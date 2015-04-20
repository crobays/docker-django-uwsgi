from base import *


# Turn on debug mode
DEBUG = TEMPLATE_DEBUG = True

# Add debug toolbar
INSTALLED_APPS += (
    'debug_toolbar',
)

def custom_show_toolbar(self):
    return True

DEBUG_TOOLBAR_CONFIG = {
    'SHOW_TOOLBAR_CALLBACK': custom_show_toolbar,
}

DEBUG_TOOLBAR_PATCH_SETTINGS = False

# Fake cache for development
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.dummy.DummyCache',
    }
}

# Media and static setup
# MEDIA_URL = '/media/'
# STATIC_URL = '/static/'

# temp disable emails
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# import logging
# l = logging.getLogger('django.db.backends')
# l.setLevel(logging.DEBUG)
# l.addHandler(logging.StreamHandler())
#
#
# LOGGING = {
#     'version': 1,
#     'disable_existing_loggers': False,
#     'filters': {
#         'require_debug_false': {
#             '()': 'django.utils.log.RequireDebugFalse'
#         }
#     },
#     'handlers': {
#         'mail_admins': {
#             'level': 'ERROR',
#             'filters': ['require_debug_false'],
#             'class': 'django.utils.log.AdminEmailHandler'
#         },'console': {
#             'level': 'DEBUG',
#             'class': 'logging.StreamHandler',
#         },
#     },
#     'loggers': {
#         'django.request': {
#             'handlers': ['mail_admins'],
#             'level': 'ERROR',
#             'propagate': True,
#         },'django.db.backends': {
#             'level': 'DEBUG',
#             'handlers': ['console'],
#         },
#     }
# }