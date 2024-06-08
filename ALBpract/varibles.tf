variable "cidr" {
   default = "10.0.0.0/16"
  }

  variable availability_zone {
      default =  ["us-east-1a", "us-east-1b"]
    
  }
 variable ami_id {
   default = {
   "us-east-1a" = "ami-0c7217cdde317cfec"
   }
   
 }