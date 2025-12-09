module "vpc" {
  source               = "./modules/vpc"
  cidr_block           = "10.4.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Environment = "example_04"
    Name        = "example_04_vpc"
  }
}

# Public subnets for EC2
module "public_subnets" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
  subnets = {
    public_subnet_01 = {
      cidr_block = "10.4.1.0/24"
      az         = "eu-west-1a"
      tags = {
        Environment = "example_04"
        Name        = "example_04_public_subnet_01"
        Type        = "public"
      }
    }
    public_subnet_02 = {
      cidr_block = "10.4.2.0/24"
      az         = "eu-west-1b"
      tags = {
        Environment = "example_04"
        Name        = "example_04_public_subnet_02"
        Type        = "public"
      }
    }
    public_subnet_03 = {
      cidr_block = "10.4.3.0/24"
      az         = "eu-west-1c"
      tags = {
        Environment = "example_04"
        Name        = "example_04_public_subnet_03"
        Type        = "public"
      }
    }
  }
}

# Private subnets for RDS
module "private_subnets" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
  subnets = {
    private_subnet_01 = {
      cidr_block = "10.4.10.0/24"
      az         = "eu-west-1a"
      tags = {
        Environment = "example_04"
        Name        = "example_04_private_subnet_01"
        Type        = "private"
      }
    }
    private_subnet_02 = {
      cidr_block = "10.4.11.0/24"
      az         = "eu-west-1b"
      tags = {
        Environment = "example_04"
        Name        = "example_04_private_subnet_02"
        Type        = "private"
      }
    }
    private_subnet_03 = {
      cidr_block = "10.4.12.0/24"
      az         = "eu-west-1c"
      tags = {
        Environment = "example_04"
        Name        = "example_04_private_subnet_03"
        Type        = "private"
      }
    }
  }
}

# Internet Gateway for public access
module "igw" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
  tags = {
    Environment = "example_04"
    Name        = "example_04_igw"
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Environment = "example_04"
    Name        = "example_04_public_route_table"
  }
}

# Route to Internet for public subnets
module "route_internet" {
  source                 = "./modules/route"
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.igw.igw_id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  for_each       = module.public_subnets.subnet_map
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

# Security group for EC2 (public access)
resource "aws_security_group" "ec2" {
  name        = "example_04_ec2_sg"
  description = "Security group for EC2 instance"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Environment = "example_04"
    Name        = "example_04_ec2_sg"
  }
}

module "allow_ssh" {
  source            = "./modules/security_group_rule"
  security_group_id = aws_security_group.ec2.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH from anywhere"
}

module "allow_8000" {
  source            = "./modules/security_group_rule"
  security_group_id = aws_security_group.ec2.id
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP on port 8000 from anywhere"
}

module "allow_ec2_outbound" {
  source            = "./modules/security_group_rule"
  security_group_id = aws_security_group.ec2.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  type              = "egress"
}

# Security group for RDS (private access from EC2)
resource "aws_security_group" "rds" {
  name        = "example_04_rds_sg"
  description = "Security group for RDS instance"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Environment = "example_04"
    Name        = "example_04_rds_sg"
  }
}

module "allow_mysql_from_ec2" {
  source                   = "./modules/security_group_rule"
  security_group_id        = aws_security_group.rds.id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  description              = "Allow MySQL from EC2 security group"
}
