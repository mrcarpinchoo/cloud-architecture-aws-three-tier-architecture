#!/bin/bash
# Database Import Script
# Run this from the bastion host to populate the RDS countries database.
# Requires: LabInstanceProfile attached to the bastion, RDS instance running, S3 bucket accessible.

set -euxo pipefail

S3_BUCKET=$(
  aws s3api list-buckets \
    --query "Buckets[?starts_with(Name, 'project-dev-artifacts')].Name" \
    --output text
)
DUMP_FILE="countries.sql"

# installs MySQL client
sudo dnf install -y mariadb105

# downloads dump file from S3
aws s3 cp "s3://${S3_BUCKET}/${DUMP_FILE}" .

# retrieves RDS credentials from Secrets Manager
SECRET_ARN=$(
  aws secretsmanager list-secrets \
    --filters Key=name,Values=rds! \
    --query "SecretList[0].ARN" \
    --output text
)

SECRET=$(
  aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --query SecretString \
    --output text
)

USER=$(echo "$SECRET" | python3 -c "import json,sys; print(json.load(sys.stdin)['username'])")
PASSWORD=$(echo "$SECRET" | python3 -c "import json,sys; print(json.load(sys.stdin)['password'])")

# retrieves RDS endpoint
RDS_ENDPOINT=$(
  aws rds describe-db-instances \
    --query "DBInstances[0].Endpoint.Address" \
    --output text
)

# imports the dump
mysql -h "$RDS_ENDPOINT" -u "$USER" -p"$PASSWORD" countries < "$DUMP_FILE"

# verifies the import
mysql -h "$RDS_ENDPOINT" -u "$USER" -p"$PASSWORD" countries \
  -e "SELECT COUNT(*) FROM countrydata_final;"
