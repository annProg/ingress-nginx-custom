#!/bin/bash

############################
# Usage:
# File Name: add.sh
# Author: annhe  
# Mail: i@annhe.net
# Created Time: 2018-04-24 18:15:38
############################

function init() {
	if [ -d ingress-nginx ];then
		cd ingress-nginx
		git checkout *
		git pull
		cd ../
	else
		git clone https://github.com/kubernetes/ingress-nginx
	fi
}

function ngxTemplate() {
	location="ingress-nginx/rootfs/etc/nginx/template/nginx.tmpl"
	sed -i 's/^http {/http {\nreq_status_zone letvapp "$proxy_host" 2M;\nreq_status letvapp;\nreq_status_lazy on;\n/g' $location
	sed -i 's/## start server /server {\nlisten 8000;\nallow 10.0.0.0\/8;\nallow 127.0.0.0\/8;\ndeny all;\nlocation \/reqstat {\nreq_status_show letvapp;\n}\n}\n## start server /g' $location
}

function addModule() {
	location="ingress-nginx/images/nginx/build.sh"
	hash256="96ac3dee89dc85dbd97e414e5c91be4bc6fc36e4dbaba53b09b4fa02874fd117"
	sed -i -r "s/(^# download, verify and extract the source files)/\1\nget_src 96ac3dee89dc85dbd97e414e5c91be4bc6fc36e4dbaba53b09b4fa02874fd117 \"https:\/\/github.com\/annProg\/ngx_http_reqstat\/archive\/v1.0.tar.gz\"\n/g" $location
	sed -i 's/^WITH_MODULES="/WITH_MODULES="--add-module=$BUILD_PATH\/ngx_http_reqstat-master /g' $location
}

init
ngxTemplate
addModule
