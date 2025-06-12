module "vpc" {
  source               = "./modules/vpc"
  cidr_block           = "10.3.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Environment = "example_03"
    Name        = "example_03_vpc"
  }
}

module "subnets" {
  source = "./modules/subnet"
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
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
  tags = {
    Environment = "example_03"
    Name        = "example_03_igw"
  }
}

module "route_internet" {
  source                 = "./modules/route"
  route_table_id         = module.vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.igw.igw_id
}

module "allow_ssh" {
  source            = "./modules/security_group_rule"
  security_group_id = module.vpc.default_security_group_id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH from anywhere"
}
