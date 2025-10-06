terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.6.0"


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
  cluster_name    = "${var.project}-eks"
  cluster_version = "1.34"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  # <-- must be true if you want kubectl from laptop }
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  enable_irsa = true   # IAM Roles for Service Accounts

  eks_managed_node_groups = { #check with client 
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
    }
  }

  fargate_profiles = {
    default = {
      name = "default-fargate-profile"
      selectors = [
        {
          namespace = "fargate-apps"
        }
      ]
    }
  }

# Cluster logging stream will be seen in Cloudwatch logs
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    Project = var.project
    Env     = var.env
  }
}