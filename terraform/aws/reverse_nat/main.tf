provider "aws" {
  version = "~> 1.30"
  region  = "eu-west-1"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "public" {
  vpc_id = "${var.vpc_id}"
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}
data "aws_subnet_ids" "private" {
  vpc_id = "${var.vpc_id}"
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}
