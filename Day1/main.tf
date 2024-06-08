
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidar_block
    
   
}
resource "aws_subnet" "my_public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  count =2
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index)
  tags= {
      name="subnet-${count.index}"
      map_public_ip_on_launch = true
  }
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  count = 2
  availability_zone = element(data.aws_availability_zones.available.names, count.index+2)
  cidr_block =cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index+2)
  tags= {
      name="subnet-${count.index}"
  }
}


resource "aws_security_group" "web-sg" {
    vpc_id = aws_vpc.my_vpc.id
    description = "Security group for web-servers with HTTP ports open within VPC"
    ingress  {
       
       from_port = 80
       to_port = 80
       protocol = "tcp"
       security_groups = [aws_security_group.my_alb_sg.id]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
  
}

resource "aws_eip" "nat"{
    vpc = true
}

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.my_public_subnet[0].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_route_table" "my_pb_rt" {
    vpc_id = aws_vpc.my_vpc.id
    route  {
       cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id

    }
  
}

resource "aws_route_table_association" "public_rta" {
    route_table_id = aws_route_table.my_pb_rt.id
    count = length(aws_subnet.my_public_subnet)
    subnet_id = element( aws_subnet.my_public_subnet[*].id, count.index)
  
}

resource "aws_route_table" "my_pv_rt" {
    vpc_id = aws_vpc.my_vpc.id
    route  {
       cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_nat.id

    }
  
}

resource "aws_route_table_association" "private_rta" {
    route_table_id = aws_route_table.my_pv_rt.id
    count= length(aws_subnet.my_private_subnet)
    subnet_id = element(aws_subnet.my_private_subnet[*].id, count.index)
  
}


resource "aws_security_group" "my_alb_sg" {
    vpc_id = aws_vpc.my_vpc.id

    ingress  {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
  egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }
  

}

resource "aws_lb" "app_lb" {
  
  name_prefix = "app-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.my_alb_sg.id]
  subnets = aws_subnet.my_private_subnet[*].id
  }

resource "aws_lb_listener" "app_listener"{
load_balancer_arn = aws_lb.app_lb.arn
port = 80
protocol = "HTTP"
default_action {
  type = "forward"
  target_group_arn = aws_lb_target_group.blue_tgt.arn
}

}

resource "random_pet" "app" {

    length    = 2
    separator = "-"
  
}
