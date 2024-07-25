terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59.0"
    }
  }
}


provider "aws" {
    region = "us-east-1"
    access_key = var.aws_access_key_id
    secret_key = var.aws_secret_access_key
}
