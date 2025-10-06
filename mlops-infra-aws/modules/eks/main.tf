terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.6.0"
}

terraform {
  backend "s3" {
    bucket         = "mlops-tofu-state"   # same state bucket as networking
    key            = "aws/eks/terraform.tfstate" #the folder in which eks terraform.tfstate will live ( along others in this project )
    region         = "us-east-2" # in conformity with client request
    dynamodb_table = "mlops-tofu-locks" # enabled at client request
    encrypt        = true
  }
}

provider "aws" {
  region = var.region #assigned in variables
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.2"
  name    = "${var.project}-eks"
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  # <-- must be true if you want kubectl from laptop }
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs

  enable_irsa = true   # IAM Roles for Service Accounts

  eks_managed_node_groups = { #check with client 
    default = {
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size
      instance_types = var.node_group_instance_types
      capacity_type  = var.node_group_capacity_type
    }
  }

  fargate_profiles = {
    default = {
      name = "default-fargate-profile"
      selectors = [
        {
          namespace = var.fargate_namespace
        }
      ]
    }
  }

# Cluster logging stream will be seen in Cloudwatch logs
  enabled_log_types = var.enabled_log_types

  tags = {
    Project = var.project
    Env     = var.env
  }
}