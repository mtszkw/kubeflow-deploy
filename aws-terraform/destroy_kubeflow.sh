#!/bin/bash

# Exit when any command fails
set -e

# Display commands
set -x

# Set environment variables
source set_env_variables.sh

cd terraform
terraform destroy -auto-approve -var="aws_profile=$AWS_PROFILE" -var="aws_region=$AWS_REGION" -var="aws_cluster_name=$CONFIG_EKS_CLUSTER_NAME"
cd ..