terraform {
  backend "s3" {
    bucket = "tf-state-4983a5f7"
    key    = "project_1/terraform.tfstate"
    region = "ap-southeast-1"
    encrypt = true
  }
}
