terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.6.0"

  backend "gcs" {                             # 🔴 CHANGED from s3 backend → gcs backend
    bucket = "mlops-tofu-state-gcp1"           # 🔴 Needs to be globally unique across all GCP
    prefix = "terraform/state"                # like a folder for .tfstate files
  }

}

provider "google" {
  project = var.project_id  # must create variables.tf
  region = var.region # us-east1 in GCP ( us-east-2 in AWS)
}

resource "google_storage_bucket" "tf_state" {  #creation of the bucket where the .tfstate files of each module will live
  name = "mlops-tofu-state" #resource
  location = var.region

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true          # 🔴 replaces AWS ACL system
}

resource "google_storage_bucket_iam_member" "owner" {  # 🔴 Needed in GCP: permissions for your Terraform SA
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${var.terraform_sa_email}"
}
