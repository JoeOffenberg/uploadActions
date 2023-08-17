# This file is for local development only
# It MUSTN'T be included in the Terraform artifact

provider google {
  project = var.project_id
  region  = "us-central1"
}

module "local_execution" {
  source = "../"

  # You will get the values from SNOW when executing via CD Pipeline
  # Since this is a local run we have to provide the values
  environment   = "dev"
  project_id    = var.project_id
  regionality   = "us-central1"
  business_unit = "ts"
  owner         = "sg0000000"
  contact_email = "rick_deckard__sabre_com" # use _ for . and __ for @

  # Custom variables
  # Put all the variables that you set using tfvars files
  # Make sure that you set assign the values in the local.tfvars for local execution
  app_name           = var.app_name
  bucket_name_suffix = var.bucket_name_suffix
  foo                = var.foo
}
