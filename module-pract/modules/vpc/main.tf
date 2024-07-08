resource "aws_vpc" "vpc" {
  
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.projectname}-vpc"
  }

}
resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
      Name = "my-igw"
    }
  
}
data "aws_availability_zones" "availability_zones" {}

resource "aws_subnet" "public_subnet_az1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnet_az1_cidr
    availability_zone = data.aws_availability_zones.availability_zones.names[0]
    map_public_ip_on_launch = true

    tags = {
      Name = " public_subnet_az1"
    }
  
}

resource "aws_subnet" "public_subnet_az2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnet_az2_cidr
    availability_zone = data.aws_availability_zones.availability_zones.names[1]
    map_public_ip_on_launch = true

    tags = {
      Name = " public_subnet_az2"
    }
  
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id
    
    route  {
        cidr_block= "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw.id
        
    }

    tags = {
      Name = "public_route_table"
    }
      
}

resource "aws_route_table_association" "route_table_assc_public_subnet_az1" {
    route_table_id = aws_route_table.public_route_table.id
    subnet_id = aws_subnet.public_subnet_az1.id

    
}


resource "aws_route_table_association" "route_table_assc_public_subnet_az2" {
    route_table_id = aws_route_table.public_route_table.id
    subnet_id = aws_subnet.public_subnet_az2.id

    
}

resource "aws_subnet" "private_subnet_az1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private_subnet_az1_cidr 
    availability_zone = data.aws_availability_zones.availability_zones.names[0]
    map_public_ip_on_launch = false

    tags = {
      Name = "private-subnet-az1"
    }
}

resource "aws_subnet" "private_subnet_az2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private_subnet_az2_cidr 
    availability_zone = data.aws_availability_zones.availability_zones.names[1]
    map_public_ip_on_launch = false

    tags ={
        Name = "private-subnet-az2"
    }
}

