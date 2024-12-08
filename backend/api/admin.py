from django.contrib import admin
from .models import Device, Message


# Register your models here.
admin.site.register(Device)
admin.site.register(Message)