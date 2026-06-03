#!/bin/bash
# Debian Buster (openjdk:11.0.7-slim) repos moved to archive.debian.org
if [ -f /etc/apt/sources.list ]; then
	sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list
	sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list
	echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until
fi
