
  resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
  }

  resource "aws_subnet" "my_sub1" {
    cidr_block = "10.0.0.0/24"
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = "us-east-1a"
    tags={
        Name= "My_Sub1"
    }
    
  }


  resource "aws_subnet" "my_sub2" {
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = "us-east-1b"
    tags={
        Name= "My_Sub2"
    }
    
  }

  resource "aws_security_group" "my_sg" {
    vpc_id = aws_vpc.my_vpc.id
    ingress{
        description = " for SSH"
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "Fot http"
        to_port = 80
        from_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
       Name= "Mysg"
    }
    
  }
 
  resource "aws_instance" "my-instance1" {
    ami = "ami-0c7217cdde317cfec"
    instance_type = "t2.micro"
    #key_name =file(aws_key_pair.mykey.public_key)
    #security_groups = aws_security_group.my_sg.id
    vpc_security_group_ids = [aws_security_group.my_sg.id]
    subnet_id = aws_subnet.my_sub1.id
    
  }
  