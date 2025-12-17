terraform {
  backend "s3" {
    bucket = "talha-irving-terraform-state"
    key = "terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "terraform_lock"
    encrypt = true
  }
}
