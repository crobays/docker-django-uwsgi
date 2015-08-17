"""
Django settings for main project.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.6/ref/settings/
"""

from django.conf.global_settings import TEMPLATE_CONTEXT_PROCESSORS as TCP, STATICFILES_FINDERS as SFF

from django.utils.six.moves.urllib.parse import urljoinimport
import os
import sys

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))

PROJECT_DIR = os.path.dirname(BASE_DIR);

DATA_DIR = os.path.join(PROJECT_DIR, 'data');

APPLICATION_ENV = os.environ.get('APPLICATION_ENV', 'production')

# Gets error reports when not in DEBUG mode
ADMINS = (

)

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.6/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'secret'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = TEMPLATE_DEBUG = False


TEMPLATE_DIRS = (
    os.path.join(BASE_DIR, 'templates/'),
    # Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
)

TEMPLATE_CONTEXT_PROCESSORS = TCP + (
    'django.core.context_processors.request',
)

TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
    # 'apptemplates.Loader',
)


# Application definition

INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'easy_thumbnails',
)

PROJECT_APPS = (
    os.environ.get('APP_NAME', 'main'),
)

INSTALLED_APPS += PROJECT_APPS


MIDDLEWARE_CLASSES = (
    'django.middleware.gzip.GZipMiddleware',
    'htmlmin.middleware.HtmlMinifyMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'debug_toolbar.middleware.DebugToolbarMiddleware',
    'htmlmin.middleware.MarkRequestMiddleware',
)


ROOT_URLCONF = '{}.urls'.format(os.environ.get('APP_NAME', 'main'))

# WSGI_APPLICATION = '{}.wsgi.application'.format(os.environ.get('APP_NAME', 'main'))

# Authentication model
# AUTH_USER_MODEL = 'users.User'

# Cache
# CACHES = {
#     'default': {
#         'BACKEND': 'redis_cache.cache.RedisCache',
#         'LOCATION': 'localhost:6379:1',
#         'OPTIONS': {
#             'CLIENT_CLASS': 'redis_cache.client.DefaultClient',
#         }
#     }
# }

# HTML_MINIFY = True
EXCLUDE_FROM_MINIFYING = ('^admin/',)
KEEP_COMMENTS_ON_MINIFYING = True


# Database
# https://docs.djangoproject.com/en/1.6/ref/settings/#databases

DATABASES = {}

if os.environ.get('DB_PORT_5432_TCP_ADDR'):
    DATABASES['default'] = {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'HOST': os.environ.get('DB_PORT_5432_TCP_ADDR'),
        'NAME': os.environ.get('DB_ENV_POSTGRES_DB'),
        'USER': os.environ.get('DB_ENV_POSTGRES_USER'),
        'PASSWORD': os.environ.get('DB_ENV_POSTGRES_PASSWORD'),
        'CONN_MAX_AGE': 300,
        'ATOMIC_REQUESTS': True,
    }
elif os.environ.get('DB_PORT_3306_TCP_ADDR'):
    DATABASES['default'] = {
            'ENGINE': 'django.db.backends.mysql',
            'HOST': os.environ.get('DB_PORT_3306_TCP_ADDR'),
            'NAME': os.environ.get('DB_ENV_MYSQL_DATABASE'),
            'USER': os.environ.get('DB_ENV_MYSQL_USER'),
            'PASSWORD': os.environ.get('DB_ENV_MYSQL_PASSWORD'),
            'CONN_MAX_AGE': 300,
            'ATOMIC_REQUESTS': True,
    }
else:
    DATABASES['default'] = {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(DATA_DIR, 'db.sqlite3'),
    }


# Running test
if 'test' in sys.argv:
    DATABASES['default'] = {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(DATA_DIR, 'test.db'),
        'TEST_NAME': os.path.join(DATA_DIR, 'test.db'),
    }

# Internationalization
# https://docs.djangoproject.com/en/1.6/topics/i18n/

LANGUAGE_CODE = 'en'

TIME_ZONE = os.environ.get('TIMEZONE', 'Etc/UTC')

USE_I18N = True

USE_L10N = True

USE_TZ = True

LOCALE_PATHS = (
    os.path.join(BASE_DIR, 'locale/'),
)

PHONENUMBER_DEFAULT_REGION = LANGUAGE_CODE.upper()


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.6/howto/static-files/

MEDIA_URL = '{}/media/'.format(os.environ.get('ASSETS_HOST', ''))
STATIC_URL = '{}/static/'.format(os.environ.get('ASSETS_HOST', ''))

# Media setup
MEDIA_ROOT = os.path.join(os.path.dirname(BASE_DIR), 'media')

APP_STATIC_URL = urljoin(STATIC_URL, "app/")
APP_STATIC_IMAGES_URL = urljoin(MEDIA_URL, "images/")
APP_STATIC_DIST_URL = urljoin(APP_STATIC_URL, "dist/")

# Static root
STATIC_ROOT = os.path.join(os.path.dirname(BASE_DIR), 'static')

# STATICFILES_DIRS = (
#     os.path.join(BASE_DIR, 'static'),
# )

# # Minify stuff
# STATICFILES_STORAGE = 'pipeline.storage.PipelineStorage'

# STATICFILES_FINDERS = SFF + (
#     'pipeline.finders.PipelineFinder',
# )

# Media setup
MEDIA_ROOT = os.path.join(os.path.dirname(BASE_DIR), 'media')

# Suit
# SUIT_CONFIG = {
#     'ADMIN_NAME': '',
#     'HEADER_DATE_FORMAT': 'l, j F Y',
#     'SEARCH_URL': '',
#     'MENU_ICONS': {
#     },
#     'MENU': (

#     )
# }


# Geo position field settings
GEOPOSITION_MAP_WIDGET_HEIGHT = 250
GEOPOSITION_MAP_OPTIONS = {}
GEOPOSITION_MARKER_OPTIONS = {}


# Thumbnail settings
THUMBNAIL_HIGH_RESOLUTION = True
THUMBNAIL_QUALITY = 100

THUMBNAIL_PROCESSORS = (
    'easy_thumbnails.processors.colorspace',
    'easy_thumbnails.processors.autocrop',
    'easy_thumbnails.processors.scale_and_crop',
    'easy_thumbnails.processors.filters',
)

THUMBNAIL_OPTIMIZE_COMMAND = {
    'png': '/usr/bin/optipng {filename}',
    'gif': '/usr/bin/optipng {filename}',
    'jpeg': '/usr/bin/jpegoptim {filename}'
}


# E-Mail
# EMAIL_USE_TLS = True
# EMAIL_HOST = ''
# EMAIL_PORT = 587
# EMAIL_HOST_USER = ''
# EMAIL_HOST_PASSWORD = ''

# Temp disable emails
# EMAIL_BACKEND = 'django.core.mail.backends.dummy.EmailBackend'

# PIPELINE_COMPILERS = (
#     'pipeline.compilers.sass.SASSCompiler',
# )


# PIPELINE_CSS = {
#     'all': {
#         'source_filenames': (
#             'app/style/sass/master.css',
#         ),
#         'output_filename': 'css/all.css',
#         'variant': 'datauri',
#     },
#     'ie': {
#         'source_filenames': (
#             'app/style/sass/ie.sass',
#         ),
#         'output_filename': 'css/ie.css',
#         'variant': 'datauri',
#     },
# }

# PIPELINE_JS = {
#     'all': {
#         'source_filenames': (
#             'app/js/modernizr-2.8.3/modernizr-latest.js',
#             'app/js/jquery/jquery-1.11.2.min.js',
#             'app/js/raven/raven.min.js',
#             'app/js/fastclick/fastclick.js',
#             'app/js/foundation/foundation.js',
#             'app/js/foundation/foundation.topbar.js',
#             'app/js/foundation/foundation.offcanvas.js',
#             'app/js/script.js',
#         ),
#         'output_filename': 'js/all.js',
#     },
#     'ie': {
#         'source_filenames': (
#             'app/js/selectivizr-1.0.2/selectivizr-min.js',
#         ),
#         'output_filename': 'js/ie.js',
#     },
# }

