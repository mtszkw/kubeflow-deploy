variable "aws_region" {
  type        = string
  description = "AWS Region where resources should be created"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}


variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}


variable "aws_cluster_name" {
  type        = string
  description = "Name of Amazon EKS cluster to be created"
}