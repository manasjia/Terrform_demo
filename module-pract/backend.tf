terraform {
  backend "s3" {
    bucket = "my-moudle-test-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
