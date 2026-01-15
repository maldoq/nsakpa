from django.db import models
from django.conf import settings
from django.utils.text import slugify
from django.utils import timezone

class BlogPost(models.Model):
    STATUS_CHOICES = [
        ('draft', 'Brouillon'),
        ('published', 'Publié'),
        ('archived', 'Archivé'),
    ]

    title = models.CharField(max_length=200, verbose_name="Titre")
    slug = models.SlugField(unique=True, blank=True)
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='blog_posts')
    content = models.TextField(verbose_name="Contenu")
    excerpt = models.TextField(max_length=500, blank=True, verbose_name="Extrait")
    featured_image = models.ImageField(upload_to='blog_images/', blank=True, null=True, verbose_name="Image de couverture")
    category = models.CharField(max_length=100, default='Général', verbose_name="Catégorie")
    tags = models.CharField(max_length=200, blank=True, help_text="Séparez les tags par des virgules")
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft', verbose_name="Statut")
    published_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    view_count = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.title)
        if self.status == 'published' and not self.published_at:
            self.published_at = timezone.now()
        super().save(*args, **kwargs)
    
    def __str__(self):
        return self.title

    # Helper pour template: convertir tags str en liste
    def get_tags_list(self):
        return [tag.strip() for tag in self.tags.split(',')] if self.tags else []

class Comment(models.Model):
    post = models.ForeignKey(BlogPost, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    content = models.TextField(verbose_name="Commentaire")
    created_at = models.DateTimeField(auto_now_add=True)
    active = models.BooleanField(default=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'Commentaire par {self.author.username} sur {self.post}'
