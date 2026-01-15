from django.contrib import admin
from .models import BlogPost

class BlogPostAdmin(admin.ModelAdmin):
    list_display = ('title', 'author', 'status', 'published_at', 'created_at')
    list_filter = ('status', 'category', 'author')
    search_fields = ('title', 'content', 'excerpt')
    prepopulated_fields = {'slug': ('title',)}
    readonly_fields = ('published_at', 'created_at', 'updated_at')

# Enregistrer correctement le modèle dans l'admin
admin.site.register(BlogPost, BlogPostAdmin)