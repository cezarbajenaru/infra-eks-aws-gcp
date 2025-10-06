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