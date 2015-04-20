#!/bin/bash
export APPLICATION_ENV="${APPLICATION_ENV:-$ENVIRONMENT}"
manage_file="manage"
if [ -f /project/$CODE_DIR/manage-docker.py ]
then
	manage_file="manage-docker"
fi
source /project/bin/activate && \
	python \
	/project/$CODE_DIR/$manage_file.py \
	runserver 0.0.0.0:8000
