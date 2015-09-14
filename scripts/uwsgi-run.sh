#!/bin/bash
export APPLICATION_ENV="${APPLICATION_ENV:-$ENVIRONMENT}"
source /project/bin/activate && \
cd /project && \
uwsgi \
	--socket=0.0.0.0:3031 \
	--chmod-socket=666 \
	--home=/project \
	--pythonpath=/project/$CODE_DIR \
	--module=$APP_NAME.wsgi
