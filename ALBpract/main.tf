<<<<<<< HEAD
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


// alb 

resource "aws_lb" "myalb" {

   
    internal = false
    load_balancer_type = "application"
    subnets = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]
    security_groups = [aws_security_group.myswg.id]
    
    }
resource "aws_lb_target_group" "mylbtg" {
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.my_vpc.id
    health_check {
    path = "/"
    port = "traffic-port"
  }
  
}
resource "aws_lb_target_group_attachment" "mytgA1" {
  target_group_arn = aws_lb_target_group.mylbtg.arn
  target_id = aws_instance.webserver1.id
  port = 80
  
}

resource "aws_lb_target_group_attachment" "mytgA2" {
  target_group_arn = aws_lb_target_group.mylbtg.arn
  target_id = aws_instance.webserver2.id
  port = 80
}
resource "aws_lb_listener" "name" {
    load_balancer_arn = aws_lb.myalb.arn
     port              = 80
     protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.mylbtg.arn
    type             = "forward"
  }
}
output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}
  
      
=======
resource "aws_vpc" "myvpc" {
    cidr_block = "${var.cidr}"
    tags = {
        Name="Myvpc"
    }
  
}
resource "aws_subnet" "mysubnet" {
vpc_id = aws_vpc.myvpc.id
count = 2
availability_zone = "${element(var.availability_zone, count.index)}"
cidr_block = "${cidrsubnet(var.cidr, 2, count.index)}"
  tags= {
    Name = "Web subnet ${count.index +1}"
  }
}

resource "aws_instance" "myinstance" {
    count = 2
    ami = "${lookup(var.ami_id, "us-east-1a")}"
    instance_type = "t2.micro"
    subnet_id = "${element(aws_subnet.mysubnet.*.id , count.index % length(aws_subnet.mysubnet.*.id))}"
    user_data = "${file("userdata.sh")}"
  
    tags= {
    Name = "Web Server ${count.index + 1}"
  }


}
>>>>>>> 350e76c (alb project)
