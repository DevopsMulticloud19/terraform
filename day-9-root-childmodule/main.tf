provider "aws" {
  region = var.region
}

module "ec2_instance" {
  source = "./module/ec2-instance"

  instance_name = "my-ec2"
  instance_type = "t2.micro"
  ami_id        = var.ami_id
}
module "s3_bucket" {
  source      = "./module/s3-bucket"
  bucket_name = "my-bucket-is-always-unique"
}
module "rds_instance" {
  source            = "./modules/rds-instance"
  db_instance_name  = "mydb"
  db_username       = "admin"
  db_password       = "password12345"
  db_instance_class = "db.t3.micro"
  allocated_storage = 20
  engine            = "mysql"
}
