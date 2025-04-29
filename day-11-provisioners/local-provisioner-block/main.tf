resource "aws_instance" "example" {
  ami           = "ami-0e449927258d45bc4"
  instance_type = "t2.micro"
  tags = {
    Name = "null resource"
  }

  provisioner "local-exec" {
    command = "echo Instance public IP is ${self.public_ip} > instance_info.txt"
  }
}