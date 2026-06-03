#!/bin/bash

set -e

if hash yum 2>/dev/null; then
 PACKAGE_MGR="yum"
elif hash zypper 2>/dev/null; then
 PACKAGE_MGR="zypper"
elif hash rpm 2>/dev/null; then
 PACKAGE_MGR="rpm"
else
 PACKAGE_MGR="apt_get"
fi
echo "Installing packages with $PACKAGE_MGR"

case "$PACKAGE_MGR" in
	"yum" )
		yum -y update
		yum -y install yum-utils wget unzip curl jq
		;;
	"rpm" )
		echo "Installed nothing via rpm"
		;;
	"zypper" )
		zypper refresh && \
		zypper -n install wget unzip curl jq && \
		zypper clean -a
		;;
	"apt_get" )
		/fix-debian-repos.sh
		apt-get update
		apt-get install -y --no-install-recommends unzip ca-certificates
		rm -rf /var/lib/apt/lists/*
		;;
esac
