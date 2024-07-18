#!/bin/bash

# This script will export all key value pairs under a given AWS Secret as an environment variable file

REGION="eu-west-2"

# Set the Secret name or path is passed as the only parameter
SECRET_PATH="${1}"

# Get all Key Value pairs of the secret
SECRETS_JSON=$(aws secretsmanager get-secret-value \
  --region ${REGION} \
  --secret-id ${SECRET_PATH} \
  --query 'SecretString' \
  --output text)

VARS_FILE="/tmp/secrets"
rm -f $VARS_FILE # Remove the file if it already exists
echo "Exporting variables to ${VARS_FILE}"
# Lopp through each key value pair and export it as an environment variable
for row in $(echo "${SECRETS_JSON}" | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]"); do
  export $row
  echo "Exported variable: $row"
  echo "export $row" >> $VARS_FILE
done
