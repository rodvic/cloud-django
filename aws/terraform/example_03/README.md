# Example 03 - Create Networking Resources and EC2 Instance with modules

This example demonstrates how to create networking resources such as VPC, subnets, internet gateway, and route tables using Terraform, along with an EC2 instance using modules.

## Prerequisites

- Run docker container with Terraform builded from aws/terraform directory: [docker build and run instructions](../README.md)

```bash
cd example_03
```

## Terraform Initialization

Before running the Terraform commands, ensure you have initialized the Terraform configuration. This step downloads the necessary provider plugins.

```bash
terraform init
```

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

## SSH conection to EC2 Instance

To connect to the EC2 instance created by Terraform, you need to use SSH. A key pair is generated during the Terraform apply process, and you can use it to connect to the instance.

```bash
ssh -i ec2_key.pem ubuntu@<EC2_INSTANCE_PUBLIC_IP>
```

## Terraform Destroy

To clean up and remove all the resources created by Terraform, you can run the destroy command. This will delete all the resources defined in your Terraform configuration.

```bash
terraform destroy
```
