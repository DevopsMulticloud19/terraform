resource "aws_vpc" "cust_vpc" {
cidr_block = "10.0.0.0/16"   
enable_dns_support   = true       
enable_dns_hostnames = true 
  
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

resource "aws_route_table" "cust_rt" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cust_IG.id
  }  
}
resource "aws_route_table_association" "pri-sub" {
  subnet_id = aws_subnet.pri.id
  route_table_id = aws_route_table.cust_rt.id
  
}
resource "aws_route_table_association" "cust_rt_association" {
    subnet_id = aws_subnet.pub.id
    route_table_id = aws_route_table.cust_rt.id
  
}
resource "aws_db_subnet_group" "subnet" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.pub.id, aws_subnet.pri.id] 
  tags = {
    Name = "My DB Subnet Group"
  }
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
resource "aws_db_instance" "mydb" {
  identifier             = "mydb-instance"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "admin"
  password               = "Admin123" 
  db_name                = "terraform_db"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true

  vpc_security_group_ids = [aws_security_group.cust_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.subnet.id

  publicly_accessible    = true
  multi_az               = false
  storage_encrypted      = true
  backup_retention_period = 7

  tags = {
    Name        = "terraform_db"
    Environment = "dev"
  }
}

resource "aws_db_instance" "mydb_replica" {
  identifier          = "mydb-replica"
  replicate_source_db = aws_db_instance.mydb.arn
  instance_class      = "db.t3.micro"

  publicly_accessible = true  
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_instance.mydb.db_subnet_group_name
  vpc_security_group_ids = aws_db_instance.mydb.vpc_security_group_ids

  tags = {
    Name        = "terraform_db_replica"
    Environment = "dev"
    Role        = "read-replica"
  }
}
