

all: dry

dry:
	helm template web . -f ./services/web.yaml --set domain=test.com || exit 1
	helm template api . -f ./services/api.yaml --set domain=test.com || exit 1
	helm template goapi . -f ./services/goapi.yaml --set domain=test.com || exit 1
	helm template graphql . -f ./services/graphql.yaml --set domain=test.com || exit 1


test: 
	http https://apex.pixo-app.com -h | head -n 1 || exit 1
	http https://modules.pixo-app.com/ping -h | head -n 1 || exit 1
	http https://api.pixo-app.com/health -h | head -n 1 || exit 1


