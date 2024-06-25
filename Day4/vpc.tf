resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidar
    tags = {
      Name = "my_vpc"
    }
  
}

data "aws_availability_zones" "available" {
  
}

resource "aws_subnet" "my_pub_sub" {
    count = var.instance_count
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidar, 8, count.index)
    availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))
    
    map_public_ip_on_launch = true
    
    
    tags = {
      Name = "my_pub_sub"
    }
  }

  resource "aws_subnet" "my_priv_sub" {
    count = var.instance_count
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidar, 8 , count.index+3)
    availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available))
    

    tags = {
      Name = "my_priv_sub"
    }
    
  }

  resource "aws_internet_gateway" "my-igw" {

    vpc_id = aws_vpc.my_vpc.id
    
       
    tags = {
      name = "my-igw"
    }
            
  }

resource "aws_route_table" "my_pub_rt" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"

        gateway_id = aws_internet_gateway.my-igw.id
    }
     
    tags = {
      Name = "my_pub_rt"
    }
  
}

resource "aws_route_table" "my-priv-rt" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      Name = "my_priv_rt"
    }
  
}

resource "aws_route_table_association" "my_pub_sub_ass" {
    route_table_id = aws_route_table.my_pub_rt.id
    subnet_id = aws_subnet.my_pub_sub[count.index].id
    count = var.instance_count

     
}

resource "aws_security_group" "my-sg" {
    vpc_id = aws_vpc.my_vpc.id
    
    ingress {
        to_port = "0"
        from_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        
    }

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

