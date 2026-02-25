terraform {
  backend "s3" {
    bucket = "tf-state-bootstrap-5aa1a0fb"
    key    = "project_1/terraform.tfstate"
    region = "ap-southeast-1"
    use_lockfile = true
    encrypt = true
  }
}
