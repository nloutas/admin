provider "aws" {
  version = "~> 1.30"
  region  = "eu-west-1"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
 
