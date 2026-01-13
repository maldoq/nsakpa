from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
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
    # On récupère le paramètre 'username' envoyé par Flutter
    # Ce paramètre contient soit le téléphone, soit l'email
    login_input = request.data.get('username')
    password = request.data.get('password')

    if not login_input or not password:
        return Response({'error': 'Identifiant et mot de passe requis'}, status=status.HTTP_400_BAD_REQUEST)

    # Recherche flexible : Email OU Username (Phone)
    user_obj = User.objects.filter(Q(username=login_input) | Q(email=login_input)).first()

    if user_obj is None:
        return Response({'error': 'Compte introuvable'}, status=status.HTTP_401_UNAUTHORIZED)
    
    if not user_obj.check_password(password):
        return Response({'error': 'Mot de passe incorrect'}, status=status.HTTP_401_UNAUTHORIZED)
    
    if not user_obj.is_active:
        return Response({'error': 'Compte désactivé'}, status=status.HTTP_401_UNAUTHORIZED)

    # Génération du token JWT
    refresh = RefreshToken.for_user(user_obj)
    
    return Response({
        'refresh': str(refresh),
        'token': str(refresh.access_token),
        'user': UserSerializer(user_obj).data
    })