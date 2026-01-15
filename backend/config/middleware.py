# config/middleware.py
# Middleware pour désactiver CSRF en développement

class DisableCSRFMiddleware:
    """
    Désactive la vérification CSRF pour le développement.
    À NE PAS utiliser en production !
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        setattr(request, '_dont_enforce_csrf_checks', True)
        response = self.get_response(request)
        return response
