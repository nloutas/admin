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
  default = "vpc-peering"
}
 
variable "availability_zones" {
  type = "list"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
 
variable "core_vpc_id" {
  description = "Id of core VPC"
} 
 
variable "vpc_cidr_block" {
  description = "CIDR for new VPC"
  default = "10.0.0.0/16"
}

