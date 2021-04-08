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

```bash
eksctl get cluster
eksctl get nodegroup --cluster eks-kubeflow
```

```bash
aws eks --region us-east-2 update-kubeconfig --name eks-kubeflow
```

### Install Kubeflow on Amazon EKS

Check for [latest releases](https://github.com/kubeflow/kfctl/releases) or stay with the version below (1.2.0).

```bash
curl --silent --location "https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/kfctl /usr/local/bin
```

### Set up Kubeflow configuration

```bash
cat << EoF > kf-install.sh
export AWS_CLUSTER_NAME=eks-kubeflow
export KF_NAME=\${AWS_CLUSTER_NAME}

export BASE_DIR=${HOME}/environment
export KF_DIR=\${BASE_DIR}/\${KF_NAME}

# export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_aws_cognito.v1.2.0.yaml"
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_aws.v1.2.0.yaml"

export CONFIG_FILE=\${KF_DIR}/kfctl_aws.yaml
EoF

source kf-install.sh
mkdir -p ${KF_DIR} && cd ${KF_DIR}
```

```bash
wget -O kfctl_aws.yaml $CONFIG_URI
```

Now you can adapt _kfctl_aws.yaml_ file to your needs, in section:

    spec:
      auth:
        basicAuth:
          password: 12341234
          username: admin@kubeflow.org
      region: us-west-2
      enablePodIamPolicy: true
      # If you don't use IAM Role for Service Account, you can still use node instance roles.
      #roles:
      #- eksctl-kubeflow-aws-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx
      
**Important**: Here you should region (us-east-2 is used in this README) and cluster name (by default its kubeflow-aws, see role name). In addition to that, you should decide whether you want to rely on IAM policy (enablePodIamPolicy: true) or node instance roles. Roles can be commented out if you want to use IAM only.

### Install AWS IAM Authenticator

```bash
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin
```

### Deploy Kubeflow

```bash
cd ${KF_DIR} && kfctl apply -V -f ${CONFIG_FILE}
```

Run this to check the status (you'll need to wait a minute or two for all services to be running):

```bash
kubectl -n kubeflow get all
```

### Accessing Kubeflow Dashboard using external IP

When all services are up and running, you should also be able to see istio-ingressgateway:
```bash
kubectl get service istio-ingressgateway -n istio-system
```

If service type is set to NodePort, edit its specification and replace NodePort with LoadBalancer. After saving changes, istio-ingressgateway should have an external IP to be used to access it from the outside. Finally, use port-forwarding to expose Kubeflow Dashboard. Once again you'll need to wait a minute before you can access it.

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```
