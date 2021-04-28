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
  profile = "default"
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