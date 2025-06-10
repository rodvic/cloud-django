terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source               = "../modules/vpc"
  cidr_block           = "10.3.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Environment = "example_03"
    Name        = "example_03_vpc"
  }
}

module "subnets" {
  source = "../modules/subnet"
  vpc_id = module.vpc.vpc_id
  subnets = {
    subnet_01 = {
      cidr_block = "10.3.1.0/24"
      az         = "eu-west-1a"
      tags = {
        Environment = "example_03"
        Name        = "example_03_subnet_01"
      }
    }
    subnet_02 = {
      cidr_block = "10.3.2.0/24"
      az         = "eu-west-1b"
      tags = {
        Environment = "example_03"
        Name        = "example_03_subnet_02"
      }
    }
    subnet_03 = {
      cidr_block = "10.3.3.0/24"
      az         = "eu-west-1c"
      tags = {
        Environment = "example_03"
        Name        = "example_03_subnet_03"
      }
    }
  }
}

module "igw" {
  source = "../modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
  tags = {
    Environment = "example_03"
    Name        = "example_03_igw"
  }
}

module "route_internet" {
  source                 = "../modules/route"
  route_table_id         = module.vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.igw.igw_id
}

module "allow_ssh" {
  source            = "../modules/security_group_rule"
  security_group_id = module.vpc.default_security_group_id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH from anywhere"
}

module "allow_8000" {
  source            = "../modules/security_group_rule"
  security_group_id = module.vpc.default_security_group_id
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH from anywhere"
}

module "ec2" {
  source                        = "../modules/ec2_instance"
  ami                           = "ami-03fd334507439f4d1"
  instance_type                 = "t2.micro"
  key_name                      = "proupsa-ec2-key-pair"
  subnet_id                     = module.subnets.subnet_ids[0] # Using the first subnet for the instance
  associate_public_ip_address   = true
  security_group_ids            = [module.vpc.default_security_group_id]
  tags = {
    Environment = "example_03"
    Name        = "example_03_ec2_instance"
  }

  volume_size                   = 8
  volume_type                   = "gp3"
  delete_on_termination         = true
  encrypted                     = false
  iops                          = 3000
  throughput                    = 125

  cpu_credits                   = "standard"
  http_endpoint                 = "enabled"
  http_put_response_hop_limit   = 2
  http_tokens                   = "required"

  hostname_type                 = "ip-name"
  enable_resource_name_dns_a_record  = false
  enable_resource_name_dns_aaaa_record = false

  instance_count                = 1
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
output "subnet_ids" {
  value = module.subnets.subnet_ids
}
output "ec2_instance_id" {
  value = module.ec2.instance_id
}
output "ec2_instance_public_ip" {
  value = module.ec2.public_ip
}
output "ec2_instance_public_dns" {
  value = module.ec2.public_dns
}
