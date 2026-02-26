# resource "aws_instance" "primary_instance" {
#   provider = aws.primary
#   ami = data.aws_ami.primary_ami.id
#   instance_type = "t3.micro"
#   subnet_id = aws_subnet.primary_subnet.id
#   security_groups = [aws_security_group.primary_sg.name]
#   key_name = var.key_pair_name
#   associate_public_ip_address = true
#   instance_tenancy = "default"  
# }