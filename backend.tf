terraform {
  backend "s3" {
    bucket         = "my-bucket-terraform-lab"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
