.PHONY: static


base_compose_path = "run-base-services.yml"
backend_docker_compose_path = "run-backend-services.yml"
broker_docker_compose_path = "run-broker-services.yml"
s3_docker_compose_path = "run-s3-service.yml"
nginx_docker_compose_path = "run-nginx-service.yml"

BASE_DC = docker compose
BASE_DC += -f $(base_compose_path)
BASE_DC += -f $(backend_docker_compose_path)
BASE_DC += -f $(broker_docker_compose_path)
BASE_DC += -f $(s3_docker_compose_path)
BASE_DC += -f $(nginx_docker_compose_path)
PYTHONPATH = ./backend


build-no-cache:
	$(BASE_DC) build --no-cache

build:
	$(BASE_DC) build

up:
	$(BASE_DC) up -d

down:
	$(BASE_DC) down --remove-orphans

# Tools

image-build:
	DOCKER_BUILDKIT=1 docker build \
		--platform=linux/amd64 \
		-f Dockerfile \
		-t test-image .

# Development

format: # format your code according to project linter tools
	poetry run black . -t py312
	poetry run isort .

black:
	poetry run black --check backend -t py312

isort:
	poetry run isort --check backend

flake8:
	poetry run flake8 --inline-quotes '"'

pylint:
	PYTHONPATH=$(PYTHONPATH) poetry run pylint backend

mypy:
	PYTHONPATH=$(PYTHONPATH) poetry run mypy --namespace-packages --show-error-codes backend --check-untyped-defs --ignore-missing-imports --show-traceback --enable-incomplete-feature=NewGenericSyntax

lint: black isort flake8 pylint mypy

pip-audit:
	@# We don't use python-jose (`GHSA-cjwg-qfpm-7377`, `GHSA-6c5p-j8vq-pqhj`)
	poetry run pip-audit \
		--ignore-vuln GHSA-cjwg-qfpm-7377 \
		--ignore-vuln GHSA-6c5p-j8vq-pqhj

test:
	PYTHONPATH=$(PYTHONPATH) poetry run pytest -n 2 --reuse-db

poetry-install:
	poetry config virtualenvs.create false
	poetry install --no-root --no-interaction

ci-lint: poetry-install lint

ci-test: poetry-install test

ci-deps-audit: poetry-install pip-audit

all: format lint test pip-audit
