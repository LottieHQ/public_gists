#!/bin/bash

# This script will export all SSM parameters under a given path as environment variables

REGION="eu-west-2"

# Set the SSM path
SSM_PATH="${1}"

# Get all SSM parameter names under the given path
SSM_PARAMETER_NAMES=$(aws ssm get-parameters-by-path \
  --region ${REGION} \
  --path "${SSM_PATH}" \
  --recursive \
  --with-decryption \
  --query 'Parameters[].Name' \
  --output text)

# Loop through each parameter and export it as an environment variable
for name in $SSM_PARAMETER_NAMES; do
  value=$(aws ssm get-parameter \
    --region $REGION \
    --name $name \
    --with-decryption \
    --query 'Parameter.Value' \
    --output text)
  if [ ! -z "$name" ] && [ ! -z "$value" ]; then
    name=$(echo $name | awk -F/ '{print toupper($NF)}')
    export "$name"="$value"
    echo "Exported variable: $name"
    echo "export $name=$value" >> /tmp/ssm-parameters
  fi
done
