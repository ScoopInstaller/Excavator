FROM phusion/baseimage:latest

LABEL org.label-schema.maintainer="Richard Kuhnt <r15ch13+git@gmail.com>" \
      org.label-schema.description="Base image for Scoop update services" \
      org.label-schema.url="https://github.com/lukesampson/scoop" \
      org.label-schema.vcs-url="https://github.com/r15ch13/excavator" \
      org.label-schema.schema-version="1.0.0-rc1"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ARG HUB_VERSION=2.5.1
ARG POWERSHELL_BUILD=16.04

# Create required directories
RUN mkdir -p /root/.ssh \
    && mkdir -p /root/.config/powershell \
    && mkdir -p /root/cache \
    && mkdir -p /root/log

# Expose ssh and log volume
VOLUME /root/.ssh /root/log

# Expose environment variables
ENV GIT_USERNAME=
ENV GIT_EMAIL=
ENV SNOWFLAKES=
ENV BUCKET=
ENV CRONTAB="0 * * * *"
ENV METHOD=push
ENV UPSTREAM=

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
RUN curl -LO https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz \
    && tar zxvvf hub-linux-amd64-${HUB_VERSION}.tgz \
    && ./hub-linux-amd64-${HUB_VERSION}/install \
    && rm hub-linux-amd64-${HUB_VERSION}.tgz \
    && rm -rf hub-linux-amd64-${HUB_VERSION}/*

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
    && echo "$CRONTAB root /bin/bash /root/excavate.sh > /root/log/mud.log 2>&1" >> /etc/crontab
