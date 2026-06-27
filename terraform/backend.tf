terraform {
  backend "s3" {
    bucket         = "shazna-terraform-state-bucket"
    key            = "platform/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-lock"
  }
}
