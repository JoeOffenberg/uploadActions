# This file is for local development only
# It MUSTN'T be included in the Terraform artifact

# Make sure that you include all outputs from ../variables.tf here
# Except the SNOW variables which are defined in the local/main.tf

variable "app_name" {
  default     = "sndevops"
  description = "name of the application, used as prefix for GCE instances names (example: my-app-name)"
}

variable "bucket_name_suffix" {
  default     = "default"
  description = "Suffix for Cloud Storage bucket"
}

variable "foo" {
  default     = "bar"
  description = "FooBar variable to demonstrate how to pass values via Automation Data"
}

# Do not modify variables below, these are specific to the local execution

variable "project_id" {
  description = "Project ID for local execution, value set in the Makefile"
}
