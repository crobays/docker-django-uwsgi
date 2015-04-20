from base import *

# Temp domains for production period
# ALLOWED_HOSTS = [
#     '',
# ]

# Speed up templates
TEMPLATE_LOADERS = (
    ('django.template.loaders.cached.Loader', (
        'django.template.loaders.filesystem.Loader',
        'django.template.loaders.app_directories.Loader',
    )),
)

# Optimize thumbnails for production
INSTALLED_APPS += (
    'easy_thumbnails.optimize',
)

# Save sessions in cache
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'default'

# Media and static setup
# MEDIA_URL = 'http://assets-www.example.nl/media/'
# STATIC_URL = 'http://assets-www.example.nl/static/'

# PREPEND_WWW = True
