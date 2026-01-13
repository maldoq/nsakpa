import base64
import uuid
from django.core.files.base import ContentFile
from rest_framework import serializers
from .models import Product, ProductImage
from users.serializers import UserSerializer

class ProductImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductImage
        fields = ['id', 'image', 'is_main']

class ProductSerializer(serializers.ModelSerializer):
    # Pour l'affichage (GET)
    images_details = ProductImageSerializer(source='images', many=True, read_only=True)
    artisan_details = UserSerializer(source='artisan', read_only=True)
    
    # Pour l'écriture (POST/PUT) : Accepte une liste de Base64
    images = serializers.ListField(
        child=serializers.CharField(),
        write_only=True,
        required=False
    )

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'price', 'stock', 
            'category', 'is_limited_edition', 'artisan', 
            'artisan_details', 'images', 'images_details',
            'created_at', 'updated_at'
        ]
        extra_kwargs = {
            'artisan': {'read_only': True} # L'artisan est défini automatiquement par la vue
        }

    def create(self, validated_data):
        # 1. Extraire les images (liste de strings base64)
        images_data = validated_data.pop('images', [])
        
        # 2. Créer le produit
        product = Product.objects.create(**validated_data)
        
        # 3. Traiter chaque image Base64
        for index, img_str in enumerate(images_data):
            try:
                # Format attendu: "data:image/jpeg;base64,....."
                if ';base64,' in img_str:
                    format, imgstr = img_str.split(';base64,')
                    ext = format.split('/')[-1] # ex: jpg
                    
                    # Décoder
                    data = base64.b64decode(imgstr)
                    file_name = f"{product.id}_{index}_{uuid.uuid4()}.{ext}"
                    
                    # Créer l'objet ProductImage
                    ProductImage.objects.create(
                        product=product,
                        image=ContentFile(data, name=file_name),
                        is_main=(index == 0) # La première image est principale
                    )
            except Exception as e:
                print(f"Erreur image: {e}")
                
        return product