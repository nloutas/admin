provider "aws" {
  region  = "eu-west-1"
  version = "~> 1.30"
}

locals {
  vpc_id   = "vpc-05830c7e9bc3bc2b8"  // dw VPC
  vpc_cidr_block = "10.188.0.0/16"

  instance = "nikos"
  stage    = "dev"
  application_name = "demo"
  instance_key_name = "terraform"
  office_cidr_block   = "213.214.18.25/32" // office access IP 

  // define all AZs, as aurora ignores terraform and deploys in all AZs anyway
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  dns_name = "dev-nikos-data-warehouse.czu79lvs4ots.eu-west-1.redshift.amazonaws.com"
  port = 5439

  route53_zone = "dev.emnify.io."
}


module "nat" {
  source = "../"
  stage    = "${local.stage}"
  instance = "${local.instance}"

  application        = "${local.application_name}"
  availability_zones = "${local.availability_zones}"
  vpc_id             = "${local.vpc_id}"
  vpc_cidr_block     = "${local.vpc_cidr_block}"

  office_cidr_block  = "${local.office_cidr_block}"
  db_dns_name = "${local.dns_name}"
  db_port = "${local.port}"

  route53_zone = "${local.route53_zone}"
}
