terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "personal-admin"
  region = "eu-central-1"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Policy: EksAllAccess
resource "aws_iam_policy" "policy_EksAllAccess" {
  name = "EksAllAccess"
  description = "EksAllAccess for Kubeflow deploy"
  tags = {
    Project = "Playground"
    CreatedWith  = "Terraform"
  }

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "eks:*",
        "Resource": "*"
      },
      {
        "Action": [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        "Resource": [
          "arn:aws:ssm:*:${local.account_id}:parameter/aws/*",
          "arn:aws:ssm:*::parameter/aws/*"
        ],
        "Effect": "Allow"
      },
      {
        "Action": [
          "kms:CreateGrant",
          "kms:DescribeKey"
        ],
        "Resource": "*",
        "Effect": "Allow"
      }
    ]
  })
}

# Policy: IamLimitedAccess
resource "aws_iam_policy" "policy_IamLimitedAccess" {
  name = "IamLimitedAccess"
  description = "IamLimitedAccess for Kubeflow deploy"
  tags = {
    Project = "Playground"
    CreatedWith  = "Terraform"
  }
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:ListInstanceProfiles",
          "iam:AddRoleToInstanceProfile",
          "iam:ListInstanceProfilesForRole",
          "iam:PassRole",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:GetOpenIDConnectProvider",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:ListAttachedRolePolicies",
          "iam:TagRole"
        ],
        "Resource": [
          "arn:aws:iam::${local.account_id}:instance-profile/eksctl-*",
          "arn:aws:iam::${local.account_id}:role/eksctl-*",
          "arn:aws:iam::${local.account_id}:oidc-provider/*",
          "arn:aws:iam::${local.account_id}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup",
          "arn:aws:iam::${local.account_id}:role/eksctl-managed-*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "iam:GetRole"
        ],
        "Resource": [
          "arn:aws:iam::${local.account_id}:role/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "iam:CreateServiceLinkedRole"
        ],
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "iam:AWSServiceName": [
              "eks.amazonaws.com",
              "eks-nodegroup.amazonaws.com",
              "eks-fargate.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# Policy: IamFullAccessKubeflow
resource "aws_iam_policy" "policy_IamFullAccessKubeflow" {
  name = "IamFullAccessKubeflow"
  description = "IamFullAccessKubeflow for Kubeflow deploy"
  tags = {
    Project = "Playground"
    CreatedWith  = "Terraform"
  }
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "iam:*"
        ],
        "Resource": [
          "arn:aws:iam::${local.account_id}:role/kf-*"
        ]
      }
    ]
  })
}

# Group: KubeflowDevelopers
resource "aws_iam_group" "group_KubeflowDevelopers" {
  name = "KubeflowDevelopers"
  path = "/"
}

# Attach EksAllAccess policy to KubeflowDevelopers group
resource "aws_iam_group_policy_attachment" "attach_EksAllAccess_to_group" {
  group      = aws_iam_group.group_KubeflowDevelopers.name
  policy_arn = aws_iam_policy.policy_EksAllAccess.arn
}

# Attach IamLimitedAccess policy to KubeflowDevelopers group
resource "aws_iam_group_policy_attachment" "attach_IamLimited_to_group" {
  group      = aws_iam_group.group_KubeflowDevelopers.name
  policy_arn = aws_iam_policy.policy_IamLimitedAccess.arn
}

# Attach IamFullAccessKubeflow policy to KubeflowDevelopers group
resource "aws_iam_group_policy_attachment" "attach_IamFullKF_to_group" {
  group      = aws_iam_group.group_KubeflowDevelopers.name
  policy_arn = aws_iam_policy.policy_IamFullAccessKubeflow.arn
}

#############################################################################################

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "kubeflow-cluster"
}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name                 = "k8s-vpc"
  cidr                 = "172.16.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "15.1.0"

  cluster_name    = "${local.cluster_name}"
  cluster_version = "1.18"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  node_groups = {
    first = {
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 1

      instance_types = ["m5.xlarge", "m5.xlarge"]
    }
  }

  write_kubeconfig   = true
  config_output_path = "./"
}
