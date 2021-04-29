output "eks_cluster_iam_role_arn" {
  description = "ARN of the EKS cluster Security Group"
  value       = module.eks.cluster_iam_role_arn
}

output "eks_cluster_iam_role_name" {
  description = "Name of the EKS cluster Security Group"
  value       = module.eks.cluster_iam_role_name
}