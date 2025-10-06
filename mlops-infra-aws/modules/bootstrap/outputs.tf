output "tf_state_bucket" {
  description = "S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.tf_state.bucket
}

output "tf_locks_table" {
  description = "DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.tf_locks.name
}
