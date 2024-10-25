terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.68"
    }
  }
}
provider "aws" {
  region = "ap-south-1"
}