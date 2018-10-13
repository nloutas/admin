module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.stage}-${var.instance}-${var.application}-dw-vpc"
  cidr = "${var.vpc_cidr_block}"

  azs             = ["${var.availability_zones}"]
  private_subnets = ["${list(cidrsubnet(var.vpc_cidr_block, 8, 0),  cidrsubnet(var.vpc_cidr_block, 8, 1), cidrsubnet(var.vpc_cidr_block, 8, 2))}"]
  public_subnets  = ["${list(cidrsubnet(var.vpc_cidr_block, 8, 10),  cidrsubnet(var.vpc_cidr_block, 8, 11), cidrsubnet(var.vpc_cidr_block, 8, 12))}"]

  enable_s3_endpoint = true
  enable_nat_gateway = true
  enable_vpn_gateway = false  
  enable_dns_hostnames = true 
  enable_dns_support = true

  tags = {
    Stage = "${var.stage}"
    Instance = "${var.instance}"
    Application = "${var.application}"
  }
}

resource "aws_vpc_peering_connection" "dw-vpc-peering" {
  peer_vpc_id   = "${var.core_vpc_id}"
  vpc_id        = "${module.vpc.vpc_id}"
  auto_accept   = true  // requires that both VPCs belong to the same AWS account
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "VPC peering"
    Stage = "${var.stage}"
    Instance = "${var.instance}"
    Application = "${var.application}"
  }
}

# add routing for both core and dw VPCs through the aws_vpc_peering_connection 
data "aws_route_tables" "core_vpc" {
  vpc_id = "${var.core_vpc_id}"
}
resource "aws_route" "core_vpc_to_peering_conn_route" {
  count                     = "${length(data.aws_route_tables.core_vpc.ids)}"
  route_table_id            = "${data.aws_route_tables.core_vpc.ids[count.index]}"
  destination_cidr_block    = "${var.vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.dw-vpc-peering.id}"

  depends_on = ["aws_vpc_peering_connection.dw-vpc-peering"]
}

// route traffic from DW to core VPC through aws_vpc_peering_connection
data "aws_route_tables" "dw_vpc" {
  vpc_id = "${module.vpc.vpc_id}"
}
data "aws_vpc" "core_vpc" {
  id = "${var.core_vpc_id}"
}
resource "aws_route" "dw_vpc_to_peering_conn_route" {
    count                   = 5
//  count                     = "${coalesce(length(data.aws_route_tables.dw_vpc.ids), 5)}"
  route_table_id            = "${data.aws_route_tables.dw_vpc.ids[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.core_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.dw-vpc-peering.id}"

  depends_on = ["aws_vpc_peering_connection.dw-vpc-peering", "module.vpc"]
}
