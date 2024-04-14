terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
    access_key = var.accesskey
    secret_key = var.secretkey
    region  = "ap-southeast-2"
}
