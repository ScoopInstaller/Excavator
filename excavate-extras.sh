#!/bin/bash
export SCOOP="/opt/scoop"
export SCOOP_HOME="/opt/scoop"
export SCOOP_CACHE="/opt/cache/extras"
git config --global user.name "`cat /etc/container_environment/GIT_USERNAME`"
git config --global user.email "`cat /etc/container_environment/GIT_EMAIL`"
cd /opt/scoop-extras
rm /opt/cache/extras/* 2> /dev/null
pwsh ./bin/auto-pr.ps1 -p
