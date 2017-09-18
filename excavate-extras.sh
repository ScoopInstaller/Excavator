#!/bin/bash
export SCOOP="/opt/scoop"
export SCOOP_HOME="/opt/scoop"
export SCOOP_CACHE="/opt/cache"
git config --global user.name "`cat /etc/container_environment/GIT_USERNAME`"
git config --global user.email "`cat /etc/container_environment/GIT_EMAIL`"
cd /opt/scoop-extras
powershell ./bin/auto-pr.ps1 -p
rm /opt/cache/* 2> /dev/null
