variable "aws_region" {
    type = string
    description = "Aws region put for Bucket"
    default = "us-east-1"
  
}

variable "site_domain" {
  type        = string
  description = "The domain name to use for the static site"
}

variable "cloudflare_api_token" {
    type = string
    default = "xhOTuFIkQFrNfgzKcgRX1WhNoIbJLTo_UFticFt6"
  
}