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
    access_key = "yoAKIASVYSAJ7N4VKRKB4Y" # Optional, can also use environment variables
    secret_key = "Kr1xjImcNxA00vJtGX9s5PYtcLpR0LCz1141OFos" # Optional, can also use environment variables
  
}