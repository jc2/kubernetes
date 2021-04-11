from __future__ import absolute_import, unicode_literals
from time import sleep

from celery import shared_task

from .models import Something

@shared_task
def add_something(text):
    print("Creating something in 10 seconds")
    sleep(10)
    s = Something()
    s.text = text
    s.save()