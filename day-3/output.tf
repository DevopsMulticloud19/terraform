output  "ip" {
  value = aws_instance.name.public_ip
  sensitive = true
}