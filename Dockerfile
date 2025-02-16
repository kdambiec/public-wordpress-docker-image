FROM debian:bookworm-slim
# Update the list of packages
RUN apt update
# Upgrade the packages
RUN apt -y upgrade

# Install Supervisord so that we can run multiple processes in the docker container
RUN apt -y install supervisor
RUN mkdir -p /var/log/supervisor
# Copy the supervisord configuration into the docker image
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install NGINX
RUN apt -y install nginx
# Install PHP and the php-mysql package
RUN apt -y install php8.2-fpm php-mysql
# Install Additional PHP Extensions for wordpress
RUN apt -y install php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip

# Remove the default site configuration files for nginx
RUN unlink /etc/nginx/sites-enabled/default
RUN rm -f /etc/nginx/sites-available/default

# Copy our NGINX Site Configuration File into the image
COPY --chown=www-data:www-data conf/nginx-site.conf /etc/nginx/sites-available/wordpress
RUN ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress

# Download Wordpress
RUN mkdir -p /var/www/wordpress
RUN apt -y install wget
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
RUN tar -zxvf /tmp/wordpress.tar.gz -C /var/www

# Set the owner of the wordpress files to www-data
RUN chown -R www-data:www-data /var/www/wordpress

# Install MariaDB
RUN apt install -y mariadb-server

RUN mkdir -p /var/run/mysqld && \
    chown root:mysql /var/run/mysqld && \
    chmod 774 /var/run/mysqld

# Some Cleanup
RUN apt -y remove wget
RUN apt -y clean

# Expose port 80 for NGINX
EXPOSE 80

# Set up two volumes for wordpress and mariadb
VOLUME /var/www/wordpress
VOLUME /var/lib/mysql

CMD ["/usr/bin/supervisord"]