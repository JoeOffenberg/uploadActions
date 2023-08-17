# This file is for local development only
# It MUSTN'T be included in the Terraform artifact

# Make sure that you include all outputs from ../outputs.tf here

output "bucket_name" {
  value = module.local_execution.bucket_name
}

output "bucket_link" {
  value = module.local_execution.bucket_link
}

output "bucket_url" {
  value = module.local_execution.bucket_url
}
