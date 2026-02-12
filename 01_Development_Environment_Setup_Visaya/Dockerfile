FROM php:8.3-apache

# 1. Install system dependencies
# We combine these into one RUN to keep the image small
RUN apt-get update && apt-get install -y \
    zip \
    mariadb-client \
    npm \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# 2. Install PHP extensions
RUN docker-php-ext-install \
    bcmath \
    ctype \
    pdo \
    pdo_mysql \
    sockets

# 3. Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# 4. Enable Apache mod_rewrite (needed for Laravel routes)
RUN a2enmod rewrite

# 5. Install NVM and Node.js LTS
ENV NVM_DIR /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install --lts \
    && nvm use --lts

# 6. Set working directory
WORKDIR /var/www/html