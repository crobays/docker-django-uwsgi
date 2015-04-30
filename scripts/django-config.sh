#!/bin/bash

function find_replace_add_string_to_file() {
	find="$1"
	replace="$2"
	replace_escaped="${2//\//\\/}"
	file="$3"
	label="$4"
	if grep -q ";$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
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
		action="Added"
		echo -e "\n$replace\n" >> "$file"
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

# install django, normally you would remove this step because your project would already
# be installed in the code/app/ directory

if [ ! -d /project ]
then
	mkdir -p /project
fi

export APPLICATION_ENV="${APPLICATION_ENV:-$ENVIRONMENT}"
if [ "${APPLICATION_ENV:0:3}" == "dev" ]
then
	rm -rf /etc/service/uwsgi
else
	rm -rf /etc/service/runsv
fi

if [ ! -f /project/requirements.txt ]
then
	cp /conf/requirements.txt /project/requirements.txt
fi

virtualenv /project --python "python$PYTHON_VERSION"
rm -rf /project/local
fix_python_exec_path

echo -e '#!/bin/bash' > /root/.bashrc
echo -e 'export PATH="/project/bin:$PATH"' >> /root/.bashrc
echo -e 'export APPLICATION_ENV="${APPLICATION_ENV:-$ENVIRONMENT}"' >> /root/.bashrc
echo -e 'source /project/bin/activate' >> /root/.bashrc
chmod +x /project/bin/*
chmod +x /root/.bashrc

find_replace_add_string_to_file "VIRTUAL_ENV=.*" "VIRTUAL_ENV=\"\$PWD\";if [ -d /project ];then VIRTUAL_ENV=\"/project\";fi" /project/bin/activate "Modify activate script"

source /root/.bashrc
/project/bin/pip install -r /project/requirements.txt
fix_python_exec_path

if [ ! -d /project/$CODE_DIR ]
then
	if [ "$CUSTOM_BOILERPLATE" == "false" ] || [ "$CUSTOM_BOILERPLATE" == "False" ] || [ "$CUSTOM_BOILERPLATE" == "0" ]
	then
		mkdir -p /project/$CODE_DIR
		/project/bin/django-admin.py startproject $PROJECT_NAME /project/$CODE_DIR
	else
		cp --recursive /conf/project-boilerplate /project/$CODE_DIR
		fix_python_exec_path

		if [ $TIMEZONE ] && [ -f /project/$CODE_DIR/$PROJECT_NAME/settings/base.py ]
		then
			find_replace_add_string_to_file "TIME_ZONE = .*" "TIME_ZONE = '$TIMEZONE'" /project/$CODE_DIR/$PROJECT_NAME/settings/base.py "Set $PROJECT_NAME/settings/base Timezone"
		fi

		if [ $TIMEZONE ] && [ -f /project/$CODE_DIR/$PROJECT_NAME/settings/base.py ]
		then
			secret="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)"
			find_replace_add_string_to_file "SECRET_KEY = 'secret'" "SECRET_KEY = '$secret'" /project/$CODE_DIR/$PROJECT_NAME/settings/base.py "Set $PROJECT_NAME/settings/base Secret"
		fi
	fi
	mkdir /project/$CODE_DIR/templates
fi

# if [ ! -d /project/$CODE_DIR/$PROJECT_NAME/$APP_NAME ]
# then
# 	if [ $APP_TEMPLATE ]
# 	then
# 		template="--template=$APP_TEMPLATE"
# 	fi
# 	/project/bin/django-admin.py startapp $template $APP_NAME /project/$CODE_DIR/$PROJECT_NAME
# 	fix_python_exec_path
# fi

echo "code directory: $CODE_DIR"
echo "project: $CODE_DIR/$PROJECT_NAME"



if [ ! -d /project/static/admin ]
then
	mkdir -p /project/static
	python_dir=$(ls -r /project/lib | head -n 1)
	if [ -d /project/lib/$python_dir/site-packages/django/contrib/admin/static/admin ]
	then
		cp -r /project/lib/$python_dir/site-packages/django/contrib/admin/static/admin /project/static/admin
	else
		echo "No static files for admin found: /project/lib/$python_dir/site-packages/django/contrib/admin/static/admin"
	fi
fi

env
