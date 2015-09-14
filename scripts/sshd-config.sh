#!/bin/bash

if [ "${ENVIRONMENT:0:3}" != "dev" ]
then
	rm -rf /etc/service/sshd
	exit 0
fi

rm -rf /etc/service/sshd/down

if [ ! -d /project/ignore ]
then
	mkdir -p /project/ignore
	echo '*' > /project/ignore/.gitignore
fi

ifconfig |
	grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' |
	grep -Eo '([0-9]*\.){3}[0-9]*' |
	grep -v '127.0.0.1' |
	tail -n 1 > /project/ignore/backend-ip.txt

sed -i "s/#Port 22/Port 2222/" /etc/ssh/sshd_config

ssh_key="/project/ignore/ssh-key"
if [ ! -f "$ssh_key.pub" ]
then
	ssh-keygen -q -f $ssh_key -N '' -t rsa
fi

# if [ ! -d /project/bin ]
# then
# 	mkdir /project/bin
# fi
# cp /conf/ssh-backend /project/bin/ssh-backend

if [ ! -d /root/.ssh ]
then
	mkdir /root/.ssh
fi
cat $ssh_key.pub > /root/.ssh/authorized_keys
