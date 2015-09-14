# Originally from https://github.com/dockerfiles/django-uwsgi-nginx

FROM phusion/baseimage:0.9.17
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]

MAINTAINER Crobays <crobays@userex.nl>
ENV DOCKER_NAME django-uwsgi
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
	apt-get -y dist-upgrade

RUN apt-get install -y \
	unzip \
	software-properties-common \
	build-essential \
	python-software-properties \
	python \
	python-dev \
	python-psycopg2 \
	python-setuptools \
	libjpeg-dev \
	libmysqlclient-dev \
	libpq-dev \
	libxml2-dev \
	libxslt-dev \
	sqlite3 \
	supervisor

# install uwsgi now because it takes a little while
RUN easy_install pip
RUN pip install uwsgi
RUN pip install virtualenv

RUN ln -sf /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib && \
	ln -sf /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib && \
	ln -sf /usr/lib/x86_64-linux-gnu/libz.so /usr/lib

# Exposed ENV
ENV TIMEZONE Etc/UTC
ENV ENVIRONMENT production
ENV PYTHON_VERSION 2
ENV CODE_DIR src
ENV APP_NAME main
ENV BOILERPLATE_ZIP_URL false

VOLUME /project
WORKDIR /project

# HTTP ports
EXPOSE 8000 9090 2222

RUN echo '/sbin/my_init' > /root/.bash_history

RUN echo "#!/bin/bash\necho \"\$TIMEZONE\" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata" > /etc/my_init.d/02-timezone.sh
ADD /scripts/django-config.sh /etc/my_init.d/03-django-config.sh
ADD /scripts/sshd-config.sh /etc/my_init.d/04-sshd-config.sh
RUN echo "#!/bin/bash\n echo \"Running in \$ENVIRONMENT...\"" > /etc/my_init.d/99-environment-message.sh

RUN mkdir /etc/service/uwsgi
ADD /scripts/uwsgi-run.sh /etc/service/uwsgi/run

RUN mkdir /etc/service/runsv
ADD /scripts/runsv-run.sh /etc/service/runsv/run

RUN chmod +x /etc/my_init.d/* && chmod +x /etc/service/*/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

