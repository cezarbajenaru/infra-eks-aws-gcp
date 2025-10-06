variable "project" {
  description = "Project name prefix"
  type        = string
  default     = "mlops-infra-aws"
}

variable "env" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC" # check what AWS gives us
  type        = string
  default     = "10.42.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"] # !!!check with client
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
  default     = ["10.42.1.0/24", "10.42.2.0/24", "10.42.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnets"
  type        = list(string)
  default     = ["10.42.101.0/24", "10.42.102.0/24", "10.42.103.0/24"]
}
