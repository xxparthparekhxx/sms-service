from django.db import models
from django.contrib.auth.models import User  # Import Django's User model
from uuid import uuid4

class Device(models.Model):
    name = models.CharField(max_length=100)
    fcm_token = models.CharField(max_length=200)
    phone_number = models.CharField(max_length=15)
    secret_key = models.CharField(max_length=100, default=uuid4)
    sms_limit = models.IntegerField(default=0)
    user = models.ForeignKey(User, related_name='devices', on_delete=models.CASCADE)  # Link to Django User

    def __str__(self):
        return self.name

class Message(models.Model):
    message = models.CharField(max_length=200)
    device = models.ForeignKey(Device, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
