import json

from django.http import HttpResponse

from .models import Something
from .tasks import add_something


def index(request):
    response_data = []
    for s in Something.objects.all():
        response_data.append({'text': s.text, 'created': int(s.created.timestamp() * 1000)})
    return HttpResponse(json.dumps(response_data), content_type="application/json")


def create_something(request):
    # if request.method == 'GET':
    text = request.GET.get('text')
    if text:
        add_something.delay(text)
        response_data ={
            "message": "You have created something"
        }
    else:
        response_data ={
            "message": "Do you even know what you are doing?"
        }
    return HttpResponse(json.dumps(response_data), content_type="application/json")
