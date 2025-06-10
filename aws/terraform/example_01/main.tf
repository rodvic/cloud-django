terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

# Create a S3 bucket
resource "aws_s3_bucket" "bucket_01" {
  bucket = "proupsa-example-01"

  tags = {
    Environment = "example_01"
    Name        = "proupsa-example-01"
  }
}
