# orders/serializers.py
from rest_framework import serializers
from .models import Order, OrderItem

class OrderItemSerializer(serializers.ModelSerializer):
    product_id = serializers.CharField(source='product.id', read_only=True)
    product_name = serializers.CharField(read_only=True)
    product_image = serializers.SerializerMethodField()
    artisan_name = serializers.CharField(source='artisan.first_name', read_only=True)
    total_price = serializers.SerializerMethodField()

    class Meta:
        model = OrderItem
        fields = [
            'id',
            'product_id',
            'product_name',
            'product_image',
            'quantity',
            'unit_price',
            'total_price',
            'artisan_name',
        ]

    def get_product_image(self, obj):
        if obj.product and obj.product.images.exists():
            request = self.context.get('request')
            image = obj.product.images.first()
            if image and image.image:
                if request:
                    return request.build_absolute_uri(image.image.url)
                return image.image.url
        return None

    def get_total_price(self, obj):
        return obj.unit_price * obj.quantity


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    buyer_id = serializers.CharField(source='buyer.id', read_only=True)
    buyer_name = serializers.CharField(source='buyer.first_name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    
    # Champs calculés pour l'artisan principal (premier artisan des items)
    artisan_id = serializers.SerializerMethodField()
    artisan_name = serializers.SerializerMethodField()
    
    # Champs manquants pour Flutter
    subtotal = serializers.SerializerMethodField()
    delivery_fee = serializers.SerializerMethodField()
    payment_status = serializers.SerializerMethodField()
    confirmed_at = serializers.SerializerMethodField()
    delivered_at = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = [
            'id',
            'buyer_id',
            'buyer_name',
            'artisan_id',
            'artisan_name',
            'status',
            'status_display',
            'total_amount',
            'subtotal',
            'delivery_fee',
            'delivery_address',
            'delivery_phone',
            'payment_method',
            'payment_status',
            'transaction_id',
            'is_paid',
            'is_delivered',
            'is_received',
            'created_at',
            'confirmed_at',
            'delivered_at',
            'received_at',
            'updated_at',
            'items',
        ]
        read_only_fields = ['buyer_id', 'buyer_name', 'created_at', 'updated_at']

    def get_artisan_id(self, obj):
        """Récupère l'ID du premier artisan dans les items"""
        first_item = obj.items.first()
        if first_item and first_item.artisan:
            return str(first_item.artisan.id)
        return ''

    def get_artisan_name(self, obj):
        """Récupère le nom du premier artisan dans les items"""
        first_item = obj.items.first()
        if first_item and first_item.artisan:
            return first_item.artisan.first_name or first_item.artisan.username
        return ''
    
    def get_subtotal(self, obj):
        """Pour l'instant, subtotal = total (pas de frais de livraison séparés)"""
        return obj.total_amount
    
    def get_delivery_fee(self, obj):
        """Pour l'instant, pas de frais de livraison"""
        return 0
    
    def get_payment_status(self, obj):
        """Mappe is_paid vers payment_status"""
        if obj.is_paid:
            return 'inescrow'  # Correspondant à PaymentStatus.inEscrow dans Flutter
        return 'pending'
    
    def get_confirmed_at(self, obj):
        """Pour l'instant, utilisez updated_at si la commande est payée"""
        if obj.status in ['paid', 'preparing', 'delivering', 'delivered']:
            return obj.updated_at
        return None
    
    def get_delivered_at(self, obj):
        """Pour l'instant, utilisez updated_at si la commande est livrée"""
        if obj.status == 'delivered':
            return obj.updated_at
        return None