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

services_file_name = "sms-worker-586f1-firebase-adminsdk-zah4d-4dd84eb82c.json"
import firebase_admin
from firebase_admin import credentials

cred = credentials.Certificate(services_file_name)
firebase_admin.initialize_app(cred)
class DeviceViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = DeviceSerializer

    def get_queryset(self):
        return Device.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        # Delete existing device if any
        Device.objects.filter(user=self.request.user).delete()
        # Create new device
        serializer.save(user=self.request.user)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_sms(request):
    message_text = request.data.get('message')
    recipient = request.data.get('recipient')

    try:
        device = Device.objects.get(user=request.user)
        
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
        
from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator

@method_decorator(csrf_exempt, name='dispatch')
class LoginView(APIView):
    permission_classes = []

    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        
        user = authenticate(username=username, password=password)
        
        if user:
            refresh = RefreshToken.for_user(user)
            return Response({
                'access_token': str(refresh.access_token),
                'refresh_token': str(refresh)
            })
            
        return Response({'error': 'Invalid credentials'}, status=401)

@method_decorator(csrf_exempt, name='dispatch')
class RefreshTokenView(APIView):
    permission_classes = []

    def post(self, request):
        refresh_token = request.data.get('refresh_token')
        try:
            refresh = RefreshToken(refresh_token)
            return Response({
                'access_token': str(refresh.access_token),
                'refresh_token': str(refresh)
            })
        except Exception as e:
            return Response({'error': str(e)}, status=401)