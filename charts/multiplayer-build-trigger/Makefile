

all: dep diff

dep:
	helm dep update

dry:
	helm template web . -f ./values.yaml -f ./test-values.yaml > test-output.yaml || exit 1

diff: dry
	git diff test-output.yaml

