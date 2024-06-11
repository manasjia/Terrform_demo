resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"

    enable_dns_hostnames = true
  
}

resource "aws_subnet" "public_sub" {
    depends_on = [aws_vpc.my_vpc] 
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = "us-east-1a"
    cidr_block = "10.0.0.0/24"
map_public_ip_on_launch = true
  
}

resource "aws_subnet" "private_sub" {

    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"

    depends_on = [ aws_vpc.my_vpc,aws_subnet.public_sub ]
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    
 
}

resource "aws_route_table" "my_rtb" {
vpc_id = aws_vpc.my_vpc.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
    
}
  
}

resource "aws_route_table_association" "my_rtb_ass" {
    subnet_id = aws_subnet.public_sub.id
    route_table_id = aws_route_table.my_rtb.id   
  
}


resource "aws_eip" "Nat-Gateway-EIP" {
    depends_on = [aws_route_table_association.my_rtb_ass  ]

}

resource "aws_nat_gateway" "my_nat_gw" {
    depends_on = [ aws_eip.Nat-Gateway-EIP ]
    subnet_id = aws_subnet.private_sub.id
    allocation_id = aws_eip.Nat-Gateway-EIP.id
  
}


resource "aws_route_table" "my_natgw_rtb" {
  vpc_id = aws_vpc.my_vpc.id
  route  {
    cidr_block="0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gw.id
  }
  
}
resource "aws_route_table_association" "nat_gw_rtbasso" {
route_table_id = aws_route_table.my_natgw_rtb.id
subnet_id = aws_subnet.private_sub.id

}
resource "aws_security_group" "WS_SG" {
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        description = " For HTTP"
        to_port = 80
        from_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

     ingress{
        description = " for ping"
        to_port = 0
        from_port = 0
        protocol = "ICMP"
        cidr_blocks = ["0.0.0.0/0"]

     }
     ingress {
        description = "For SSH"
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
     }
     egress {
        description = "output from webserver"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
     }
    
    }

    resource "aws_security_group" "mysql_sg" {
        vpc_id = aws_vpc.my_vpc.id

        ingress {
            description = "Input for MySQL"
            to_port = 3306
            from_port = 3306
            protocol = "tcp"
            security_groups = [aws_security_group.WS_SG.id]
        }
      
      egress {
        description = "output from MySQL"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
  
  resource "aws_security_group" "Bast_host_sg" {
    name= "Bast-host-sg"
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        description = " Bastion Host SG"
        to_port = 0
        from_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
    egress {
        description = "output for Bastion Host"
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  }

# Creating security group for MySQL Bastion Host Access

resource "aws_security_group" "DB-BH-sg" {
    name = "mysql-bastion-host-sg"
   vpc_id = aws_vpc.my_vpc.id

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.Bast_host_sg.id]
   }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    
   }
}

# creating instances for webserver 

resource "aws_instance" "webserver" {

ami = "ami-04b70fa74e45c3917"
instance_type = "t2.micro"
subnet_id = aws_subnet.public_sub.id
key_name = "New-demo-keys"

vpc_security_group_ids = [aws_security_group.WS_SG.id]
tags = {
  name= " Webserver"
}

connection {
host = aws_instance.webserver.public_ip
type = "ssh"
user="ubuntu"
private_key = file("C:/Users/manas/Desktop/New-demo-keys.pem")
  
}

provisioner "remote-exec" {
    inline = [
        "sudo apt-get update -y",
        "sudo apt-get install php php-mysqlnd apache2 -y",
        "wget https://wordpress.org/wordpress-4.8.14.tar.gz",
        "tar -xzf wordpress-4.8.14.tar.gz",
        "sudo mkdir /var/www",
        "sudo mkdir /var/www/html",
        "sudo cp -r wordpress /var/www/html/",
        "sudo systemctl start apache2",
        "sudo systemctl enable apache2",
        "sudo systemctl restart apache2"
    ]
  }
    
  
}


resource "aws_instance" "MySQL" {

ami = "ami-04b70fa74e45c3917"
instance_type = "t2.micro"
subnet_id = aws_subnet.private_sub.id
key_name = "New-demo-keys"

vpc_security_group_ids = [aws_security_group.mysql_sg.id, aws_security_group.DB-BH-sg.id]

tags = {
    name = " MySQL server"
}


  
}

resource "aws_instance" "bastion-host" {
ami = "ami-04b70fa74e45c3917"
instance_type = "t2.micro"
subnet_id = aws_subnet.public_sub.id
key_name = "New-demo-keys"
vpc_security_group_ids = [aws_security_group.Bast_host_sg.id]
tags = {
  name= " Bastion Server"
}

  
}