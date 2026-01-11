FROM php:8.3-cli-alpine

# Install system dependencies
RUN apk add --no-cache \
    git \
    unzip \
    && docker-php-ext-install -j$(nproc) opcache \
    && docker-php-ext-enable opcache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR .

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install dependencies (production only)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy application code
COPY . .

# Expose port (Render will set PORT env variable)
EXPOSE 8080

# Start the server
CMD ["php", "server.php"]
