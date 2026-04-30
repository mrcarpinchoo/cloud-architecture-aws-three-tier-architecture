#!/bin/bash
# EC2 User Data Script
# Runs on first boot of each instance launched by the Auto Scaling Group.
# Installs Apache, PHP, the AWS SDK, and deploys the app from S3.

set -euxo pipefail

# Variables
S3_BUCKET="project-app-artifacts"
APP_S3_PREFIX="app/"
WEB_ROOT="/var/www/html"

# System updates & packages
yum update -y
yum install -y httpd php php-mysqli php-json curl unzip

# Deploy app from S3
# The EC2 IAM role must have s3:GetObject / s3:ListBucket on the bucket.
aws s3 sync "s3://${S3_BUCKET}/${APP_S3_PREFIX}" "${WEB_ROOT}/"

# Install AWS SDK for PHP (required by get-parameters.php)
cd "${WEB_ROOT}"

# Install Composer (PHP dependency manager)
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm -f composer-setup.php

# Install the AWS SDK — this generates aws-autoloader.php
composer require aws/aws-sdk-php --no-interaction --no-progress

# Fix permissions
chown -R apache:apache "${WEB_ROOT}"
chmod -R 755 "${WEB_ROOT}"

# Enable and start Apache
systemctl enable httpd
systemctl start httpd
