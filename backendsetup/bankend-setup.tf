provider "aws" {

  region = "us-east-1"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "manas-demo-buck-1"

  force_destroy = "false"



  tags = {
    Name = "Terraform State Bucket"
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {

      sse_algorithm = "AES256"

    }
  }

}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}


resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"

  }

}


