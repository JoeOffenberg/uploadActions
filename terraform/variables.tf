# Below you will find all the top level variables for your deployment package
# You MUST provide values for all of them
# The order of sources for the values is as follows (later sources override if values are already set)
# 1. The default value from the variable declaration
# 2. tfvars file for the target environment (dev.tfvars for Development, cert.tfvest for Certification, prod.tfvars for Production)
# 3. Additional tfvars file specified in the Automation Data in deploymentParametersFile
# 4. Additional parameters passed via Automation Data deploymentParameters
# For an example of Automation Data setup see: http://gitdocs.sabre.com/gitdocs/gcp-cicd/armada/application-configuration.html#_sample_automation_data_for_ansible_tower_with_terraform

# For local development:
# 1. You have to copy declaration of all your variables to local/variables.tf
# 2. Assign values in local/local.tfvars

variable "app_name" {
  default     = "sndevops"
  description = "name of the application, used as prefix for GCE instances names (example: my-app-name)"
}

variable "bucket_name_suffix" {
  default     = "default"
  description = "the bucket name suffix"
}

variable "foo" {
  default     = "bar"
  description = "FooBar variable to demonstrate how to pass values via Automation Data"
}

# These variables are populated by SNOW and passed by the CD Pipeline
# Do not touch - the declaration is necessary

variable "business_unit" {}
variable "contact_email" {}
variable "environment" {}
variable "owner" {}
variable "project_id" {}
variable "regionality" {}
