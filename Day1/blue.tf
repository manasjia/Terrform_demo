
resource "aws_instance" "blue"{
    count = length(aws_subnet.my_private_subnet)
  ami = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  subnet_id = element(aws_subnet.my_private_subnet[*].id, count.index)
  vpc_security_group_ids =[aws_security_group.web-sg.id]
  user_data = templatefile("${path.module}/userdata.sh", {
    file_content = "version 1.0 - #${count.index}"
  })

}

resource "aws_lb_target_group" "blue_tgt" {
  name     = "blue-tg-${random_pet.app.id}-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

resource "aws_lb_target_group_attachment" "blue" {
  count            = length(aws_instance.blue)
  target_group_arn = aws_lb_target_group.blue_tgt.arn
  target_id        = aws_instance.blue[count.index].id
  port             = 80
}

