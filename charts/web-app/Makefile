

all: dry

dry:
	helm template web . --set domain=test.com || exit 1

