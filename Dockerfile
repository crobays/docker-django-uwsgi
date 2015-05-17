# Copyright 2013 Thatcher Peskens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM phusion/baseimage:0.9.16
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]

MAINTAINER Crobays <crobays@userex.nl>
ENV DOCKER_NAME django-uwsgi
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get install -y software-properties-common

RUN apt-get install -y \
	python-software-properties \
	python \
	python-dev \
	python-setuptools \
	sqlite3 \
	libmysqlclient-dev \
	libjpeg-dev \
	supervisor

# install uwsgi now because it takes a little while
RUN easy_install pip
RUN pip install uwsgi
RUN pip install virtualenv

# Exposed ENV
ENV TIMEZONE Etc/UTC
ENV ENVIRONMENT production
ENV PYTHON_VERSION 2
ENV CODE_DIR src
ENV PROJECT_NAME main
ENV CUSTOM_BOILERPLATE false

VOLUME /project
WORKDIR /project

# HTTP ports
EXPOSE 8000 9090

RUN echo '/sbin/my_init' > /root/.bash_history

RUN echo "#!/bin/bash\necho \"\$TIMEZONE\" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata" > /etc/my_init.d/01-timezone.sh
ADD /scripts/uwsgi-config.sh /etc/my_init.d/02-uwsgi-config.sh
ADD /scripts/django-config.sh /etc/my_init.d/03-django-config.sh
ADD /scripts/git-config.sh /etc/my_init.d/04-git-config.sh
RUN echo "#!/bin/bash\n echo \"Running in \$ENVIRONMENT...\"" > /etc/my_init.d/99-environment-message.sh

RUN mkdir /etc/service/uwsgi
ADD /scripts/uwsgi-run.sh /etc/service/uwsgi/run

RUN mkdir /etc/service/runsv
ADD /scripts/runsv-run.sh /etc/service/runsv/run

RUN chmod +x /etc/my_init.d/* && chmod +x /etc/service/*/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD /conf /conf

