output "primary_vpc_id" {
  value = aws_vpc.primary_vpc.id
}

output "secondary_vpc_id" {
  value = aws_vpc.secondary_vpc.id
}

output "primary_instance_public_ip" {
  value = aws_instance.primary_instance.public_ip
}

output "secondary_instance_public_ip" {
  value = aws_instance.secondary_instance.public_ip
}
