resource "aws_internet_gateway" "myig" {
    vpc_id = aws_vpc.myvpc.id
  
}

resource "aws_route_table" "myrtb" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block ="0.0.0.0/0"
        gateway_id = aws_internet_gateway.myig.id
    }
   tags= {
    Name = "Public Subnet Route Table"
}
}

resource "aws_subnet" "publicsubnet" {
    count = 2
    vpc_id = aws_vpc.myvpc.id
    availability_zone = "${element(var.availability_zone, count.index)}"
    cidr_block = "${cidrsubnet(var.cidr, 2 ,  count.index+2 )}"
   tags= {
    Name = "Public Subnet ${count.index + 1}"
  }
} 

resource "aws_route_table_association" "public_subnet_rta" {
  count          = 2
  subnet_id      = "${aws_subnet.publicsubnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.myrtb.id}"
}