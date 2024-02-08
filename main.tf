provider "aws" {
    region = "us-east-1"
     
  }

  resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
  }

  resource "aws_subnet" "my_sub1" {
    cidr_block = "10.0.0.0/24"
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = " us-east-1a"
    tags={
        Name= "My_Sub1"
    }
    
  }


  resource "aws_subnet" "my_sub2" {
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = " us-east-1b"
    tags={
        Name= "My_Sub2"
    }
    
  }