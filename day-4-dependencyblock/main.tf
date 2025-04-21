resource "aws_instance" "name" {
  
ami = "ami-00a929b66ed6e0de6"
instance_type= "t2.micro"
  
}
resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    depends_on = [ aws_instance.name ]
  
}