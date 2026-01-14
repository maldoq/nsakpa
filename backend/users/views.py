from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import authenticate
from django.db.models import Q 
from rest_framework_simplejwt.tokens import RefreshToken
from drf_spectacular.utils import extend_schema
from .models import User
from .serializers import UserSerializer


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_queryset(self):
        """Filtrage par rôle si le paramètre ?role=artisan est passé"""
        queryset = User.objects.all()
        role = self.request.query_params.get('role')
        if role:
            queryset = queryset.filter(role=role)
        return queryset

    def get_permissions(self):
        """
        GET & POST (inscription) : public (AllowAny)
        PUT/DELETE : authentifié (IsAuthenticated)
        """
        if self.action in ['list', 'retrieve', 'create']:
            return [AllowAny()]
        return [IsAuthenticated()]


@extend_schema(
    request={
        'application/json': {
            'type': 'object',
            'properties': {
                'username': {'type': 'string', 'description': 'Email ou Téléphone'},
                'password': {'type': 'string'},
            },
            'required': ['username', 'password'],
        }
    },
    responses={
        200: {'description': 'Login réussi'},
        401: {'description': 'Erreur auth'}
    },
    description="Login via Email OU Téléphone"
)
@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    login_input = request.data.get('username')
    password = request.data.get('password')

    if not login_input or not password:
        return Response({'error': 'Identifiant et mot de passe requis'}, status=status.HTTP_400_BAD_REQUEST)

    user_obj = User.objects.filter(Q(username=login_input) | Q(email=login_input)).first()

    if user_obj is None:
        return Response({'error': 'Compte introuvable'}, status=status.HTTP_401_UNAUTHORIZED)
    
    if not user_obj.check_password(password):
        return Response({'error': 'Mot de passe incorrect'}, status=status.HTTP_401_UNAUTHORIZED)
    
    if not user_obj.is_active:
        return Response({'error': 'Compte désactivé'}, status=status.HTTP_401_UNAUTHORIZED)

    refresh = RefreshToken.for_user(user_obj)
    
    return Response({
        'refresh': str(refresh),
        'token': str(refresh.access_token),
        'user': UserSerializer(user_obj).data
    })