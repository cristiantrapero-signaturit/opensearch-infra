#!/bin/sh

# This script sets the SSM parameters for the Opensearch deployment.
# Install apache2-utils for hash the passwords
command -v htpasswd >/dev/null || sudo apt install apache2-utils

echo "Please set the following parameters:\n"
echo -n "ACCESS KEY ID: ";
read ACCESS_KEY_ID;
echo -n "SECRET ACCESS KEY: ";
read SECRET_ACCESS_KEY;
echo -n "OPENSEARCH ADMIN PASSWORD: ";
read ADMIN_PASSWORD;
ADMIN_PASSWORD_HASHED=$(htpasswd -bnBC 10 "" $ADMIN_PASSWORD | tr -d ':\n')

echo -n "OPENSEARCH DASHBOARD PASSWORD: ";
read DASHBOARD_PASSWORD;
DASHBOARD_PASSWORD_HASHED=$(htpasswd -bnBC 10 "" $DASHBOARD_PASSWORD | tr -d ':\n')

echo "================= SSM PARAMETERS ======================="
echo ACCESS_KEY_ID: ${ACCESS_KEY_ID}
echo SECRET_ACCESS_KEY: ${SECRET_ACCESS_KEY}
echo ADMIN_PASSWORD: ${ADMIN_PASSWORD}
echo ADMIN_PASSWORD_HASHED: ${ADMIN_PASSWORD_HASHED}
echo DASHBOARD_PASSWORD: ${DASHBOARD_PASSWORD}
echo DASHBOARD_PASSWORD_HASHED: ${DASHBOARD_PASSWORD_HASHED}

echo "\nAdding access_key_id to SSM..."
aws ssm put-parameter --region eu-west-1 --name access_key_id --value ${ACCESS_KEY_ID} --type "SecureString" --overwrite
echo "Adding secret_access_key to SSM..."
aws ssm put-parameter --region eu-west-1 --name secret_access_key --value ${SECRET_ACCESS_KEY} --type "SecureString" --overwrite
echo "Adding admin_password to SSM..."
aws ssm put-parameter --region eu-west-1 --name admin_password --value ${ADMIN_PASSWORD} --type "SecureString" --overwrite
echo "Adding admin_password_hash to SSM..."
aws ssm put-parameter --region eu-west-1 --name admin_password_hash --value ${ADMIN_PASSWORD_HASHED} --type "SecureString" --overwrite
echo "Adding dashboard_password to SSM..."
aws ssm put-parameter --region eu-west-1 --name dashboard_password --value ${DASHBOARD_PASSWORD} --type "SecureString" --overwrite
echo "Adding dashboard_password_hash to SSM..."
aws ssm put-parameter --region eu-west-1 --name dashboard_password_hash --value ${DASHBOARD_PASSWORD_HASHED} --type "SecureString" --overwrite
