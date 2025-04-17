resource "aws_instance" "name" {
    ami = var.ami_id
    instance_type = var.size_types
    iam_instance_profile = var.iam_role
    
}