output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {  #This URL acts as the “identity provider” for the cluster. AWS uses it to validate tokens issued by Kubernetes service accounts
  description = "OIDC issuer URL for IRSA"
  value       = module.eks.cluster_oidc_issuer_url
}

output "node_group_role_name" {
  description = "IAM role name for the worker nodes"
  value       = module.eks.eks_managed_node_groups["default"].iam_role_name
}