output "instance_id" {
  value = aws_instance.app_node.id
}

output "public_ip" {
  value = aws_instance.app_node.public_ip
}

output "private_ip" {
  value = aws_instance.app_node.private_ip
}
