resource "aws_db_instance" "this" {
  identifier              = var.db_instance_name
  allocated_storage       = var.allocated_storage
  engine                  = var.engine
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true

  publicly_accessible     = true   # (optional, depends on your security rules)
}

