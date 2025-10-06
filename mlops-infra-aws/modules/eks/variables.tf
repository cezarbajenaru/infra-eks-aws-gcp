variable "project" {
  description = "Project name prefix"
  type        = string
  default     = "mlops-infra-aws"
}

variable "env" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "development"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2" # matches correctly
}

variable "vpc_id" {
  description = "VPC ID from networking module" # to be completed!!!
  type        = string
}

variable "private_subnets" {
  description = "Private subnets for worker nodes" # to be completed!!! these variables are taken by main.tf
  type        = list(string)
}

# EKS Cluster Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Node Group Configuration
variable "node_group_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_group_instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_group_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_group_capacity_type)
    error_message = "Capacity type must be either ON_DEMAND or SPOT."
  }
}

# Fargate Configuration
variable "fargate_namespace" {
  description = "Namespace for Fargate profile selector"
  type        = string
  default     = "fargate-apps"
}

# Logging Configuration
variable "enabled_log_types" {
  description = "List of enabled EKS cluster log types"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}