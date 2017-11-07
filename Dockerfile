FROM phusion/baseimage:latest

LABEL org.label-schema.maintainer="Richard Kuhnt <r15ch13+git@gmail.com>" \
      org.label-schema.description="This container runs the updating services for all Scoop buckets" \
      org.label-schema.url="https://github.com/lukesampson/scoop" \
      org.label-schema.vcs-url="https://github.com/r15ch13/excavator" \
      org.label-schema.schema-version="1.0.0-rc1"

CMD ["/sbin/my_init"]

# Install dependencies and clean up
RUN apt-get update \
    && apt-get install -y \
        apt-utils \
        ca-certificates \
        curl \
        apt-transport-https \
        git \
        locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup the locale
ENV GIT_USERNAME=
ENV GIT_EMAIL=
ENV LANG=en_US.UTF-8
ENV LC_ALL=$LANG
RUN locale-gen $LANG && update-locale

# Import the public repository GPG keys for Microsoft
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# Register the Microsoft Ubuntu 16.04 repository
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/microsoft.list

# Install cronjob
ADD excavate*.sh /opt/
RUN chmod +x /opt/excavate*.sh \
    && echo "0 * * * * root sh /opt/excavate.sh > /opt/log/main.log 2>&1" >> /etc/crontab \
    && echo "0 * * * * root sh /opt/excavate-extras.sh > /opt/log/extras.log 2>&1" >> /etc/crontab \
    && echo "0 * * * * root sh /opt/excavate-versions.sh > /opt/log/versions.log 2>&1" >> /etc/crontab

# Install hub
RUN curl -LO https://github.com/github/hub/releases/download/v2.2.9/hub-linux-amd64-2.2.9.tgz \
    && tar zxvvf hub-linux-amd64-2.2.9.tgz \
    && ./hub-linux-amd64-2.2.9/install \
    && rm hub-linux-amd64-2.2.9.tgz \
    && rm -rf hub-linux-amd64-2.2.9/*

# Install powershell from Microsoft Repo
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    powershell \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create required directories
RUN mkdir -p /root/.ssh \
    && mkdir -p /root/.config/powershell \
    && mkdir -p /opt/cache/main \
    && mkdir -p /opt/cache/extras \
    && mkdir -p /opt/cache/versions \
    && mkdir -p /opt/log

# add github.com to known_hosts and generate private/public key
RUN if ! grep "$(ssh-keyscan github.com 2>/dev/null)" /root/.ssh/known_hosts > /dev/null; then ssh-keyscan github.com >> /root/.ssh/known_hosts; fi
RUN [ -f "/root/.ssh/id_rsa" ] || ssh-keygen -t rsa -b 4096 -C "scoop-excavator" -f /root/.ssh/id_rsa -N ""

# Expose ssh volume
VOLUME /root/.ssh /opt/log

# Clone scoop repos and configure git remotes
RUN git config --global core.autocrlf true \
    && git clone https://github.com/lukesampson/scoop /opt/scoop \
    && cd /opt/scoop && git remote set-url --push origin git@github.com:lukesampson/scoop.git \
    && git clone https://github.com/lukesampson/scoop-extras /opt/scoop-extras \
    && cd /opt/scoop-extras && git remote set-url --push origin git@github.com:lukesampson/scoop-extras.git \
    && git clone https://github.com/scoopinstaller/versions /opt/scoop-versions \
    && cd /opt/scoop-versions && git remote set-url --push origin git@github.com:scoopinstaller/versions.git

# Add scoop environment variables to powershell profile
RUN echo '$env:SCOOP="/opt/scoop"' > /root/.config/powershell/profile.ps1 \
    && echo '$env:SCOOP_HOME="/opt/scoop"' >>/root/.config/powershell/profile.ps1 \
    && echo '$env:SCOOP_CACHE="/opt/cache"' >> /root/.config/powershell/profile.ps1
