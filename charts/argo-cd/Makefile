

all: dry

dep:
	helm dep update

dry:
	helm template -n test test . -f ./values.yaml -f ./test-values.yaml > test-output.yaml || exit 1
	git diff test-output.yaml

