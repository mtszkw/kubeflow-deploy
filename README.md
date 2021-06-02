## Kubeflow Deploy

Mentioned in [Kubeflow (is not) for Dummies](https://mtszkw.substack.com/p/kubeflow-is-not-for-dummies) blog post.

### [AWS EKS + CloudShell](aws-cloudshell/)

Deploying Kubeflow using AWS CloudShell and eksctl, no need to configure aws-cli. Poor reproducibility.

### [AWS EKS + Terraform](aws-terraform/)

Deploying Kubeflow using Terraform code locally. You'll need few tools e.g. kubectl, aws-iam-authenticator but the script should install these for you. All you need then is configure AWS cli and a bash console. This approach has a simple configuration i.e. AWS profile, region, cluster name and creates a cluster than can be destroyed easily with destroy_kubeflow script.

### [Minikube (WSL)](minikube/)

Instructions for deploying Kubeflow 1.2 locally on WSL using minikube. Quite simple, poor reproducibility and it's local only.
