variable "aws_profile" {
    type = string
    default = "profile_needed"
}
variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "vpc_cidr" {
    type = string

}
variable "environment" {
    type = string
}
variable "account_id" {
    type = string
}
variable "availability_zones" {
    type = list
}

variable "private_subnets_cidr" {
    type = list
}

variable "public_subnets_cidr" {
    type = list
}

variable "ecr_repo_name" {
    type = string
}

variable "project_name" {
    type = string
}

variable "vpc_id" {
    type        = string
    description = "(Optional) Name of the target vpc you want to stand up infra in."
    # default     = "vpc-035326b64d88ae469"
}
