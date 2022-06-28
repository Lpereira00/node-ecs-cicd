#resource "aws_vpc" "main_vpc" {
#  cidr_block           = "${var.vpc_cidr}"
#  enable_dns_hostnames = true
#  enable_dns_support   = true
#  tags = {
#    Name        = "${var.environment}-vpc"
#    Environment = "${var.environment}"
#  }
#}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
#resource "aws_internet_gateway" "ig" {
#  vpc_id = "${aws_vpc.main_vpc.id}"
#  tags = {
#    Name        = "${var.environment}-igw"
#    Environment = "${var.environment}"
#  }
#}
/* Elastic IP for NAT */
#resource "aws_eip" "nat_eip" {
#  vpc        = true
#  depends_on = [aws_internet_gateway.ig]
#}
/* NAT */
#resource "aws_nat_gateway" "nat" {
#  allocation_id = "${aws_eip.nat_eip.id}"
#  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
#  depends_on    = [aws_internet_gateway.ig]
#  tags = {
#    Name        = "nat"
#    Environment = "${var.environment}"
#  }
#}
/* Public subnet */
#resource "aws_subnet" "public_subnet" {
#  vpc_id                  = "${aws_vpc.main_vpc.id}"
#  count                   = "${length(var.public_subnets_cidr)}"
#  cidr_block              = "${element(var.public_subnets_cidr,   count.index)}"
#  availability_zone       = "${element(var.availability_zones,   count.index)}"
#  map_public_ip_on_launch = true
#  tags = {
#    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
#    Environment = "${var.environment}"
#  }
#}
/* Private subnet */
#resource "aws_subnet" "private_subnet" {
#  vpc_id                  = "${aws_vpc.main_vpc.id}"
#  count                   = "${length(var.private_subnets_cidr)}"
#  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
#  availability_zone       = "${element(var.availability_zones,   count.index)}"
#  map_public_ip_on_launch = false
#  tags = {
#    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
#    Environment = "${var.environment}"
#  }
#}
#/* Routing table for private subnet */
#resource "aws_route_table" "private" {
#  vpc_id = "${aws_vpc.main_vpc.id}"
#  tags = {
#    Name        = "${var.environment}-private-route-table"
#    Environment = "${var.environment}"
#  }
#}
/* Routing table for public subnet */
#resource "aws_route_table" "public" {
#  vpc_id = "${aws_vpc.main_vpc.id}"
#  tags = {
#    Name        = "${var.environment}-public-route-table"
#    Environment = "${var.environment}"
#  }
#}
#resource "aws_route" "public_internet_gateway" {
#  route_table_id         = "${aws_route_table.public.id}"
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id             = "${aws_internet_gateway.ig.id}"
#}
#resource "aws_route" "private_nat_gateway" {
#  route_table_id         = "${aws_route_table.private.id}"
#  destination_cidr_block = "0.0.0.0/0"
#  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
#}
/* Route table associations */
#resource "aws_route_table_association" "public" {
#  count          = "${length(var.public_subnets_cidr)}"
#  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
#  route_table_id = "${aws_route_table.public.id}"
#}

#resource "aws_network_acl" "public_acl" {
#  vpc_id      = aws_vpc.main_vpc.id
#  egress {
#    protocol   = "tcp"
#    rule_no    = 200
#    action     = "allow"
#    cidr_block = aws_subnet.public_subnet[0].cidr_block
#    from_port  = 0
#    to_port    = 0
#  }
#
#  ingress {
#    protocol   = "tcp"
#    rule_no    = 100
#    action     = "allow"
#    cidr_block = aws_subnet.public_subnet[1].cidr_block
#    from_port  = 0
#    to_port    = 0
#  }
#    tags = {
#      Environment = "${var.environment}"
#    }
#  }

#resource "aws_network_acl_association" "acl_assoc_1" {
#  network_acl_id = aws_network_acl.public_acl.id
#  subnet_id      = aws_subnet.public_subnet[0].id
#}
#
#resource "aws_network_acl_association" "acl_assoc_2" {
#  network_acl_id = aws_network_acl.public_acl.id
#  subnet_id      = aws_subnet.public_subnet[1].id
#}
#resource "aws_vpc_endpoint" "ecr_api" {
#  service_name = "com.amazonaws.us-east-1.ecr.api"
#  vpc_id       = aws_vpc.main_vpc.id
#  vpc_endpoint_type = "Interface"
#  subnet_ids        = [for subnet in aws_subnet.public_subnet : subnet.id]
#  security_group_ids = [aws_security_group.default.id]
#}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.59.0"

  name = "vpc-module-${var.project_name}"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
#  enable_logs_endpoint = true
#  logs_endpoint_security_group_ids = [aws_security_group.ecs-demo.id]
#  enable_s3_endpoint = true
#  enable_ecr_dkr_endpoint = true
#  ecr_dkr_endpoint_security_group_ids = [aws_security_group.ecs-demo.id]
#  enable_ecr_api_endpoint = true
#  ecr_api_endpoint_security_group_ids = [aws_security_group.ecs-demo.id]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "terraform-cloudpipeline-${var.project_name}"
  }
}
