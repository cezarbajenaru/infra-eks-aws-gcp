terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "us-east-2" # in conformity with client request
}

resource "aws_s3_bucket" "tf_state" {  #creation of the bucket where the .tfstate files of each module will live
  bucket = "mlops-tofu-state"

  tags = {
    Project = "mlops"
    Purpose = "terraform-state"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" { #enabled versioning to protect state history just in case
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # SSE-S3 encryption
    }
  }
}

resource "aws_dynamodb_table" "tf_locks" {  #this will ensure Dynamo DB State locking ( this is like an automation contract between tofu and dynamodb )
  name         = "mlops-tofu-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project = "mlops"
    Purpose = "terraform-locking"
  }
}
