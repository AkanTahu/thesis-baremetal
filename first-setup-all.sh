#!/bin/bash
USER="$(whoami)"
set -e

# 1. Update sistem & install git
sudo apt update
sudo apt install -y git

# 2. Tambahkan PPA PHP dan install PHP + extension yang dibutuhkan Laravel
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install -y php8.1 php8.1-fpm php8.1-cli php8.1-common php8.1-dev php-pear \
    php8.1-mbstring php8.1-xml php8.1-bcmath php8.1-zip php8.1-curl php8.1-gd php8.1-mysql

# 3. Install dependency lain (build-essential, library gambar, dsb)
sudo apt install -y build-essential libpng-dev libjpeg-turbo8-dev libfreetype6-dev zip unzip curl \
    libonig-dev libzip-dev nodejs npm mariadb-client nginx

# 4. Install Composer (PHP dependency manager)
EXPECTED_SIGNATURE="$(curl -s https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    >&2 echo 'ERROR: Invalid composer installer signature'
    rm composer-setup.php
    exit 1
fi
php composer-setup.php --quiet
sudo mv composer.phar /usr/local/bin/composer
rm composer-setup.php

# 5. Install nvm dan Node.js LTS (untuk Laravel Mix, dsb)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

# 6. Install MariaDB Server (MySQL compatible)
sudo apt install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb

# 7. Install Nginx
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# 8. Install Imagick untuk PHP
sudo apt install -y libmagickwand-dev
sudo pecl install imagick
echo "extension=imagick.so" | sudo tee /etc/php/8.1/mods-available/imagick.ini
sudo phpenmod imagick
sudo systemctl restart php8.1-fpm

# 9. Install Python 3.9 dan pip
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.9 python3.9-venv python3.9-dev python3.9-distutils
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9

# 10. Git clone project thesis-baremetal
git clone https://github.com/AkanTahu/thesis-baremetal.git

sudo chmod o+x /home
sudo chmod o+x /home/$USER
sudo chown -R $USER:www-data /home/$USER/thesis-baremetal/rekachain-web/public
sudo chown -R www-data:www-data /home/$USER/thesis-baremetal/rekachain-web/storage
sudo chown -R www-data:www-data /home/$USER/thesis-baremetal/rekachain-web/bootstrap/cache
sudo chmod -R 775 /home/$USER/thesis-baremetal/rekachain-web/storage
sudo chmod -R 775 /home/$USER/thesis-baremetal/rekachain-web/bootstrap/cache

sudo chmod +x /home/$USER/thesis-baremetal/rekachain-web/first-setup.sh
sudo chown -R $USER:www-data /home/$USER/thesis-baremetal/rekachain-web

sudo chown -R www-data:www-data /home/$USER/thesis-baremetal/shared-storage
sudo chmod -R 775 /home/$USER/thesis-baremetal/shared-storage

sudo /home/$USER/first-setup-python.sh


echo "=== SETUP SELESAI ==="
echo "Project sudah di-clone ke folder thesis-baremetal"
echo "Lanjutkan dengan setup Laravel & Python di folder tersebut sesuai kebutuhan."

