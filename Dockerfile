FROM debian:bookworm-slim
# Update the list of packages
RUN apt update
# Upgrade the packages
RUN apt -y upgrade

# Install Supervisord so that we can run multiple processes in the docker container
RUN apt -y install supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install NGINX
RUN apt -y install nginx
# Install PHP and the php-mysql package
RUN apt -y install php8.2-fpm php-mysql
# Install Additional PHP Extensions for wordpress
RUN apt -y install php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip php-imagick php-dom php-exif php-igbinary php-mbstring

# Remove the default site configuration files for nginx
RUN unlink /etc/nginx/sites-enabled/default
RUN rm -f /etc/nginx/sites-available/default

# Copy our NGINX Site Configuration File into the image
COPY --chown=www-data:www-data conf/nginx-site.conf /etc/nginx/sites-available/wordpress
RUN ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress

# Download Wordpress
RUN mkdir -p /var/www/wordpress
RUN apt install wget
RUN wget https://wordpress.org/wordpress-6.7.2.tar.gz -O /tmp/wordpress.tar.gz
RUN tar -zxvf /tmp/wordpress.tar.gz -C /var/www

# Wordpress Setup
RUN chown -R www-data:www-data /var/www/wordpress

# Expose port 80 for NGINX
EXPOSE 80

RUN chown -R www-data:www-data /var/www/html

# Set up a volume for wordpress
VOLUME /var/www/wordpress

CMD ["/usr/bin/supervisord"]
