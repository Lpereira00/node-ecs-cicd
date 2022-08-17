
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.59.0"

  name = "vpc-module-${var.project_name}"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr
#  database_subnets = var.database_subnets_cidr

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

