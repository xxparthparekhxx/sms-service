from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView
from django.contrib.auth.models import User
from .models import Device, Message
from .serializers import UserSerializer, DeviceSerializer, MessageSerializer
import firebase_admin
from firebase_admin import messaging

class DeviceViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = DeviceSerializer

    def get_queryset(self):
        return Device.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_sms(request):
    device_id = request.data.get('device_id')
    message_text = request.data.get('message')
    recipient = request.data.get('recipient')

    try:
        device = Device.objects.get(id=device_id, user=request.user)
        
        # Create message record
        message = Message.objects.create(
            device=device,
            message=message_text
        )

        # Send FCM notification
        message = messaging.Message(
            data={
                'message': message_text,
                'recipient': recipient,
            },
            token=device.fcm_token,
        )
        
        response = messaging.send(message)
        
        return Response({
            'status': 'success',
            'message_id': response
        })

    except Device.DoesNotExist:
        return Response({
            'error': 'Device not found'
        }, status=status.HTTP_404_NOT_FOUND)