FROM php:8.1-apache-buster as dev
RUN apt-get update -y && apt-get install -y libmcrypt-dev

ENV APP_ENV=dev
ENV APP_DEBUG=true
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update && apt-get install -y zip
RUN docker-php-ext-install pdo pdo_mysql
COPY . /app/

COPY . /var/www/html/
RUN composer install

RUN php artisan config:cache && \
    php artisan route:cache && \
    chmod 777 -R /var/www/html/storage/ && \
    chown -R www-data:www-data /var/www/ && \
    a2enmod rewrite

EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=8000
