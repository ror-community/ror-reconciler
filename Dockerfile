FROM phusion/passenger-full:1.0.12
LABEL maintainer="mfenner@datacite.org"

# Set correct environment variables
ENV HOME /home/app

# Allow app user to read /etc/container_environment
RUN usermod -a -G docker_env app

# Use baseimage-docker's init process
CMD ["/sbin/my_init"]

# Install Ruby 2.6.5
RUN bash -lc 'rvm install ruby-2.6.5'
RUN bash -lc 'rvm --default use ruby-2.6.5'

# Update installed APT packages, clean up when done
RUN apt-get update && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get clean && \
    apt-get install ntp wget unzip tzdata -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable Passenger and Nginx and remove the default site
# Preserve env variables for nginx
RUN rm -f /etc/service/nginx/down && \
    rm /etc/nginx/sites-enabled/default
COPY vendor/docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY vendor/docker/00_app_env.conf /etc/nginx/conf.d/00_app_env.conf
COPY vendor/docker/env.conf /etc/nginx/main.d/env.conf

# Use Amazon NTP servers
COPY vendor/docker/ntp.conf /etc/ntp.conf

# Copy webapp folder
COPY . /home/app/webapp/
RUN mkdir -p /home/app/webapp/vendor/bundle && \
    chown -R app:app /home/app/webapp && \
    chmod -R 755 /home/app/webapp

# enable SSH
RUN rm -f /etc/service/sshd/down && \
    /etc/my_init.d/00_regen_ssh_host_keys.sh

# Install Ruby gems
WORKDIR /home/app/webapp
RUN mkdir -p vendor/bundle && \
    chown -R app:app . && \
    chmod -R 755 . && \
    gem install bundler:2.1.4 && \
    /sbin/setuser app bundle install --path vendor/bundle

# install custom ssh key during startup
RUN mkdir -p /etc/my_init.d
COPY vendor/docker/10_ssh.sh /etc/my_init.d/10_ssh.sh

# Expose web
EXPOSE 80
