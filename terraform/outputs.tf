# This file contains outputs that will be returned after TF module execution.
# This data will not be passed with full logs to SNOW.

# Please check https://www.terraform.io/docs/configuration/outputs.html for more details

# This outputs below are specific to bucket, which is created by this demo app
output "bucket_name" {
  value = google_storage_bucket.bucket.name
}

output "bucket_link" {
  value = google_storage_bucket.bucket.self_link
}

output "bucket_url" {
  value = google_storage_bucket.bucket.url
}
