
all: diff

test:
	helm template external-dns . > test-output.yaml

diff: test
	git diff test-output.yaml

