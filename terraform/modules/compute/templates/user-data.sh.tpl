#!/bin/bash
set -euxo pipefail

S3_BUCKET="${s3_bucket_name}"
APP_S3_PREFIX="app/"
WEB_ROOT="/var/www/html"

dnf update -y
dnf install -y httpd php php-mysqli php-json unzip

aws s3 sync "s3://$${S3_BUCKET}/$${APP_S3_PREFIX}" "$${WEB_ROOT}/"

cd "$${WEB_ROOT}"

export HOME=/root
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm -f composer-setup.php

composer require aws/aws-sdk-php --no-interaction --no-progress

chown -R apache:apache "$${WEB_ROOT}"
chmod -R 755 "$${WEB_ROOT}"

systemctl enable httpd
systemctl start httpd
