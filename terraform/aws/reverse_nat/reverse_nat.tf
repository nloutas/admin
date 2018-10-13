
locals {
  prefix = "${var.stage}-${var.instance}-${var.application}"
}

# SG for NAT instance
resource "aws_security_group" "nat" {
  name        = "${local.prefix}-nat"
  description = "allow NAT traffic in ${var.application}"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name        = "NAT instance SG"
    Stage       = "${var.stage}"
    Instance    = "${var.instance}"
    Application = "${var.application}"
  }
}

resource "aws_security_group_rule" "nat_allow_forwarding_cidr_blocks" {
  security_group_id = "${aws_security_group.nat.id}"
  type              = "ingress"
  protocol          = "TCP"
  from_port         = "${var.db_port}"
  to_port           = "${var.db_port}"
  cidr_blocks       = ["${var.nat_allowed_cidr_blocks}"]
  description       = "allow forwarding from specific CIDR ranges"
}

resource "aws_security_group_rule" "nat_allow_ssh_from_office" {
  security_group_id = "${aws_security_group.nat.id}"
  type              = "ingress"
  protocol          = "TCP"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = ["${var.office_cidr_block}"]
  description       = "allow SSH access from office"
}

resource "aws_security_group_rule" "nat_allow_all_outbound" {
  security_group_id = "${aws_security_group.nat.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow all outbound"
}

# NAT instance user-data to enable IPv4 forwarding and iptables rules for DB access
data "template_file" "nat_user_data" {
  template = "${file("${path.module}/files/nat-forwarding-config.sh.tmpl")}"

  vars {
    vpc_cidr_block          = "${data.aws_vpc.selected.cidr_block}"
    db_port                 = "${var.db_port}"
    db_public_dns           = "${var.db_dns_name}"
    nat_allowed_cidr_blocks = "${join(",", var.nat_allowed_cidr_blocks)}"
  }
}
 
data "aws_ami" "ubuntu-bionic" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
data "aws_subnet" "public1" {
  id = "${data.aws_subnet_ids.public.ids[0]}"
}
resource "aws_instance" "reverse_nat" {
  ami                         = "${data.aws_ami.ubuntu-bionic.id}"
  availability_zone           = "${data.aws_subnet.public1.availability_zone}"
  subnet_id                   = "${data.aws_subnet.public1.id}"
  vpc_security_group_ids      = ["${aws_security_group.nat.id}"]
  associate_public_ip_address = true
  source_dest_check           = false // disable source/destination checks on the NAT instance
  monitoring                  = false // false=basic monitoring, true=detailed
  instance_type               = "${var.nat_instance_type}"
  key_name                    = "${var.ec2_instance_key_name}"
  user_data                   = "${data.template_file.nat_user_data.rendered}"

  tags {
    Name = "NAT instance"
    Stage = "${var.stage}"
    Instance = "${var.instance}"
    Application = "${var.application}"
  }
}

# route to send outgoing traffic from private subnets to the NAT instance
data "aws_route_tables" "vpc_private" {
  vpc_id = "${var.vpc_id}"
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}
resource "aws_route" "private_subnets_to_nat" { 
  count                     = "${coalesce(length(data.aws_route_tables.vpc_private.ids), 3)}"
  route_table_id            = "${data.aws_route_tables.vpc_private.ids[count.index]}"
  destination_cidr_block    = "0.0.0.0/0" 
  instance_id               = "${aws_instance.reverse_nat.id}"

  depends_on = ["aws_instance.reverse_nat"]
}

# route53 record for NAT instance
data "aws_route53_zone" "net" {
  name         = "${var.route53_zone}"
  private_zone = false
}
resource "aws_route53_record" "reverse_nat_instance" {
  zone_id = "${data.aws_route53_zone.net.zone_id}"
  name    = "${local.prefix}.${var.route53_zone}"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.reverse_nat.public_ip}"]
  depends_on = ["aws_instance.reverse_nat"]
 
}