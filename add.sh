#!/bin/bash

############################
# Usage:
# File Name: add.sh
# Author: annhe  
# Mail: i@annhe.net
# Created Time: 2018-04-24 18:15:38
############################

if [ "$GOPATH"x == ""x ]; then
	echo "GOPATH error"
	exit 1
fi

BASE_DIR=`echo $GOPATH |cut -f1 -d':'`
DIR="$BASE_DIR/src/k8s.io"
[ ! -d $DIR ] && mkdir $DIR
DIR_INGRESS="$DIR/ingress-nginx"

function init() {
	if [ -d $DIR_INGRESS ];then
		cd $DIR_INGRESS
		git checkout *
		git pull
	else
		cd $DIR && \
		git clone https://github.com/kubernetes/ingress-nginx
	fi
}

function ngxTemplate() {
	location="$DIR_INGRESS/rootfs/etc/nginx/template/nginx.tmpl"
	sed -i 's/^http {/http {\nreq_status_zone letvapp "$proxy_host" 2M;\nreq_status letvapp;\nreq_status_lazy on;\nserver {\nlisten 8000;\nallow 10.0.0.0\/8;\nallow 127.0.0.0\/8;\ndeny all;\nlocation \/reqstat {\nreq_status_show letvapp;\n}\n}\n/g' $location
}

function addModule() {
	location="$DIR_INGRESS/images/nginx/build.sh"
	hash256="42ba47fdfd5c39b3665235ea9e32db26f6673100fe6994af72387bcc38d3f311"
	sed -i -r "s/(^# download, verify and extract the source files)/\1\nget_src $hash256 \"https:\/\/github.com\/annProg\/ngx_http_reqstat\/archive\/v1.0.tar.gz\"\n/g" $location
	sed -i 's/^WITH_MODULES="/WITH_MODULES="--add-module=$BUILD_PATH\/ngx_http_reqstat-1.0 /g' $location
}

function title() {
	RED_COLOR='\E[1;31m'
	RESET='\E[0m'
	echo -e "\n$RED_COLOR========= $1 =========$RESET"
}

function compile() {
	echo -e "\nManual operation the following steps:"
	title "1. Prepare Nginx image"
	echo "cd $DIR_INGRESS/images/nginx"
	echo "ARCH=amd64 TAG=reqstat make container"

	title "2. Prepare golang"
	echo "cd $DIR_INGRESS"
	echo "dep ensure"
	echo "dep ensure -update"

	title "3. Compile ingress-contorller"
	echo "cd $DIR_INGRESS"
	echo "ARCH=amd64 BASEIMAGE=quay.io/kubernetes-ingress-controller/nginx-amd64:reqstat make build container"
}	

init
ngxTemplate
addModule
compile
