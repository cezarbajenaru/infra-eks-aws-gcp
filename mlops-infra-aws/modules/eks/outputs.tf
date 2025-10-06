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

# Fargate outputs - commented out due to attribute name changes
# output "fargate_pod_execution_role_arn" {
#   description = "Fargate pod execution role ARN"
#   value       = module.eks.fargate_profiles["default"].pod_execution_role_arn
# }

# output "fargate_pod_execution_role_name" {
#   description = "Fargate pod execution role name"
#   value       = module.eks.fargate_profiles["default"].pod_execution_role_name
# }

# Security group outputs
output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "EKS node security group ID"
  value       = module.eks.node_security_group_id
}

# Cluster configuration outputs
output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = module.eks.cluster_version
}

# IRSA outputs
output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks.oidc_provider_arn
}