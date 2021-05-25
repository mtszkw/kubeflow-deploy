variable "aws_profile" {
  type        = string
  description = "AWS CLI profile name"
}

variable "aws_region" {
  type        = string
  description = "AWS Region where resources should be created"
}

variable "aws_cluster_name" {
  type        = string
  description = "Name of Amazon EKS cluster to be created"
}
