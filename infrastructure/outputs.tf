# Backend state bucket outputs
# output "backend_state_bucket_name" {
#   value = aws_s3_bucket.backend_state_storage.bucket
# }

# output "backend_state_bucket_arn" {
#   value = aws_s3_bucket.backend_state_storage.arn
# }


# Backend state lock table outputs
# output "backend_state_lock_table_name" {
#   value = aws_dynamodb_table.backend_state_lock.name
# }

# output "backend_state_lock_table_arn" {
#   value = aws_dynamodb_table.backend_state_lock.arn
# }

# Website bucket outputs
# Bootstrap state outputs
data "terraform_remote_state" "bootstrap_state" {
  backend = "s3"
  config = {
    bucket         = "talha-irving-terraform-state"
    key            = "bootstrap/terraform.tfstate"
    region         = "eu-west-2"
  }
}

output "backend_state_bucket_name" {
  value = data.terraform_remote_state.bootstrap_state.outputs.backend_state_bucket_name
}

output "backend_state_lock_table_name" {
  value = data.terraform_remote_state.bootstrap_state.outputs.backend_state_lock_table_name
}

output "backend_state_bucket_arn" {
  value = data.terraform_remote_state.bootstrap_state.outputs.backend_state_bucket_arn
}

output "backend_state_lock_table_arn" {
  value = data.terraform_remote_state.bootstrap_state.outputs.backend_state_lock_table_arn
}

output "website_bucket_name" {
  value = aws_s3_bucket.portfolio_website.bucket
}
