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

init
ngxTemplate
