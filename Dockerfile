FROM php:7.4-fpm

#Obtendo os argumentos enviados pelo arquivo docker-compose
ARG user
ARG uid

#Instalação de dependências
RUN apt update && apt install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

#Limpeza do cache
RUN apt clean && apt autoclean && apt autoremove && rm -rf /var/lib/apt/lists/*

#Instalação das extensões do PHP
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    sockets

#Instalação do Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

#Criação de usuário no sistema para utilizar os comandos do Composer e Artisan
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

#Instalação do Redis
RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

#Configurando o diretório de trabalho
WORKDIR /var/www

#Indicando qual usuário vai executar o container
USER $user
