resource "aws_key_pair" "this" {
  key_name   = "ec2-key-${var.env}"
  public_key = var.public_key
}

resource "aws_instance" "app_node" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.this.key_name

  # Enforce IMDSv2 per Security Standards
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "AppNode-${var.env}"
  }
}
