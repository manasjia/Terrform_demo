resource "aws_instance" "testdemo" {
    instance_type = "t2.micro"
    ami = "ami-0427090fd1714168b"
    subnet_id = "subnet-06c2935a0c09c5594"

    tags = {
        Name= "testdemo"
    }
  
}

resource "aws_ami_from_instance" "testdemo" {
    name = "test-demo"
    source_instance_id = aws_instance.testdemo.id
    snapshot_without_reboot = true

    depends_on = [ aws_instance.testdemo ]
  
}

