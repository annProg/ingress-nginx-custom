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
		git checkout nginx-0.20.0
	else
		cd $DIR && \
		git clone https://github.com/kubernetes/ingress-nginx
		cd ingress-nginx
		git checkout nginx-0.20.0
	fi

	# fix Makefile
	sed -i 's/--no-cache --pull/--no-cache/g' Makefile
}

function addModule() {
	location="$DIR_INGRESS/images/nginx/rootfs/build.sh"
	hash256="ce93155f924fabb17f8f8cead25f6c10f3996a7652c86a74e15a937f8af44d00"
	sed -i -r "s/(^# download, verify and extract the source files)/\1\nget_src $hash256 \"https:\/\/github.com\/annProg\/ngx_http_reqstat\/archive\/v1.1.tar.gz\"\n/g" $location
	sed -i 's/^WITH_MODULES="/WITH_MODULES="--add-module=$BUILD_PATH\/ngx_http_reqstat-1.1 /g' $location
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
addModule
compile
