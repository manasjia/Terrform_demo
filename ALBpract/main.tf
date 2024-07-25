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

