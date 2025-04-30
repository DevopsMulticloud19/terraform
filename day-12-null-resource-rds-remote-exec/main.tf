# Store DB creds in Secrets Manager
resource "aws_secretsmanager_secret" "rds_secret" {
  name = "rds-mysql-credentials-s"
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = "adminn"
    password = "YourSecurePassword123!"
  })
}

resource "aws_vpc" "cust_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pub" {
  cidr_block = "10.0.0.0/24"
  vpc_id     = aws_vpc.cust_vpc.id
}

resource "aws_subnet" "pri" {
  cidr_block         = "10.0.1.0/24"
  vpc_id             = aws_vpc.cust_vpc.id
  availability_zone  = "us-east-1a"
}

resource "aws_subnet" "pri_b" {
  cidr_block         = "10.0.2.0/24"
  vpc_id             = aws_vpc.cust_vpc.id
  availability_zone  = "us-east-1b"
}

resource "aws_internet_gateway" "cust_IG" {
  vpc_id = aws_vpc.cust_vpc.id
}

resource "aws_eip" "ngw" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.pub.id
}

resource "aws_route_table" "cust_rt" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cust_IG.id
  }
}

resource "aws_route_table" "cust_rt_1" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}

resource "aws_route_table_association" "pri_sub" {
  subnet_id      = aws_subnet.pri.id
  route_table_id = aws_route_table.cust_rt_1.id
}

resource "aws_route_table_association" "pri_sub_b" {
  subnet_id      = aws_subnet.pri_b.id
  route_table_id = aws_route_table.cust_rt_1.id
}

resource "aws_route_table_association" "cust_rt_association" {
  subnet_id      = aws_subnet.pub.id
  route_table_id = aws_route_table.cust_rt.id
}

resource "aws_security_group" "cust_sg" {
  name        = "cust-security-group"
  description = "Allow SSH, HTTP, MySQL"
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

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
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

resource "aws_db_subnet_group" "default" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.pri.id, aws_subnet.pri_b.id]
}

resource "aws_db_instance" "mysql_rds" {
  identifier              = "mydb"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = jsondecode(aws_secretsmanager_secret_version.rds_secret_value.secret_string)["username"]
  password                = jsondecode(aws_secretsmanager_secret_version.rds_secret_value.secret_string)["password"]
  db_name                 = "dev"
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.cust_sg.id]
  publicly_accessible     = false
  skip_final_snapshot     = true
}

 resource "aws_instance" "sql_runner" {
  ami                         = "ami-0e449927258d45bc4"
  instance_type               = "t2.micro"
  key_name                    = "terraform"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.pub.id
  vpc_security_group_ids      = [aws_security_group.cust_sg.id]

  tags = {
    Name = "SQL Runner"
  }
}


resource "null_resource" "remote_sql_exec" {

   triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/HP/Downloads/terraform.pem")
    host        = aws_instance.sql_runner.public_ip
  }

  provisioner "file" {
    source      = "init.sql"
    destination = "/tmp/init.sql"
  }
  provisioner "remote-exec" {
  inline = [
    "echo 'Installing MySQL client...'",
    "sudo yum install -y mariadb",

    "echo 'Checking MySQL version...'",
    "mysql --version",

    "echo 'Checking init.sql exists...'",
    "test -f /tmp/init.sql && echo 'init.sql found' || echo 'init.sql NOT found'",

    "echo 'Running SQL script...'",
    "mysql -h ${aws_db_instance.mysql_rds.address} -u ${local.db_username} -p${local.db_password} dev < /tmp/init.sql || echo 'MySQL command failed'"
  ]
}




  

   
  }
  locals {
  db_username = jsondecode(aws_secretsmanager_secret_version.rds_secret_value.secret_string)["username"]
  db_password = jsondecode(aws_secretsmanager_secret_version.rds_secret_value.secret_string)["password"]
}

