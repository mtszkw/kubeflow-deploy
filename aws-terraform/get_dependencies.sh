#!/bin/bash

# Exit when any command fails
set -e

# Display commands
set -x

if ! [ -x "$(command -v terraform)" ]; then
  echo 'Error: Terraform is not installed.' >&2
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl && \
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  sudo apt-get update && sudo apt-get install terraform
  # exit 1
fi

if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: aws is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v aws-iam-authenticator)" ]; then
  echo 'Error: aws-iam-authenticator is not installed.' >&2
  curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator && \
  chmod +x aws-iam-authenticator && \
  sudo mv aws-iam-authenticator /usr/local/bin
  # exit 1
fi

if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
  kubectl version --client
  # exit 1
fi

if ! [ -x "$(command -v eksctl)" ]; then
  echo 'Error: eksctl is not installed.' >&2
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
  sudo mv -v /tmp/eksctl /usr/local/bin
  # exit 1
fi

if ! [ -x "$(command -v kfctl)" ]; then
  echo 'Error: kfctl is not installed.' >&2
  curl --silent --location "https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz" | tar xz -C .
  sudo mv -v kfctl /usr/local/bin
  # exit 1
fi