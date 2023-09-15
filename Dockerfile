FROM composer:2.4 as image-build
COPY . /app/

FROM php:8.1-apache-buster as dev
RUN apt-get update -y && apt-get install -y libmcrypt-dev

ENV APP_ENV=dev
ENV APP_DEBUG=true
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get update && apt-get install -y zip
RUN docker-php-ext-install pdo pdo_mysql
WORKDIR /app
COPY . /app

COPY . /var/www/html/
COPY --from=image-build /usr/bin/composer /usr/bin/composer
RUN composer install

RUN php artisan key:generate

RUN php artisan config:cache && \
    php artisan route:cache && \
    chmod 777 -R /var/www/html/storage/ && \
    chown -R www-data:www-data /var/www/ && \
    a2enmod rewrite

COPY --from=image-build /app /var/www/html
EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=8000
