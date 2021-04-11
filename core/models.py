from django.db import models

# Create your models here.
class Something(models.Model):
    text = models.CharField(max_length=250)
    created = models.DateTimeField(auto_now_add=True)