# This is an example Terraform resource for creation of a Google Storage bucket
# Replace it with your resources, you can add more files to this folder for better structure

resource "google_storage_bucket" "bucket" {
  name                        = "${var.project_id}-${var.app_name}-${var.bucket_name_suffix}"
  location                    = var.regionality
  force_destroy               = true
  uniform_bucket_level_access = true
  labels = {
    application   = var.app_name
    business_unit = var.business_unit
    contact_email = var.contact_email
    name          = var.app_name
    owner         = var.owner
  }
}

data "local_file" "artifact" {
  filename = "${path.module}/readme.txt"
}

resource "google_storage_bucket_object" "file_artifact" {
  name   = "${var.app_name}-readme-${filemd5(data.local_file.artifact.filename)}.txt"
  bucket = google_storage_bucket.bucket.name
  source = data.local_file.artifact.filename
}
