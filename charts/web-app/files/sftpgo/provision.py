import base64
import hashlib
import hmac
import json
import os
import sys
import time
import urllib.error
import urllib.request

API_URL = os.environ["SFTPGO_API_URL"].rstrip("/")
ADMIN_USERNAME = os.environ["SFTPGO_ADMIN_USERNAME"]
BUCKET = os.environ["SFTPGO_BUCKET"]
WAIT_SECONDS = int(os.environ.get("SFTPGO_WAIT_SECONDS", "300"))

ACCOUNTS_FILE = "/provisioning/accounts.json"
ADMIN_PASSWORD_FILE = "/secrets/admin/password"
PASSWORDS_DIR = "/secrets/passwords"

GCS_PROVIDER = 2
PERMISSIONS = ["list", "download"]
# SFTPGo keeps a stored password when an update omits it, so an account without one
# has every password-based sign-in method denied instead.
PASSWORD_LOGIN_METHODS = [
    "password",
    "password-over-SSH",
    "keyboard-interactive",
    "publickey+password",
    "publickey+keyboard-interactive",
]
# Transfers need local scratch space that exists after every restart; nothing is stored there.
SCRATCH_DIR = "/tmp"
FINGERPRINT_PREFIX = "fingerprint="
PAGE_SIZE = 500


class ProvisioningError(Exception):
    pass


def read_secret(path):
    try:
        with open(path, encoding="utf-8") as f:
            return f.read().strip()
    except FileNotFoundError:
        return ""


def call(method, path, token=None, basic=None, body=None):
    request = urllib.request.Request(API_URL + path, method=method)
    if token:
        request.add_header("Authorization", "Bearer " + token)
    if basic:
        encoded = base64.b64encode(":".join(basic).encode()).decode()
        request.add_header("Authorization", "Basic " + encoded)
    data = None
    if body is not None:
        data = json.dumps(body).encode()
        request.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(request, data=data, timeout=30) as response:
            payload = response.read()
            return response.status, json.loads(payload) if payload else None
    except urllib.error.HTTPError as e:
        return e.code, error_reason(e.read())
    except OSError as e:
        return None, str(e)


def error_reason(payload):
    try:
        body = json.loads(payload)
    except ValueError:
        return payload.decode(errors="replace").strip()
    return ": ".join(part for part in (body.get("message"), body.get("error")) if part)


def failure(action, status, reason):
    detail = f"status {status}"
    if reason:
        detail += f", {reason}"
    return ProvisioningError(f"{action} failed ({detail})")


def wait_for_server():
    deadline = time.monotonic() + WAIT_SECONDS
    while True:
        status, reason = call("GET", "/api/v2/version")
        if status is not None:
            return
        if time.monotonic() >= deadline:
            raise ProvisioningError(
                f"server was not ready after {WAIT_SECONDS} seconds ({reason})"
            )
        time.sleep(2)


def read_passwords(accounts):
    passwords = {}
    missing = []
    for account in accounts:
        if not account["password"]:
            continue
        username = account["username"]
        passwords[username] = read_secret(os.path.join(PASSWORDS_DIR, username))
        if not passwords[username]:
            missing.append(username)
    if missing:
        raise ProvisioningError(
            "; ".join(f"account {u}: password is missing from the secret store" for u in missing)
        )
    return passwords


def fingerprint(user, key):
    canonical = json.dumps(user, sort_keys=True).encode()
    return FINGERPRINT_PREFIX + hmac.new(key.encode(), canonical, hashlib.sha256).hexdigest()


def matches(existing, user):
    gcs = existing.get("filesystem", {}).get("gcsconfig", {})
    wanted = user["filesystem"]["gcsconfig"]
    return (
        existing.get("additional_info") == user["additional_info"]
        and existing.get("status") == user["status"]
        and existing.get("home_dir") == user["home_dir"]
        and existing.get("permissions") == user["permissions"]
        and existing.get("public_keys", []) == user["public_keys"]
        and existing.get("filters", {}).get("denied_login_methods", [])
        == user["filters"]["denied_login_methods"]
        and existing.get("filesystem", {}).get("provider") == GCS_PROVIDER
        and gcs.get("bucket") == wanted["bucket"]
        and gcs.get("key_prefix") == wanted["key_prefix"]
        and gcs.get("automatic_credentials") == wanted["automatic_credentials"]
    )


def desired_user(account, password, key):
    user = {
        "username": account["username"],
        "status": 1,
        "home_dir": SCRATCH_DIR,
        "permissions": {"/": PERMISSIONS},
        "public_keys": account["public_keys"],
        "filesystem": {
            "provider": GCS_PROVIDER,
            "gcsconfig": {
                "bucket": BUCKET,
                "key_prefix": account["key_prefix"],
                "automatic_credentials": 1,
            },
        },
    }
    if password:
        user["password"] = password
    user["filters"] = {"denied_login_methods": [] if password else PASSWORD_LOGIN_METHODS}
    user["additional_info"] = fingerprint(user, key)
    return user


def main():
    with open(ACCOUNTS_FILE, encoding="utf-8") as f:
        accounts = json.load(f)

    passwords = read_passwords(accounts)
    admin_password = read_secret(ADMIN_PASSWORD_FILE)
    wait_for_server()
    status, response = call("GET", "/api/v2/token", basic=(ADMIN_USERNAME, admin_password))
    if status != 200:
        raise failure("administrator sign-in", status, response)
    token = response["access_token"]

    for account in accounts:
        username = account["username"]
        user = desired_user(account, passwords.get(username, ""), admin_password)
        status, existing = call("GET", f"/api/v2/users/{username}", token=token)
        if status == 200 and matches(existing, user):
            print(f"account {username}: unchanged")
        elif status == 404:
            status, reason = call("POST", "/api/v2/users", token=token, body=user)
            if status != 201:
                raise failure(f"account {username}: create", status, reason)
            print(f"account {username}: created")
        elif status == 200:
            status, reason = call(
                "PUT", f"/api/v2/users/{username}?disconnect=1", token=token, body=user
            )
            if status != 200:
                raise failure(f"account {username}: update", status, reason)
            print(f"account {username}: updated")
        else:
            raise failure(f"account {username}: lookup", status, existing)

    declared = {account["username"] for account in accounts}
    for username in sorted(existing_usernames(token) - declared):
        status, reason = call("DELETE", f"/api/v2/users/{username}", token=token)
        if status != 200:
            raise failure(f"account {username}: remove", status, reason)
        print(f"account {username}: removed")


def existing_usernames(token):
    usernames = set()
    offset = 0
    while True:
        status, page = call("GET", f"/api/v2/users?limit={PAGE_SIZE}&offset={offset}", token=token)
        if status != 200:
            raise failure("listing accounts", status, page)
        usernames.update(user["username"] for user in page)
        if len(page) < PAGE_SIZE:
            return usernames
        offset += PAGE_SIZE


if __name__ == "__main__":
    try:
        main()
    except ProvisioningError as e:
        print(f"provisioning failed: {e}", file=sys.stderr)
        sys.exit(1)
