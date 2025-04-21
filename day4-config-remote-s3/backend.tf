
terraform {
  backend "s3" {
    bucket = "remoteconfigstatefile"
    key    = "statefile.tf"
    region = "us-east-1"
  }
}
