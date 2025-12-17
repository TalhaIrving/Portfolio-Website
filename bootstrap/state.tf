terraform {
  backend "s3" {
    bucket = "talha-irving-terraform-state"
    key    = "bootstrap/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "terraform_lock"
    encrypt = true
  }
}

resource "aws_s3_bucket" "backend_state_storage" {
  bucket = var.backend_state_bucket_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "backend_state_lock" {
  name = var.backend_state_lock_table_name
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  lifecycle {
    prevent_destroy = true
  }
  billing_mode = "PAY_PER_REQUEST"
}


# Outputs

output "backend_state_bucket_name" {
  value = aws_s3_bucket.backend_state_storage.bucket
}

output "backend_state_bucket_arn" {
  value = aws_s3_bucket.backend_state_storage.arn
}

output "backend_state_lock_table_name" {
  value = aws_dynamodb_table.backend_state_lock.name
}

output "backend_state_lock_table_arn" {
  value = aws_dynamodb_table.backend_state_lock.arn
}