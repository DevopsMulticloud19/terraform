variable "ami" {
  type    = string
  default = "ami-00a929b66ed6e0de6"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "env" {
  type    = list(string)
  default = ["one","two"]
}

resource "aws_instance" "satya" {
  ami           = var.ami
  instance_type = var.instance_type
  for_each      = toset(var.env)
#   count = length(var.env)  

  tags = {
    Name = each.value # for a set, each.value and each.key is the same
  }
}