resource "aws_vpc" "cust_vpc" {
cidr_block = "10.0.0.0/16"
  
}
resource "aws_subnet" "pub" {
    cidr_block = "10.0.0.0/24"
    vpc_id = aws_vpc.cust_vpc.id
}
resource "aws_subnet" "pri" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.cust_vpc.id
  
}
resource "aws_internet_gateway" "cust_IG" {
    vpc_id = aws_vpc.cust_vpc.id
}
resource "aws_eip" "ngw" {
  domain = "vpc"
  
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id = aws_subnet.pub.id
  
}
resource "aws_route_table" "cust_rt" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cust_IG.id
  }  
}
resource "aws_route_table" "cust_rt-1" {
  vpc_id = aws_vpc.cust_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id  
  
}
}
resource "aws_route_table_association" "pri-sub" {
  subnet_id = aws_subnet.pri.id
  route_table_id = aws_route_table.cust_rt-1.id
  
}
resource "aws_route_table_association" "cust_rt_association" {
    subnet_id = aws_subnet.pub.id
    route_table_id = aws_route_table.cust_rt.id
  
}
resource "aws_security_group" "cust_sg" {
  name        = "cust-security-group"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.cust_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-sg"
  }
}
resource "aws_instance" "name" {
  ami = "ami-00a929b66ed6e0de6"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pub.id
  key_name = "terraform"
  vpc_security_group_ids = [ aws_security_group.cust_sg.id ]
  associate_public_ip_address = true
  
  
}

resource "aws_instance" "dev" {
  ami = "ami-00a929b66ed6e0de6"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pri.id
  key_name = "terraform"
  vpc_security_group_ids = [ aws_security_group.cust_sg.id ]
  associate_public_ip_address = false
  
  tags = {
    Name = "dev"
  }
}


  