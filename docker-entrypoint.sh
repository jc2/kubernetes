#!/bin/bash

if [[ $APP_MODE == "api" ]]
then
    echo "Running in api mode"
    python manage.py migrate 
    python manage.py collectstatic --noinput
    gunicorn django_web.wsgi:application --bind 0.0.0.0:8000 
elif [[ $APP_MODE == "worker" ]]
then
    echo "Running in worker mode";
    celery -A django_web worker -c 4 -l info
elif [[ $APP_MODE == "scheduler" ]]
then
    echo "Running in scheduler mode";
    celery -A django_web beat
else
    echo "No mode selected";
fi
