.DEFAULT_GOAL := help

## build:			docker-compose build
build:
	docker-compose build

## fmt: 			terraform fmt -recursive
fmt:
	docker-compose run --rm --workdir /app terraform fmt -recursive

## ci-fmt:			terraform fmt -recursive -check -diff -write=false
ci-fmt:
	docker-compose run --rm --workdir /app terraform fmt -recursive -check -diff -write=false

## validate: 		terraform validate across all environments
validate:
	docker-compose run --rm --workdir /app terraform init -backend=false
	docker-compose run --rm --workdir /app terraform validate -json

## shell:			opens a shell inside the terraform container
shell:
	docker-compose run --rm --entrypoint='' terraform /bin/ash

## pull:			docker-compose pull
pull:
	docker-compose pull

docs:
	docker-compose run --rm --workdir /app terraform-docs terraform-docs-replace-012 md /app/README.md

## help:			show this help
help:
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)
