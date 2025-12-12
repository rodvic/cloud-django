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

# Variable for S3 bucket name
variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

# Create a S3 bucket
resource "aws_s3_bucket" "bucket_01" {
  bucket = var.s3_bucket_name

  tags = {
    Environment = "example_01"
    Name        = "proupsa-example-01"
  }
}

# Output the S3 bucket name
output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.bucket_01.id
}
