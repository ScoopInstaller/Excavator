#!/bin/bash
export SCOOP="/opt/scoop"
export SCOOP_HOME="/opt/scoop"
export SCOOP_CACHE="/opt/cache"
cd /opt/scoop
powershell ./bin/auto-pr.ps1 -p -s ngrok,curl
cd /opt/scoop-extras
powershell ./bin/auto-pr.ps1 -p
cd /opt/scoop-versions
powershell ./bin/auto-pr.ps1 -p
