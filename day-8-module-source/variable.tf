variable "aws_region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID"
  default     = "" 
}

variable "instance_type" {
  default = ""
}

variable "key_name" {
  description = ""
  default = ""
}
