#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

python manage.py migrate
python manage.py collectstatic --no-input --clear
python manage.py create_beat_tasks
python manage.py add_default_refbooks
python manage.py add_groups

uvicorn asgi:application --host 0.0.0.0 --port 8000
