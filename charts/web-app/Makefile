

all: dry

dry:
	helm template web . --set domain=test.com --set sa_project_id=saproj --set db_project_id=dbproj || exit 1

