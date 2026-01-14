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

    class Meta:
        model = Order
        fields = [
            'id',
            'buyer_id',
            'buyer_name',
            'status',
            'status_display',
            'total_amount',
            'delivery_address',
            'delivery_phone',
            'payment_method',
            'transaction_id',
            'is_paid',
            'created_at',
            'updated_at',
            'items',
        ]
        read_only_fields = ['buyer_id', 'buyer_name', 'created_at', 'updated_at']