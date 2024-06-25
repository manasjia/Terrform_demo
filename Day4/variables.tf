

variable "instance_type" {
    type = string
    description = "Instance Type for the server"
    default = "t2.micro"
  
}

variable "ami" {
    type = string
    description = "Ami for creatin the instances"
    default = "ami-04b70fa74e45c3917"
  
}

variable "vpc_cidar" {
    type = string
    description = "cidar for VPC "
    default = "10.0.0.0/16"
  
}

variable "instance_count" {
    default = 3
  
}

