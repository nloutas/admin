# SG for Bastion instance
resource "aws_security_group" "bastion" {
  name        = "${var.stage}-${var.instance}-${var.application}-bastion"
  description = "allow SSH to Bastion"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name        = "Bastion instance SG"
    Stage       = "${var.stage}"
    Instance    = "${var.instance}"
    Application = "${var.application}"
  }
}

resource "aws_security_group_rule" "bastion_allow_ssh_from_office" {
  security_group_id = "${aws_security_group.bastion.id}"
  type              = "ingress"
  protocol          = "TCP"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = ["${var.office_cidr_block}"]
  description       = "allow SSH access from office"
}

resource "aws_security_group_rule" "bastion_allow_ssh_from_self" {
  security_group_id = "${aws_security_group.bastion.id}"
  type              = "ingress"
  protocol          = "TCP"
  from_port         = "22"
  to_port           = "22"
  self              = true
  description       = "allow SSH access from self"
}

resource "aws_security_group_rule" "bastion_allow_ssh_outbound" {
  security_group_id = "${aws_security_group.bastion.id}"
  type              = "egress"
  protocol          = "TCP"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = ["${data.aws_vpc.selected.cidr_block}"]
  description       = "allow SSH outbound"
}

resource "aws_security_group_rule" "nat_allow_ssh_from_bastion" {
  security_group_id = "${aws_security_group.nat.id}"
  type              = "ingress"
  protocol          = "TCP"
  from_port         = "22"
  to_port           = "22"
  source_security_group_id = "${aws_security_group.bastion.id}"
  description       = "allow SSH access from Bastion Instance"
}

# gather data
data "aws_ami" "ubuntu_bionic" {
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

# bastion is necessary for NAT terraform module
resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.ubuntu_bionic.id}"
  availability_zone           = "${data.aws_subnet.public1.availability_zone}"
  subnet_id                   = "${data.aws_subnet.public1.id}"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  associate_public_ip_address = true
  source_dest_check           = true
  monitoring                  = false   
  instance_type               =  "t2.nano"  
  key_name                    = "${var.ec2_instance_key_name}"


  tags {
    Name = "bastion instance"
    Stage = "${var.stage}"
    Instance = "${var.instance}"
    Application = "${var.application}"
  }
}

resource "aws_route53_record" "bastion_instance" {
  zone_id = "${data.aws_route53_zone.net.zone_id}"
  name    = "${var.stage}-${var.instance}-bastion.${var.route53_zone}"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.bastion.public_ip}"]
  depends_on = ["aws_instance.bastion"]
}
