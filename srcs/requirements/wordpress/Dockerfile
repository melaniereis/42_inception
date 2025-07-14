# Use the official PHP with Apache image as the base image

FROM php:7.4-Apache

# Install required packages
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache modules
RUN a2enmod rewrite

# Copy the content of WordPress
RUN curl
