from django.test import TestCase
from django.contrib.auth import get_user_model
from .models import BlogPost


User = get_user_model()


class BlogPostModelTest(TestCase):
    """Test the BlogPost model"""
    
    def setUp(self):
        """Create a test user and blog post"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            first_name='Test',
            last_name='User'
        )
        
        self.blog_post = BlogPost.objects.create(
            title='Test Article',
            subtitle='Test subtitle',
            content='Test content for the blog post',
            author=self.user,
            category='Culture',
            tags=['test', 'article'],
            read_time=5,
            is_published=True
        )
    
    def test_blog_post_creation(self):
        """Test that blog post was created successfully"""
        self.assertEqual(BlogPost.objects.count(), 1)
        self.assertEqual(self.blog_post.title, 'Test Article')
        self.assertEqual(self.blog_post.author, self.user)
    
    def test_blog_post_str(self):
        """Test the string representation"""
        self.assertEqual(str(self.blog_post), 'Test Article')
    
    def test_blog_post_defaults(self):
        """Test default values"""
        self.assertEqual(self.blog_post.likes, 0)
        self.assertEqual(self.blog_post.comments_count, 0)
        self.assertTrue(self.blog_post.is_published)
        self.assertFalse(self.blog_post.is_featured)
    
    def test_blog_post_ordering(self):
        """Test that posts are ordered by published_at descending"""
        post2 = BlogPost.objects.create(
            title='Second Article',
            subtitle='Second subtitle',
            content='Second content',
            author=self.user,
            category='Histoire'
        )
        
        posts = BlogPost.objects.all()
        self.assertEqual(posts[0], post2)  # Most recent first
        self.assertEqual(posts[1], self.blog_post)


class BlogViewsTest(TestCase):
    """Test blog-related views"""
    
    def setUp(self):
        """Create test data"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        
        # Create published posts
        for i in range(3):
            BlogPost.objects.create(
                title=f'Published Post {i}',
                subtitle=f'Subtitle {i}',
                content=f'Content {i}',
                author=self.user,
                category='Culture',
                is_published=True
            )
        
        # Create unpublished post
        BlogPost.objects.create(
            title='Unpublished Post',
            subtitle='Draft subtitle',
            content='Draft content',
            author=self.user,
            category='Culture',
            is_published=False
        )
    
    def test_post_list_view(self):
        """Test that post_list view returns only published posts"""
        response = self.client.get('/blog/')
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'Published Post')
        self.assertNotContains(response, 'Unpublished Post')
    
    def test_post_list_view_pagination(self):
        """Test pagination in post_list view"""
        # Create more posts to test pagination
        for i in range(15):
            BlogPost.objects.create(
                title=f'Extra Post {i}',
                subtitle=f'Extra Subtitle {i}',
                content=f'Extra Content {i}',
                author=self.user,
                category='Artisanat',
                is_published=True
            )
        
        response = self.client.get('/blog/')
        self.assertEqual(response.status_code, 200)
        # Should have pagination object
        self.assertTrue('posts' in response.context)
    
    def test_post_detail_view(self):
        """Test post_detail view"""
        post = BlogPost.objects.filter(is_published=True).first()
        response = self.client.get(f'/blog/{post.pk}/')
        self.assertEqual(response.status_code, 200)
        # Verify the post is in the context
        self.assertEqual(response.context['post'], post)
    
    def test_post_detail_view_unpublished(self):
        """Test that unpublished posts return 404"""
        post = BlogPost.objects.filter(is_published=False).first()
        response = self.client.get(f'/blog/{post.pk}/')
        self.assertEqual(response.status_code, 404)
