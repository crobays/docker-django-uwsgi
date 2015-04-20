# uWSGI with Django in a container

This Dockerfile allows you to build a Docker container with a fairly standard
and speedy setup for Django with uWSGI.

uWSGI from a number of benchmarks has shown to be the fastest server 
for python applications and allows lots of flexibility.

Feel free to clone this and modify it to your liking. And feel free to 
contribute patches.

### Build and run
    docker build -t webapp .
    docker run \
        -v ./:/project \
        -e PUBLIC_PATH=/project/app \
        -e TIMEZONE=Etc/UTC \
        -p 80:80 \
        -it --rm \
        webapp

### How to insert your application

In /app currently a django project is created with startproject. You will
probably want to replace the content of /app with the root of your django
project.

uWSGI chdirs to /app so in uwsgi.ini you will need to make sure the python path
to the wsgi.py file is relative to that.

