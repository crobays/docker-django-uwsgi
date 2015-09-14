# uWSGI with Django in a container

This Dockerfile allows you to build a Docker container with a fairly standard
and speedy setup for Django with uWSGI.

uWSGI from a number of benchmarks has shown to be the fastest server 
for python applications and allows lots of flexibility.

Feel free to clone this and modify it to your liking. And feel free to 
contribute patches.

### Run in current project
    docker run \
        -v $PWD/:/project \
        -e TIMEZONE=Etc/UTC \
        -e ENVIRONMENT=development \
        -e APP_NAME=main \
        -e BOILERPLATE_ZIP_URL="https://github.com/crobays/boilerplate-django/archive/master.zip" \
        -p 80:8000 \
        -it \
        crobays/django-uwsgi

### How to insert your application

In /app currently a django project is created with startproject. You will
probably want to replace the content of /app with the root of your django
project.

uWSGI chdirs to /app so in uwsgi.ini you will need to make sure the python path
to the wsgi.py file is relative to that.

