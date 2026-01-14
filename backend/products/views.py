from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Product
from .serializers import ProductSerializer

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all().order_by('-created_at')
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        # Filtrer par catégorie ou recherche si nécessaire
        queryset = super().get_queryset()
        category = self.request.query_params.get('category')
        search = self.request.query_params.get('search')
        
        if category:
            queryset = queryset.filter(category__iexact=category)
        if search:
            queryset = queryset.filter(name__icontains=search)
            
        return queryset

    # C'EST ICI LA CORRECTION IMPORTANTE
    def perform_create(self, serializer):
        # Associe le produit à l'artisan (l'utilisateur connecté)
        serializer.save(artisan=self.request.user)

    # Endpoint personnalisé pour les produits de l'artisan connecté
    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def my_products(self, request):
        # /api/products/my_products/
        products = Product.objects.filter(artisan=request.user)
        
        # Appliquer les filtres
        category = request.query_params.get('category')
        search = request.query_params.get('search')
        
        if category:
            products = products.filter(category__iexact=category)
        if search:
            products = products.filter(name__icontains=search)
            
        products = products.order_by('-created_at')
        serializer = self.get_serializer(products, many=True)
        return Response(serializer.data)