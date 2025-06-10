# Example 03 - Create Networking Resources and EC2 Instance with modules

This example demonstrates how to create networking resources such as VPC, subnets, internet gateway, and route tables using Terraform, along with an EC2 instance using modules.

## Prerequisites

- Run docker container with Terraform builded from aws/terraform directory: [docker build and run instructions](../README.md)

```bash
cd example_02
```

## Terraform Initialization

Before running the Terraform commands, ensure you have initialized the Terraform configuration. This step downloads the necessary provider plugins.

```bash
terraform init
```

## Use pre-configured ssh key

If you want to use a pre-configured SSH key for your EC2 instance, you can specify the key name in the `variables.tf` file or directly in the `main.tf` file. Make sure the key pair exists in your AWS account.

[Generating SSH key](../../README.md#Create-a-key-pair)

## Terraform Plan

To see what changes Terraform will make to your AWS environment, run the following command. This generates an execution plan without making any changes.

> You can use the `-out` option to save the plan to a file for later execution:

```bash
terraform plan -out=tfplan
```

## Terraform Apply

To apply the changes defined in your Terraform configuration, run the following command. This will create the networking resources in your AWS account.

> After running this command, Terraform will prompt you to confirm the changes. Type `yes` to proceed.

```bash
terraform apply tfplan
```
