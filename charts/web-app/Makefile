

all: dep dry

dep:
	helm dep update

dry:
	helm template web . --set domain=test.com -f ./values.yaml || exit 1

