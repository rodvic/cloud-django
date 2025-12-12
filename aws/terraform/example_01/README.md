# Example 01 - Create an S3 Bucket

This example demonstrates how to create an S3 bucket using Terraform.

> Reference: [Terraform AWS S3 Bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)

## Prerequisites

- Run docker container with Terraform builded from aws/terraform directory: [docker build and run instructions](../README.md)

```bash
cd example_01
```

## Terraform Initialization

Before running the Terraform commands, ensure you have initialized the Terraform configuration. This step downloads the necessary provider plugins.

```bash
terraform init
```

## Terraform Validation

To validate the Terraform configuration, run the following command. This checks for syntax errors and ensures that the configuration is valid.

```bash
terraform validate
```

- Output:

```bash
Success! The configuration is valid.
```

### Validation Warnings

If there are any error or warning in the configuration, the output will indicate what needs to be fixed. For example:

- aws_s3_bucket section with a deprecated argument:

```hcl
resource "aws_s3_bucket" "example_01" {
  bucket = "proupsa-example-01"
  acl    = "private"
}
```

- Output with validation warnings:

```bash
╷
│ Warning: Argument is deprecated
│
│   with aws_s3_bucket.example_01,
│   on main.tf line 16, in resource "aws_s3_bucket" "example_01":
│   16:   acl    = "private"
│
│ acl is deprecated. Use the aws_s3_bucket_acl resource instead.
╵
Success! The configuration is valid, but there were some validation warnings as shown above.
```

## Terraform Format

To format the Terraform configuration files, run the following command. This ensures that the code is properly formatted according to Terraform's style conventions.

```bash
terraform fmt
```

## Terraform Plan

To see what changes Terraform will make to your AWS environment, run the following command. This generates an execution plan without making any changes.

> S3 bucket names must be globally unique. Therefore, we set the bucket name using an environment variable with a timestamp to ensure uniqueness.

```bash
export TF_VAR_s3_bucket_name="proupsa-example-01-$(date +%Y%m%d%H%M%S)"
terraform plan
```

## Terraform Apply

To apply the changes and create the S3 bucket, run the following command. This will prompt for confirmation before proceeding.

```bash
terraform apply
```

- You can also apply without prompting for confirmation by using the `-auto-approve` flag:

```bash
terraform apply -auto-approve
```

## Terraform State

To view the current state of the resources managed by Terraform, you can use the following command. This will show you the resources that have been created and their current status.

```bash
terraform state list
```

To view detailed information about a specific resource, you can use:

```bash
terraform state show aws_s3_bucket.bucket_01
```

## Terraform Destroy

To remove the S3 bucket and any resources created by this configuration, run the following command. This will prompt for confirmation before proceeding.

```bash
terraform destroy
```
