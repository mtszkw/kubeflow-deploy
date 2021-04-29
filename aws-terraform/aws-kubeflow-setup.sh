#!/bin/bash

CONFIG_AWS_REGION="eu-central-1"
CONFIG_AWS_PROFILE="personal-admin"
CONFIG_EKS_CLUSTER_NAME="kubeflow_cluster"

export AWS_REGION=$CONFIG_AWS_REGION
export AWS_PROFILE=$CONFIG_AWS_PROFILE

curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin

curl --silent --location "https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/kfctl /usr/local/bin

if ! [ -x "$(command -v terraform)" ]; then
  echo 'Error: Terraform is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: aws is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v aws-iam-authenticator)" ]; then
  echo 'Error: aws-iam-authenticator is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v eksctl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v kfctl)" ]; then
  echo 'Error: kfctl is not installed.' >&2
  exit 1
fi

# Setup infrastructure
cd terraform
terraform init && terraform validate && terraform apply -auto-approve

TERRAFORM_EKS_CLUSTER_IAM_ROLE_NAME=$(terraform output -raw eks_cluster_iam_role_name)
echo $TERRAFORM_EKS_CLUSTER_IAM_ROLE_NAME

# Check if it's working
cd ..
export KUBECONFIG="$PWD/terraform/kubeconfig_kubeflow-cluster"
kubectl get nodes --all-namespaces

# Prepare for Kubeflow deployment
export KUBEFLOW_DIR="$PWD/$CONFIG_EKS_CLUSTER_NAME"

export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_aws.v1.2.0.yaml"
export CONFIG_FILE="$KUBEFLOW_DIR/kfctl_aws.yaml"

# Go to working directory and download kfctl_aws.yaml
mkdir -p $KUBEFLOW_DIR && cd $KUBEFLOW_DIR
wget -O $CONFIG_FILE $CONFIG_URI

# Replace region in kfctl_aws.yaml
sed -i -e "s/us-west-2/$CONFIG_AWS_REGION/g" $CONFIG_FILE
sed -i -e "s/#roles/roles/g" $CONFIG_FILE
sed -i -e "s/#- eksctl-kubeflow-aws-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx/- $TERRAFORM_EKS_CLUSTER_IAM_ROLE_NAME/g" $CONFIG_FILE
sed -i -e "s/enablePodIamPolicy: true/enablePodIamPolicy: false/g" $CONFIG_FILE

cat $CONFIG_FILE
# Pray
kfctl apply -V -f $CONFIG_FILE

kubectl get service istio-ingressgateway -n istio-system

# kubectl patch svc istio-ingressgateway -p '{"spec": {"type": "LoadBalancer"}}' -n istio-system