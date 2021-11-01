FROM phusion/baseimage:focal-1.1.0

LABEL org.label-schema.maintainer="Richard Kuhnt <r15ch13+git@gmail.com>" \
      org.label-schema.description="Base image for Scoop update services" \
      org.label-schema.url="https://github.com/lukesampson/scoop" \
      org.label-schema.vcs-url="https://github.com/scoopinstaller/excavator" \
      org.label-schema.schema-version="1.0.0-rc1"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ARG POWERSHELL_BUILD=20.04

# Create required directories
RUN mkdir -p /root/.ssh \
    && mkdir -p /root/.config/powershell \
    && mkdir -p /root/cache \
    && mkdir -p /root/log

# Expose ssh and log volume
VOLUME /root/.ssh /root/log

# Expose environment variables
ENV GIT_USERNAME= \
    GIT_EMAIL= \
    SNOWFLAKES= \
    BUCKET= \
    CRONTAB="0 * * * *" \
    METHOD=push \
    UPSTREAM=

# Download the Microsoft repository GPG keys
RUN curl -L -O https://packages.microsoft.com/config/ubuntu/${POWERSHELL_BUILD}/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
RUN dpkg -i packages-microsoft-prod.deb

# Install dependencies and clean up
RUN apt-get update \
    # && apt-get upgrade -y \
    && apt-cache search powershell \
    && apt-get install -y --no-install-recommends \
        git \
        powershell \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install hub
ADD Get-Hub.ps1 /
RUN pwsh -NoProfile ./Get-Hub.ps1
RUN tar -xvf hub-linux-amd64.tgz --strip-components 2 --directory=/usr/bin --wildcards 'hub-linux-amd64-*/bin/hub' \
    && rm hub-linux-amd64.tgz Get-Hub.ps1

# Clone Scoops main repository
RUN git config --global core.autocrlf true \
    && git clone https://github.com/lukesampson/scoop /root/scoop --depth=1

# Add fixed Scoop environment variables
RUN echo '/root/scoop' > /etc/container_environment/SCOOP \
    && echo '/root/scoop' > /etc/container_environment/SCOOP_HOME \
    && echo '/root/cache' > /etc/container_environment/SCOOP_CACHE

# Install cronjob
ADD excavate.sh /root/
RUN chmod +x /root/excavate.sh \
    && echo "$CRONTAB root /bin/bash /root/excavate.sh > /root/log/mud-\$(date +\"\%Y\%m\%d-\%H\%M\%S\").log" > /etc/cron.d/excavator
