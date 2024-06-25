resource "aws_instance" "master-server" {
    count = var.instance_count
   subnet_id = aws_subnet.my_pub_sub[count.index].id
   ami = var.ami
   instance_type = var.instance_type
   vpc_security_group_ids = [aws_security_group.my-sg.id ]
   
   tags = {
     Name= " Master-server"
   }
    
  
}

