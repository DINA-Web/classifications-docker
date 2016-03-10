from django.contrib.auth.models import User
from provider.oauth2.models import Client

u = User.objects.create_superuser(
	'admin', 
	'admin@example.com', 
	'password12')

c = Client(user = u, 
	name = 'admin', 
	url = 'http://test.url', 
	redirect_uri = 'http://test.url', 
	client_id = 'a27a3bc616b1ed2ff965',
	client_secret = '9174b76bcba9ab2188ada16bd6eb7166d2b3c71b', 
	client_type = 0)

c.save()

