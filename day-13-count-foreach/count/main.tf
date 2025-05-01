# resource "aws_instance" "name" {
#     ami = "ami-00a929b66ed6e0de6"
#     instance_type = "t2.micro"
#     key_name = "terraform"
#     availability_zone = "us-east-1a"
#     count = 2
#     tags = {
#       Name = "dev"
#     }
  
# }

  
# }
############################### Example-2 Different names #############
# variable "env" {
#     type = list(string)
#     default = ["test","prod"]
# }
# resource "aws_instance" "name" {
#     ami = "ami-00a929b66ed6e0de6"
#     instance_type = "t2.micro"
#     key_name = "terraform"
#     count = length(var.env)

#     tags = {
#       Name = var.env[count.index]
#     }

  
# }

# ## example-2 with variables list of string 

# variable "ami" {
#   type    = string
#   default = "ami-00a929b66ed6e0de6"
# }

# variable "instance_type" {
#   type    = string
#   default = "t2.micro"
# }

# variable "satya" {
#   type    = list(string)
#   default = ["one","two"]
# }

# # main.tf
# resource "aws_instance" "satya" {
#   ami           = var.ami
#   instance_type = var.instance_type
#   count         = length(var.satya)

#   tags = {
#     Name = var.satya[count.index]
#   }
# }

# #example-3 creating IAM users 
# # variable "user_names" {
# #   description = "IAM usernames"
# #   type        = list(string)
# #   default     = ["user1", "user2", "user3"]
# # }
# # resource "aws_iam_user" "example" {
# #   count = length(var.user_names)
# #   name  = var.user_names[count.index]
# # }