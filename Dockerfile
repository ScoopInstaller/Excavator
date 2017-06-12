FROM phusion/baseimage:latest

LABEL org.label-schema.maintainer="Richard Kuhnt <r15ch13+git@gmail.com>" \
      org.label-schema.description="This container runs the updating services for all scoop manifest repos" \
      org.label-schema.url="https://github.com/lukesampson/scoop" \
      org.label-schema.vcs-url="https://github.com/r15ch13/scoop-updater" \
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
ENV LANG en_US.UTF-8
ENV LC_ALL $LANG
RUN locale-gen $LANG && update-locale

# Import the public repository GPG keys for Microsoft
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# Register the Microsoft Ubuntu 16.04 repository
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/microsoft.list

# Install powershell from Microsoft Repo
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
	powershell \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose ssh volume
RUN mkdir -p /root/.ssh/
VOLUME /root/.ssh

# Clone scoop repos
RUN git config --global core.autocrlf true
RUN git clone https://github.com/lukesampson/scoop /opt/scoop
RUN git clone https://github.com/lukesampson/scoop-extras /opt/scoop-extras
RUN git clone https://github.com/scoopinstaller/versions /opt/scoop-versions
RUN cd /opt/scoop && git remote set-url --push origin git@github.com:lukesampson/scoop.git
RUN cd /opt/scoop-extras && git remote set-url --push origin git@github.com:lukesampson/scoop-extras.git
RUN cd /opt/scoop-versions && git remote set-url --push origin git@github.com:scoopinstaller/versions.git

# Install cronjob
ADD updater.sh /opt/updater.sh
RUN chmod +x /opt/updater.sh
RUN echo "0 * * * * root sh /opt/updater.sh > /opt/log.txt" >> /etc/crontab

# Install hub
RUN curl -LO https://github.com/github/hub/releases/download/v2.2.9/hub-linux-amd64-2.2.9.tgz
RUN tar zxvvf hub-linux-amd64-2.2.9.tgz
RUN ./hub-linux-amd64-2.2.9/install
