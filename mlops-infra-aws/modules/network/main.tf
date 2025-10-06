terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Remote state backend (adjust bucket/table names to your environment)
  backend "s3" {
    bucket         = "mlops-tofu-state"     # this bucket is created by boostrap/ module
    key            = "aws/networking/terraform.tfstate"
    region         = "us-east-2" # # in conformity with client request
    dynamodb_table = "mlops-tofu-locks"     # created
    encrypt        = true
  }
}

provider "aws" {
  region = var.region # find in variables
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project = var.project
    Env     = var.env
  }
}
