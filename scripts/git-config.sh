#!/bin/bash

if [ ! -f /project/.gitignore ]
then
	echo "Adding Python/Django-based gitignore to project"
	cp /conf/gitignore /project/.gitignore
fi