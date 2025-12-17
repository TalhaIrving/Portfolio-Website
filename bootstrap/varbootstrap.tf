variable "backend_state_bucket_name" {
  type = string
  description = "The name of the S3 bucket for storing the Terraform backend state"
  default = "talha-irving-terraform-state"
}

variable "backend_state_lock_table_name" {
  type = string
  description = "The name of the DynamoDB table for Terraform backend state locking"
  default = "terraform_lock"
}