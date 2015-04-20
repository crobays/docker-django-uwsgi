#!/bin/bash
export APPLICATION_ENV="${APPLICATION_ENV:-$ENVIRONMENT}"
wsgi_file="wsgi"
if [ -f /project/$CODE_DIR/$PROJECT_NAME/wsgi-docker.py ]
then
	wsgi_file="wsgi-docker"
fi

source /project/bin/activate && \
cd /project && \
uwsgi \
	--socket=/var/run/uwsgi.sock \
	--chmod-socket=666 \
	--home=/project \
	--pythonpath=/project/$CODE_DIR \
	--module=$PROJECT_NAME.$wsgi_file