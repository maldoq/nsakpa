from products.models import Product
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db import transaction
from .models import Order, OrderItem
from .serializers import OrderSerializer

class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(buyer=self.request.user)

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        user = request.user

        items_data = request.data.get('items', [])
        delivery_address = request.data.get('delivery_address')
        delivery_phone = request.data.get('delivery_phone')
        payment_method = request.data.get('payment_method', 'orange_money')

        if not items_data:
            return Response(
                {"error": "Le panier est vide"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 1️⃣ créer la commande vide
        order = Order.objects.create(
            buyer=user,
            delivery_address=delivery_address,
            delivery_phone=delivery_phone,
            payment_method=payment_method,
            total_amount=0,
        )

        total = 0

        # 2️⃣ créer les items
        for item in items_data:
            product_id = item.get('product_id')
            quantity = int(item.get('quantity', 1))

            try:
                product = Product.objects.get(id=product_id)
            except Product.DoesNotExist:
                transaction.set_rollback(True)
                return Response(
                    {"error": f"Produit {product_id} introuvable"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            price = product.price
            line_total = price * quantity
            total += line_total

            OrderItem.objects.create(
                order=order,
                product=product,
                quantity=quantity,
                price=price,
            )

        # 3️⃣ mettre à jour le total
        order.total_amount = total
        order.save()

        # 4️⃣ retourner la commande complète
        serializer = self.get_serializer(order)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['get'], url_path='my')
    def my_orders(self, request):
        user = request.user

        qs = Order.objects.filter(buyer=user).order_by('-created_at')

        # gestion du ?limit=
        limit = request.query_params.get('limit')
        if limit:
            try:
                qs = qs[:int(limit)]
            except ValueError:
                pass

        serializer = self.get_serializer(qs, many=True)
        return Response(serializer.data)
