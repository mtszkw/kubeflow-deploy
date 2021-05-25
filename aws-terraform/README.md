## Kubeflow on EKS with Terraform

#### Requirements
Deploy Kubeflow script need and will install:
- aws CLI
- aws-iam-authenticator
- eksctl
- kubectl
- Terraform

#### Deploying 

To run deployment first configure required parameters (region and cluster name, name of AWS profile with admin privileges) in `set_env_variables` script. Then run `deploy_kubeflow` and wait for deployment to finish. This may take up to 10 minutes.

```bash
# Edit configuration
cd aws-terraform
vim set_env_variables.sh

# Deploy
# you may be prompted for sudo authentication
source deploy_kubeflow.sh

# wait a couple of minutes and done
```

#### Cleaning up

Run `destroy_kubeflow` to destroy resources created before. Make sure that parameters in `set_env_variables` are the same as they were when you executed deploy.

```bash
cd aws-terraform
source destroy_kubeflow.sh
```

#### Notes

- I wrote a blog post about this project.

- I wanted to keep it simple and use Kubeflow only for my private purposes so I didn’t care about IAM or authentication. I wouldn’t use this code in any real project but I think this may be a good foundation.

- There are other ways to create EKS cluster and deploy Kubeflow on AWS, depending on your needs you may use CloudShell, eksctl or other tools.

- Whole KF deployment is quite big and quite expensive (I had to use m5.xlarge instances to handle it, got not no success with cheaper machines).

- If you need to deploy Kubeflow Pipelines only, you can have it.