resource "aws_instance" "primary_instance" {
  provider = aws.primary
  ami = data.aws_ami.primary_ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.primary_subnet.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]

  key_name = var.primary_key_name
  associate_public_ip_address = true

  user_data = local.primary_user_data

  tags = {
    Name = "Primary-Instance-${var.primary_region}"
    Environment = "Development"
  }
}

resource "aws_instance" "secondary_instance" {
  provider = aws.secondary
  ami = data.aws_ami.secondary_ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.secondary_subnet.id
  vpc_security_group_ids = [aws_security_group.secondary_sg.id]

  key_name = var.secondary_key_name
  associate_public_ip_address = true

  user_data = local.secondary_user_data

  tags = {
    Name = "Secondary-Instance-${var.secondary_region}"
    Environment = "Development"
  }
}