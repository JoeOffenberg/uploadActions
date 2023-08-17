# This file is for local development only
# It MUSTN'T be included in the Terraform artifact
# For CD Pipeline deployment a similar file is dynamically generated

terraform {
  # The state file location for local development is provided in Makefile
  # in local-plan, local-apply, local-destroy and local-refresh targets
  # If you want to use a shared location modify the targets and uncomment gcs backend below
  # backend "local" {
  #   path = "./terraform.tfstate"
  # }
  # backend "gcs" {
  #   bucket  = "tf-team-state"
  #   prefix  = "terraform/state"
  # }
  required_providers {
    google = {
      version = "~> 4.21"
    }
  }
}
