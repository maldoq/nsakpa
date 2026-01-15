from django.db import models
from django.conf import settings


class BlogPost(models.Model):
    """
    Blog post model matching the Flutter BlogArticleModel structure
    """
    CATEGORY_CHOICES = [
        ('Histoire', 'Histoire'),
        ('Culture', 'Culture'),
        ('Artisanat', 'Artisanat'),
        ('Tradition', 'Tradition'),
    ]
    
    title = models.CharField(max_length=200)
    subtitle = models.CharField(max_length=300)
    content = models.TextField()
    
    # Author information
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='blog_posts'
    )
    
    # Images
    cover_image = models.ImageField(upload_to='blog_covers/', null=True, blank=True)
    
    # Categorization
    tags = models.JSONField(default=list, blank=True)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='Culture')
    
    # Metadata
    read_time = models.IntegerField(default=5, help_text='Estimated reading time in minutes')
    published_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Engagement metrics
    likes = models.IntegerField(default=0)
    comments_count = models.IntegerField(default=0)
    
    # Featured flag
    is_featured = models.BooleanField(default=False)
    
    # Published status
    is_published = models.BooleanField(default=True)
    
    class Meta:
        ordering = ['-published_at']
        verbose_name = 'Blog Post'
        verbose_name_plural = 'Blog Posts'
    
    def __str__(self):
        return self.title
