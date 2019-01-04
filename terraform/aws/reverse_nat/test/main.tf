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

################# private instance for bastion demo ######################

data "aws_subnet_ids" "dw_private_subnets" {
  vpc_id = "${local.vpc_id}"
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}
data "aws_subnet" "private_subnet1" {
  id = "${data.aws_subnet_ids.dw_private_subnets.ids[0]}"
}

resource "aws_instance" "bastion_demo" {
  ami                         = "ami-001b0e20a92d8db1e"  # ubuntu-bionic-18.04-amd64-server
  availability_zone           = "${data.aws_subnet.private_subnet1.availability_zone}"
  subnet_id                   = "${data.aws_subnet.private_subnet1.id}"
  private_ip                  = "10.188.2.89"
  vpc_security_group_ids      = ["${module.nat.bastion_security_group_id}"]
  associate_public_ip_address = false
  source_dest_check           = true
  monitoring                  = false
  instance_type               = "t2.nano"
  key_name                    = "terraform"

  tags {
    Name = "private instance for bastion demo"
    Stage = "${local.stage}"
    Instance = "${local.instance}"
    Application = "${local.application_name}"
  }
}
