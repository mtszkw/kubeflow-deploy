## Kubeflow on EKS with Terraform

## Requirements
- aws CLI
- aws-iam-authenticator
- eksctl
- kubectl
- Terraform

If any of these tools is not available, Kubeflow Deploy will try to download and install it.

## Deploy Kubeflow

To run deployment you need to provide your AWS credentials, cluster name (optional) and start the deployment:

You can set these in `set_env_variables.sh` script or in any other way:

```bash
AWS_DEFAULT_REGION=XXX
AWS_ACCESS_KEY_ID=XXXX
AWS_SECRET_ACCESS_KEY=XXX
CONFIG_EKS_CLUSTER_NAME=XXX
```

**Important**: The identity you're using needs certain permissions to be able to set up the infrastructure. You can find necessary IAM policies in [iam directory](iam/), apply these to your profile (e.g. add them to DevelopersKubeflow group whcih will be attached to your profile) before starting deploy.

Run the script and wait for the deployment to finish (it may take up to 10 minutes):

```
source deploy_kubeflow.sh
```

## Destroy Kubeflow

Run `destroy_kubeflow` to destroy resources created before.  
Make sure that parameters in `set_env_variables` are the same as they were when you executed deploy.

```bash
cd aws-terraform
source destroy_kubeflow.sh
```
