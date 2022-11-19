

all: dry

dry:
	helm template web . --set domain=test.com -f ./values.yaml || exit 1

