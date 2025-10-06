variable "project_id" {
  description = "MLops GCP"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "terraform_sa_email" {
  description = "Service account email used by Terraform"
  type        = string
}