#!/bin/sh
set -e

# env
SUPER_ADMIN_NAME=${SUPER_ADMIN_NAME:-"user"}
SUPER_ADMIN_PWD=${SUPER_ADMIN_PWD:-"123456"}
CONFIG_DIR=${CONFIG_DIR:-"config"}

STATIC=${STATIC:-true}
DYNAMIC=${DYNAMIC:-true}
SCRAPY=${SCRAPY:-false}
CHROME=${CHROME:-false}

# install packges

echo "***** Start to install an optional dependency packages *****"

apk update

# requests
if [ $STATIC = true ]; then
	echo "***** Starting install requests *****"
	pip install requests
	echo "***** Installed requests *****"
fi

if [ $DYNAMIC = true ]; then
	# selenium
	echo "***** Starting install selenium *****"
	pip install selenium
	echo "***** Installed selenium *****"

	# firefox
	echo "***** Starting install firefox *****"
	apk add dbus-x11 ttf-freefont firefox-esr
	echo "***** Installed firefox *****"

	if [ $CHROME = true ]; then
		# chrome
		echo "***** Starting install chrome and chromedriver *****"
		apk add libexif udev chromium chromium-chromedriver
		echo "***** Installed chrome and chromedriver *****"
	fi

	# firefox and chrome depedent display
	echo "***** Starting install pydisplay *****"
	apk add xvfb
	pip install pyvirtualdisplay
	echo "***** Installed pydisplay *****"

fi

if [ $SCRAPY = true ]; then
	# scrapy
	echo "***** Starting install Scrapy *****"
	apk add gcc musl-dev libgcc openssl-dev libxml2-dev libxslt-dev libffi-dev libxml2 libxslt
	pip install Scrapy
	echo "***** Installed Scrapy *****"
fi

rm -rf /var/cache/apk/*

echo "***** Install end *****"

# setting configs

super_file="/etc/supervisor/supervisord.conf"
if [ -f "$super_file" ]; then
	echo "***** Saveing user authentication to file $super_file *****"

	cat << EOF >> $super_file
username=${SUPER_ADMIN_NAME}
password=${SUPER_ADMIN_PWD}

[include]
files = /etc/supervisor/conf.d/*.conf /app/${CONFIG_DIR}/*.conf
EOF

else
	echo "***** Don't have file $super_file *****"
fi

echo "***** Done *****"
exec "$@"