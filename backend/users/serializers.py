from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    # C'EST LA CORRECTION CRUCIALE :
    # On dit à Django : "Le champ 'name' correspond à 'first_name' dans la BDD"
    name = serializers.CharField(source='first_name', required=True)
    
    password = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})

    class Meta:
        model = User
        fields = [
            'id', 
            'username', 
            'email', 
            'name',  # Ici on utilise 'name' car on l'a défini juste au-dessus
            'password', 
            'role', 
            'phone', 
            'profile_image', 
            'location', 
            'bio', 
            'stand_name', 
            'specialties', 
            'is_verified', 
            'working_hours', 
            'years_of_experience'
        ]
        # Pas besoin de mettre 'name' dans extra_kwargs car on l'a défini manuellement en haut

    def create(self, validated_data):
        # 1. On extrait le mot de passe
        password = validated_data.pop('password', None)
        
        # Note : Grâce à source='first_name', validated_data contient déjà 'first_name' 
        # au lieu de 'name'. Django a fait la conversion automatiquement.
        
        # 2. On crée l'instance
        instance = self.Meta.model(**validated_data)
        
        # 3. On crypte le mot de passe
        if password is not None:
            instance.set_password(password)
        
        instance.save()
        return instance