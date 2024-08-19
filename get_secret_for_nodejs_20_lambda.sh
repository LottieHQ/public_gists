#!/bin/bash

# This function will export all key value pairs under a given AWS Secret as an environment variable file

echo "Exporting variables from Secrets Manager"

# Get all Key Value pairs of the secret
SECRETS_JSON=$(aws secretsmanager get-secret-value \
  --region ${REGION} \
  --secret-id ${SECRET_PATH} \
  --query 'SecretString' \
  --output text)

VARS_FILE="/tmp/secrets"
rm -f $VARS_FILE # Remove the file if it already exists
# Loop through each key value pair and export it as an environment variable
for row in $(echo "${SECRETS_JSON}" | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]"); do
  export $row
done
echo "Variables from Secrets Manager successfully exported"
# Execute the lambda function using the entrypoint script from https://github.com/aws/aws-lambda-base-images/blob/nodejs20.x/Dockerfile.nodejs20.x
exec /lambda-entrypoint.sh "$@"
