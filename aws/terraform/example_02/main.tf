terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

# Create a VPC
resource "aws_vpc" "vpc_01" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Environment = "example_02"
    Name        = "example_02_vpc"
  }
}

# Create subnets
resource "aws_subnet" "subnet_01" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Environment = "example_02"
    Name        = "example_02_subnet_01"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Environment = "example_02"
    Name        = "example_02_subnet_02"
  }
}

resource "aws_subnet" "subnet_3" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = "10.2.3.0/24"
  availability_zone = "eu-west-1c"

  tags = {
    Environment = "example_02"
    Name        = "example_02_subnet_02"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Environment = "example_02"
    Name        = "example_02_igw"
  }
}

# Create a route to the internet through the internet gateway
resource "aws_route" "route_internet" {
  route_table_id         = aws_vpc.vpc_01.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create an output with VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc_01.id
}

# Create an output to subnet ID
output "subnet_ids" {
  description = "The IDs of the subnets"
  value = [
    aws_subnet.subnet_01.id,
    aws_subnet.subnet_2.id,
    aws_subnet.subnet_3.id
  ]
}

# Create an output for default security group ID
output "default_security_group_id" {
  description = "The ID of the default security group"
  value       = aws_vpc.vpc_01.default_security_group_id
}
