terraform {
  
  backend "s3" {
    bucket = "manas-demo-buck-1"
    access_key = "/demo-1/terraform.tfstate"
    dynamodb_table = "terraform-locks"
    region = "us-east-1"
    encrypt = true
     
    
  }

}