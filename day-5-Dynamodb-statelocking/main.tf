resource "aws_instance" "name" {
    ami = "ami-00a929b66ed6e0de6"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    tags = {
        Name = "test"
    }

#  lifecycle {
#  prevent_destroy = true
#  }
   

# lifecycle {
#  ignore_changes = [ tags, ]
#    }

# lifecycle {
#  create_before_destroy = true
#    }


}