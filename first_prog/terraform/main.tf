provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_vpc" "batel_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "batel-vpc"
  }
}

resource "aws_subnet" "batel_public_subnet" {
  vpc_id     = aws_vpc.batel_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "batel_public_subnet"
  }
}

resource "aws_subnet" "batel_private_subnet" {
  vpc_id     = aws_vpc.batel_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "batel_private_subnet"
  }
}


resource "aws_security_group" "batel_app_sg" {
  name        = "batel_app_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.batel_vpc.id

  tags = {
    Name = "batel_app_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "batel_app_sg_engress" {
  security_group_id = aws_security_group.batel_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all ports
}

resource "aws_security_group" "batel_rds_sg" {
  name        = "batel_rds_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.batel_vpc.id

  tags = {
    Name = "batel_rds_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "batel_rds_sg_engress" {
  security_group_id = aws_security_group.batel_rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all ports
}

resource "aws_vpc_security_group_ingress_rule" "batel_rds_allow_app_to_db" {
  security_group_id = aws_security_group.batel_rds_sg.id
  referenced_security_group_id = aws_security_group.batel_app_sg.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "batel_app_allow_my_ip" {
  security_group_id = aws_security_group.batel_app_sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
