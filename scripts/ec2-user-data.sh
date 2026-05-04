#!/bin/bash
# EC2 User Data Script
# Runs on first boot of each instance launched by the Auto Scaling Group.
# Installs Apache, PHP, Composer, the AWS SDK, and deploys the app from S3.

set -euxo pipefail

# variables
S3_BUCKET="project-dev-artifacts-<account-regional-suffix>"
APP_S3_PREFIX="app/"
WEB_ROOT="/var/www/html"

# system updates & packages
dnf update -y
dnf install -y httpd php php-mysqli php-json unzip

# deploys app from S3
aws s3 sync "s3://${S3_BUCKET}/${APP_S3_PREFIX}" "${WEB_ROOT}/"

# AWS SDK for PHP (required by get-parameters.php) installation
cd "${WEB_ROOT}"

# installs Composer
export HOME=/root
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm -f composer-setup.php

# installs the AWS SDK — this generates the autoloader at vendor/autoload.php
composer require aws/aws-sdk-php --no-interaction --no-progress

# fixes permissions
chown -R apache:apache "${WEB_ROOT}"
chmod -R 755 "${WEB_ROOT}"

# enables and starts Apache
systemctl enable httpd
systemctl start httpd
