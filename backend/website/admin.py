from django.contrib import admin
from .models import BlogPost


@admin.register(BlogPost)
class BlogPostAdmin(admin.ModelAdmin):
    list_display = ['title', 'author', 'category', 'is_featured', 'is_published', 'published_at']
    list_filter = ['category', 'is_featured', 'is_published', 'published_at']
    search_fields = ['title', 'subtitle', 'content']
    date_hierarchy = 'published_at'
    readonly_fields = ['published_at', 'updated_at']
    
    fieldsets = (
        ('Content', {
            'fields': ('title', 'subtitle', 'content', 'cover_image')
        }),
        ('Author', {
            'fields': ('author',)
        }),
        ('Categorization', {
            'fields': ('category', 'tags')
        }),
        ('Metadata', {
            'fields': ('read_time', 'published_at', 'updated_at')
        }),
        ('Engagement', {
            'fields': ('likes', 'comments_count')
        }),
        ('Status', {
            'fields': ('is_featured', 'is_published')
        }),
    )
