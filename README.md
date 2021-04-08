# Kubeflow on Amazon EKS
Instructions for deploying Kubeflow on Amazon EKS

### Prerequisites

* Permissions
  * [Minimum IAM policies for EKS](https://eksctl.io/usage/minimum-iam-policies/)

### Creating CloudShell environment

```bash
sudo curl --silent --location -o /usr/local/bin/kubectl  https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.11/2020-09-18/bin/linux/amd64/kubectl

sudo chmod +x /usr/local/bin/kubectl

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin

```

### Creating EKS Cluster

```bash
cat << EoF > create-cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eks-kubeflow
  region: us-east-2

nodeGroups:
  - name: ng
    desiredCapacity: 2
    instanceType: m5.xlarge
EoF

```

```bash
eksctl create cluster -f create-cluster.yaml 
```
