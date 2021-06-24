#!/bin/bash

# Exit when any command fails
set -e

# Display commands
set -x

# Set environment variables
source set_env_variables.sh

cd terraform

terraform destroy -auto-approve \
-var="aws_region=$AWS_DEFAULT_REGION" \
-var="aws_access_key=$AWS_ACCESS_KEY_ID" \
-var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
-var="aws_cluster_name=$CONFIG_EKS_CLUSTER_NAME"

cd ..