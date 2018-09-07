#!/bin/bash
export SCOOP="/opt/scoop"
export SCOOP_HOME="/opt/scoop"
export SCOOP_CACHE="/opt/cache/main"
git config --global user.name "`cat /etc/container_environment/GIT_USERNAME`"
git config --global user.email "`cat /etc/container_environment/GIT_EMAIL`"
cd /opt/scoop
rm /opt/cache/main/* 2> /dev/null
pwsh ./bin/auto-pr.ps1 -p -s curl,openssl,brotli
