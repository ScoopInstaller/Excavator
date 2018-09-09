#!/bin/bash
. /etc/container_environment.sh

if [ -z "$GIT_USERNAME" ]; then echo 'GIT_USERNAME environment variable is not set!'; exit 1; fi
if [ -z "$GIT_EMAIL" ]; then echo 'GIT_EMAIL environment variable is not set!'; exit 1; fi
if [ -z "$BUCKET" ]; then echo 'BUCKET environment variable is not set!'; exit 1; fi
if [ $METHOD != 'push' ]; then
    if [ -z $UPSTREAM ]; then echo 'UPSTREAM environment variable is not set!'; exit 1; fi
fi

git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

# add github.com to known_hosts and generate private/public key
if [ -z "`grep "$(ssh-keyscan github.com 2>/dev/null)" /root/.ssh/known_hosts`" ]; then
    ssh-keyscan github.com >> /root/.ssh/known_hosts
fi
if [ ! -f /root/.ssh/id_rsa ]; then ssh-keygen -t rsa -b 4096 -C "Excavator-$BUCKET" -f /root/.ssh/id_rsa -N ''; fi

if [ ! -d /root/bucket ]; then
    echo 'Initializing Bucket repository ...'
    git config --global core.autocrlf true
    git clone "https://github.com/$BUCKET" /root/bucket
    cd /root/bucket
    git remote set-url --push origin "git@github.com:$BUCKET.git"
    if [ $METHOD != 'push' ]; then
        git remote add upstream "git@github.com:$UPSTREAM.git"
    fi
fi

echo 'Updating Scoop ...'
cd /root/scoop
git pull

echo 'Cleaning Scoop cache ...'
cd /root/bucket
rm /root/cache/* 2> /dev/null

echo 'Excavating ...'
ARGS=
if [ $METHOD == 'push' ]; then
    ARGS="-p"
else
    ARGS="-r"
fi

if [ ! -z $SNOWFLAKES ]; then
    ARGS="$ARGS -s $SNOWFLAKES"
fi

if [ -f /root/bucket/bin/auto-pr.ps1 ]; then
    pwsh /root/bucket/bin/auto-pr.ps1 $ARGS
fi
if [ -f /root/bucket/bin/bucket-updater.ps1 ]; then
    pwsh /root/bucket/bin/bucket-updater.ps1 $ARGS
fi
