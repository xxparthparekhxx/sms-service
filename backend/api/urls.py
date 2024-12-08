from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DeviceViewSet, LoginView,send_sms,RefreshTokenView

router = DefaultRouter()
router.register(r'devices', DeviceViewSet, basename='device')

urlpatterns = [
    path('', include(router.urls)),
    path('login/', LoginView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', RefreshTokenView.as_view(), name='token_refresh'),
    path('send-sms/', send_sms, name='send_sms'),
]
