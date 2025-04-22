terraform {
  backend "s3" {
    bucket = "remoteconfigstatefile"
    key    = "statefile.tf"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}
