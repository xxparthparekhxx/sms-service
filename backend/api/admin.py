from django.contrib import admin
from .models import Device, Message
from unfold.admin import ModelAdmin


@admin.register(Device)
class DeviceAdmin(ModelAdmin):
    list_display = ('name', 'phone_number', 'user', 'sms_limit')
    search_fields = ('name', 'phone_number')
    list_filter = ('user',)

@admin.register(Message)
class MessageAdmin(ModelAdmin):
    list_display = ('message', 'device', 'created_at')
    list_filter = ('device', 'created_at')