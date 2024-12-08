from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Device, Message

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email')

class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        fields = ('id', 'name', 'fcm_token', 'phone_number', 'secret_key', 'sms_limit')
        read_only_fields = ('secret_key',)

class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = ('id', 'message', 'device', 'created_at')
