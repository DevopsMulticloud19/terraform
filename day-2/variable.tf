variable "ami_id" {
    type = string
    default = "ami-00a929b66ed6e0de6"
  
}
variable "size_types" {
    type = string
    default = "t2.micro"
  
}
variable "iam_role" {
    type = string 
    default = "cloudwatchlogs"
  
}
