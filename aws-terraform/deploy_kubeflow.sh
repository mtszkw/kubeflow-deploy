#!/bin/bash

# Exit when any command fails
set -e

# Display commands
set -x

# Set environment variables
source set_env_variables.sh

# Install and check dependencies
source get_dependencies.sh

# Setup infrastructure
cd terraform && \
terraform init && \
terraform validate && \
terraform apply -auto-approve \
-var="aws_region=$AWS_DEFAULT_REGION" \
-var="aws_access_key=$AWS_ACCESS_KEY_ID" \
-var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
-var="aws_cluster_name=$CONFIG_EKS_CLUSTER_NAME"

TERRAFORM_EKS_CLUSTER_IAM_ROLE_NAME=$(terraform output -raw eks_cluster_iam_role_name)

cd ..

export KUBECONFIG="$PWD/terraform/kubeconfig_$CONFIG_EKS_CLUSTER_NAME"
echo "KUBECONFIG=$KUBECONFIG"
kubectl get nodes --all-namespaces

# Prepare for Kubeflow deployment
export KUBEFLOW_DIR="$PWD/$CONFIG_EKS_CLUSTER_NAME"
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_aws.v1.2.0.yaml"
export CONFIG_FILE="$KUBEFLOW_DIR/kfctl_aws.yaml"

# Go to working directory and download kfctl_aws.yaml
mkdir -p $KUBEFLOW_DIR && cd $KUBEFLOW_DIR
wget -O $CONFIG_FILE $CONFIG_URI

# Replace region in kfctl_aws.yaml
sed -i -e "s/us-west-2/$AWS_DEFAULT_REGION/g" $CONFIG_FILE
sed -i -e "s/#roles/roles/g" $CONFIG_FILE
sed -i -e "s/#- eksctl-kubeflow-aws-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx/- $TERRAFORM_EKS_CLUSTER_IAM_ROLE_NAME/g" $CONFIG_FILE
sed -i -e "s/enablePodIamPolicy: true/enablePodIamPolicy: false/g" $CONFIG_FILE
tail -15 $CONFIG_FILE

# Pray
kfctl apply -V -f $CONFIG_FILE
echo "Waiting for all services to be ready (2 min)" && sleep 2m

kubectl get service istio-ingressgateway -n istio-system
# If you want to use LoadBalancer instead of NodePort
# kubectl patch svc istio-ingressgateway -p '{"spec": {"type": "LoadBalancer"}}' -n istio-system
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
