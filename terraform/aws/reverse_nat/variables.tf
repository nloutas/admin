#####
# Basics and VPC
#####
variable "stage" {
  description = "tag for stage, e.g. 'dev', 'prod'"
}

variable "instance" {
  description = "tag for instance, e.g. 'company name', 'client name'"
}

variable "application" {
  description = "tag for application"
  default = "reverse-nat"
}
 
variable "availability_zones" {
  type = "list"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
 
variable "vpc_id" {}

variable "vpc_cidr_block" {}
 
variable "office_cidr_block" {
  description = "CIDR block to allow access from office" 
}


#######
# NAT instance vars
#######
variable "db_port" {
  description = "port of target DB"
}
variable "db_dns_name" {
  description = "DNS name of target DB"
}

variable "nat_instance_type" {
  default = "t2.micro"
}

variable "ec2_instance_key_name" {
  description = "SSH Key to connect to the EC2 instances in the VPC public subnets"
  default = "terraform"
}

variable "nat_allowed_cidr_blocks" {
  type = "list"
  description = "allow specific CIDR ranges on NAT instances for forwarding"
  default = [
    "213.214.18.25/32",  # office_cidr_block 
    "107.23.195.228/32", # BI platform 
  ]
}

variable "route53_zone" {
  description = "Apex of Route53 Zone"
  default = "my.net."
}

