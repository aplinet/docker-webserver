FROM ubuntu:bionic
ENV TZ=Europe/Warsaw
ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_INI_DIR=/etc/php/7.2/fpm
ENV PHP_CLI_INI_DIR=/etc/php/7.2/cli

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update
# Install locales
RUN apt-get install locales \
&& locale-gen pl_PL \
&& locale-gen pl_PL.UTF-8 
ENV LANG="pl_PL.UTF-8"
ENV LANGUAGE="pl_PL"
ENV LC_ALL="pl_PL.UTF-8"
RUN update-locale LANG=pl_PL.UTF-8 \
&& update-locale LC_ALL=pl_PL.UTF-8 \
&& update-locale \
&& dpkg-reconfigure locales
# Install fonts
RUN apt-get install -yq fonts-open-sans
# Install jdk 8
RUN apt-get install -yq openjdk-8-jdk
# Install php 7.2
RUN apt-get install -yq php7.2-fpm \
 php7.2-bcmath \
 php7.2-bz2 \
 php7.2-intl \
 php7.2-gd \
 php7.2-mbstring \
 php7.2-mysql \
 php7.2-zip \
 php7.2-pgsql \
 php7.2-xml \
 php7.2-gmp \
 php7.2-exif \
 php7.2-opcache \
 php7.2-cli \
 php7.2-xdebug
COPY 30-timezone.ini $PHP_INI_DIR/conf.d/ 
COPY 30-xdebug.ini $PHP_INI_DIR/conf.d/  
COPY 30-php-add.ini $PHP_INI_DIR/conf.d/  
COPY 30-timezone.ini $PHP_CLI_INI_DIR/conf.d/ 
COPY 30-xdebug.ini $PHP_CLI_INI_DIR/conf.d/  
COPY 30-php-add.ini $PHP_CLI_INI_DIR/conf.d/  
COPY www.conf /etc/php/7.2/fpm/pool.d/
COPY php.ini /etc/php/7.2/fpm/php.ini

# Install nginx
RUN apt-get install -yq nginx
COPY nginx-laravel /etc/nginx/sites-available/ 
COPY nginx.conf /etc/nginx/
RUN ln -s /etc/nginx/sites-available/nginx-laravel /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-enabled/default
# Install common tools
RUN apt-get install -yq software-properties-common
RUN add-apt-repository ppa:xapienz/curl34 && apt-get update
RUN apt-get install -yq vim wget curl zip git zsh
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# Add user for laravel application
RUN groupadd -g 6123 www \
 && useradd -u 1000 -ms /bin/bash -g www www \
 && mkdir -m775 /run/php && chown -R www:www /run/php \
 && usermod -s /bin/zsh www \
 && cd /home/www && git clone https://github.com/ohmyzsh/ohmyzsh.git .oh-my-zsh \
 && git clone https://github.com/zsh-users/zsh-autosuggestions /home/www/.oh-my-zsh/plugins/zsh-autosuggestions
COPY .zshrc /home/www/
RUN chown -R www:www /home/www/.oh-my-zsh && chown www:www /home/www/.zshrc && chmod 775 /home/www/.zshrc
ENV NODE_VERSION 10
ENV NVM_DIR /usr/local/nvm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash \
    && mkdir -p $NVM_DIR/versions \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
ENV DEBIAN_FRONTEND=interactive
WORKDIR /var/www/html
ENTRYPOINT service php7.2-fpm restart && service nginx restart && /bin/zsh




