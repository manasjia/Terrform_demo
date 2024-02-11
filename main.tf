resource "aws_vpc" "my_vpc" {
    cidr_block = var.cidr
}

resource "aws_subnet" "mysubnet1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "mysubnet2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
  
}
resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    
  
}
resource "aws_route_table" "Myrt" {
    vpc_id = aws_vpc.my_vpc.id
    route{
        cidr_block="0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
  
}
resource "aws_route_table_association" "myartA1" {
    route_table_id = aws_route_table.Myrt.id
    subnet_id = aws_subnet.mysubnet1.id
    
  
}
resource "aws_route_table_association" "myartA2" {
    route_table_id = aws_route_table.Myrt.id
    subnet_id = aws_subnet.mysubnet2.id
    
  
}
resource "aws_security_group" "myswg" {
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        description = "ssh"
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
   ingress {
        description = "HTTP"
        to_port = 80
        from_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  egress {
    to_port = 0
    from_port = 0
     protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
  
}

resource "aws_instance" "webserver1" {
    ami = "ami-0c7217cdde317cfec"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.mysubnet1.id
    vpc_security_group_ids = [aws_security_group.myswg.id]
    user_data = base64encode(file("userdata.sh"))
  
}

resource "aws_instance" "webserver2" {
    ami = "ami-0c7217cdde317cfec"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.mysubnet2.id
    vpc_security_group_ids = [aws_security_group.myswg.id]
    user_data = base64encode(file("userdata1.sh"))
  
}
resource "aws_s3_bucket" "my_s3_bucket" {
    bucket = "manas-terraform-pract12"
  
}