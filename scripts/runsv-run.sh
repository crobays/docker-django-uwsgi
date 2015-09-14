#!/bin/bash
export APPLICATION_ENV="${APPLICATION_ENV:-$ENVIRONMENT}"
source /project/bin/activate
echo "Running runserver..."
python \
	/project/$CODE_DIR/manage.py \
	runserver 0.0.0.0:8000
