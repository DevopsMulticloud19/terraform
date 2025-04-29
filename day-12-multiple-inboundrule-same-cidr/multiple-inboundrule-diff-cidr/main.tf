resource "aws_security_group" "devops_project_satya" {
  name        = "devops_project_satya"
  description = "Security group for DevOps project"

  ingress {
    description = "SSH access from office network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.94.195.28/32"]  # Add /32 to specify a single IP
  }

  ingress {
    description = "HTTP access for public users"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access for public users"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
