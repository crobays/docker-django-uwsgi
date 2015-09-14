#!/bin/bash

function find_replace_add_string_to_file() {
	find="$1"
	replace="$2"
	replace_escaped="${2//\//\\/}"
	file="$3"
	label="$4"
	if [ "$file" == "" ]
	then
		file="$replace"
		replace="$find"
		find=0
		action="Added"
		echo -e "\n$replace" >> "$file"
	elif grep -q ";$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
	then
		action="Uncommented"
		sed -i "s/;$find/$replace_escaped/" "$file"
	elif grep -q "#$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
	then
		action="Uncommented"
		sed -i "s/#$find/$replace_escaped/" "$file"
	elif grep -q "$replace" "$file"
	then
		action="Already set"
	elif grep -q "$find" "$file"
	then
		action="Overwritten"
		sed -i "s/$find/$replace_escaped/" "$file"
	else
		action="Not found: Added"
		echo -e "\n$replace" >> "$file"
	fi
	echo " ==> Setting $label ($action) [$replace in $file]"
}

function fix_python_exec_path()
{
	for file in /project/bin/*
	do
		if [ ! -f $file ]
		then
			continue
		fi
		find="\#\!/project/bin/python$PYTHON_VERSION"
		find2="\#\!/.*/bin/python"
		find_escaped="${find//\//\\/}"
		find_escaped2="${find2//\//\\/}"
		replace="#!/usr/bin/env python"
		replace_escaped="${replace//\//\\/}"
		sed -i "s/$find_escaped/$replace_escaped/" "$file"
		sed -i "s/$find_escaped2/$replace_escaped/" "$file"
	done
}

if [ ! -d "/project/$CODE_DIR/$APP_NAME" ]
then
	if [ "$BOILERPLATE_ZIP_URL" == "" ] || [ "$BOILERPLATE_ZIP_URL" == "false" ] || [ "$BOILERPLATE_ZIP_URL" == "False" ] || [ "$BOILERPLATE_ZIP_URL" == "0" ]
	then
		/project/bin/django-admin.py startproject $APP_NAME /project/$CODE_DIR
	else
		fix_python_exec_path
		cd /project
		curl \
			--location \
			--url "$BOILERPLATE_ZIP_URL" \
			--output boilerplate.zip

		unzip -d ./boilerplate-extract boilerplate.zip
		rm boilerplate.zip
		mv --no-clobber boilerplate-extract/$(ls boilerplate-extract)/* ./
		mv --no-clobber boilerplate-extract/$(ls boilerplate-extract)/.* ./
		rm --recursive --force ./boilerplate-extract
		rm -f media/.gitkeep

		if [ "$CODE_DIR" != 'src' ] && [ -d "/project/src" ] && [ ! -d "/project/$CODE_DIR" ]
		then
			mv "/project/src" "/project/$CODE_DIR"
		fi

		if [ "$APP_NAME" != 'main' ] && [ -d "/project/$CODE_DIR/main" ] && [ ! -d "/project/$CODE_DIR/$APP_NAME" ]
		then
			mv "/project/$CODE_DIR/main" "/project/$CODE_DIR/$APP_NAME"
		fi

	fi

	if [ ! -d /project/data ]
	then
		mkdir -p /project/data
		echo "*" > /project/data/.gitignore
	fi

	if [ -d /project/media ]
	then
		chmod -R 777 /project/media
	fi

fi

export APPLICATION_ENV="${APPLICATION_ENV:-$ENVIRONMENT}"
if [ "${APPLICATION_ENV:0:3}" == "dev" ]
then
	rm -rf /etc/service/uwsgi
	dev=1
else
	rm -rf /etc/service/runsv
fi

if [ ! -f "/project/bin/python$PYTHON_VERSION" ]
then
	rm -rf /project/bin /project/include
	# Creates ./bin ./include ./lib ./local
	virtualenv /project --python "python$PYTHON_VERSION"
	# Removes ./local
	rm -rf /project/local
fi

echo -e '#!/bin/bash' > /root/.bashrc
echo -e 'export PATH="/project/bin:$PATH"' >> /root/.bashrc
echo -e 'export APPLICATION_ENV="${APPLICATION_ENV:-$ENVIRONMENT}"' >> /root/.bashrc
echo -e 'export VIRTUAL_ENV_DISABLE_PROMPT="1"' >> /root/.bashrc
echo -e 'source /project/bin/activate' >> /root/.bashrc
echo -e 'cd /project' >> /root/.bashrc
chmod +x /project/bin/*
chmod +x /root/.bashrc

find_replace_add_string_to_file "VIRTUAL_ENV=.*" "VIRTUAL_ENV=\"\$PWD\";if [ -d /project ];then VIRTUAL_ENV=\"/project\";fi" /project/bin/activate "Modify activate script"
find_replace_add_string_to_file "if [ ! \$PYTHONPATH ]\nthen\nexport PYTHONPATH=\"/project/\$CODE_DIR\"\nfi" /project/bin/activate
find_replace_add_string_to_file "if [ ! \$DJANGO_SETTINGS_MODULE ]\nthen\nexport DJANGO_SETTINGS_MODULE=\"\$APP_NAME.settings.\$ENVIRONMENT\"\nfi" /project/bin/activate

source /root/.bashrc

requirements_file="/project/requirements.txt"
if [ -f /project/requirements.txt ] && [ $dev ]
then
	requirements_file="/project/requirements_dev.txt"
fi
/project/bin/pip install --upgrade pip
/project/bin/pip install --upgrade --requirement $requirements_file

fix_python_exec_path

if [ ! -d /project/static ]
then
	python /project/$CODE_DIR/manage.py collectstatic --noinput --link
fi

echo "project: $CODE_DIR/$APP_NAME"
