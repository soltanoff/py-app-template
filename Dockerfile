FROM python:3.12-slim

ENV PYTHONUNBUFFERED 1 \
    PYTHONDONTWRITEBYTECODE 1 \
    CRYPTOGRAPHY_DONT_BUILD_RUST 1

RUN apt-get update \
    && apt-get install -y libmagic1 gcc build-essential nodejs --no-install-recommends \
    && pip install --upgrade --no-cache-dir pip wheel setuptools poetry

WORKDIR /app

# will be cached if no changes in this files
COPY poetry.lock .
COPY pyproject.toml .

COPY /scripts/start.sh /start.sh
COPY /scripts/wait-for-it.sh /wait-for-it.sh

RUN chmod +x /start.sh \
    && chmod +x /wait-for-it.sh \
    && poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction \
    && useradd -m backend \
    && chown -R backend:backend /app \
    && mkdir /static \
    && chown -R backend:backend /static

COPY backend .

# Establish the runtime user (with no password and no sudo)
USER backend
