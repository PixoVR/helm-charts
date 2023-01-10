

all: dep dry

dep:
	helm dep update

dry:
	helm template web . -f ./values.yaml -f ./test-values.yaml || exit 1

