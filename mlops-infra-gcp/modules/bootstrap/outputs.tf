output "tf_state_bucket" {
  description = "mlops-tofu-state-gcp1"
  value       = google_storage_bucket.tf_state.name
}

output "tf_state_bucket_location" {
  description = "us-east1"
  value       = google_storage_bucket.tf_state.location
}

output "terraform_sa_email" {
  description = "Service account with permissions on the bucket"
  value       = var.terraform_sa_email
}
