# Example 03 - Ubuntu with django Docker Image on AWS

This example demonstrates how to create a custom Ubuntu-based with a django Docker image on AWS using Packer.

> Reference: [Variables](https://developer.hashicorp.com/packer/tutorials/aws-get-started/aws-get-started-variables)

## Prerequisites

- Run docker container with Terraform, Packer and AWS CLI builded from aws/packer directory: [docker build and run instructions](../README.md)

```bash
cd example_03
```

## Add variable to template

In this example, we will add a variable to specify `region` and `instance_type` of instance to be used for building the AMI, as well as a variable for the Django Docker image tag `app_version`.

```hcl
variable "region" {
  type    = string
  default = "eu-west-1"
}

# ...
```

## Add local to template

In this example, we will add a local to specify `cloud_tags` to be used for tagging the AMI.

```hcl
locals {
  common_tags = {
    Environment = "example_03"
    Name        = "example_03_django_app"
  }
}
```

## Add data source to template

In this example, we will add a data source to fetch the latest Ubuntu 22.04 AMI ID.

```hcl
data "amazon-ami" "ubuntu" {
  filters = {
    name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}
```

## Using django demo app from repository

In this example, we will clone a [django demo app located in this repository](../../../django/README.md) and build as Docker image using the specified `app_version` tag.

- Copy django app to the instance

```hcl
  provisioner "file" {
    source      = "../../../django"
    destination = "/tmp/django-app"
  }
```

- Install docker service and build docker image with setup-django script

```hcl
  provisioner "shell" {
    script = "scripts/setup-django.sh"
    environment_vars = [
      "APP_VERSION=${var.app_version}"
    ]
  }
```

## Packer Initialization

Before running the Packer commands, ensure you have initialized the Packer configuration. This step downloads the necessary plugins.

```bash
packer init .
```

## Packer Formatting

Format your template. Packer will print out the names of the files it modified, if any. In this case, your template file was already formatted correctly, so Packer won't return any file names.

```bash
packer fmt .
```

## Packer Validation

Validate your template. If Packer detects any invalid configuration, Packer will print out the file name, the error type and line number of the invalid configuration. The example configuration provided above is valid, so Packer will return nothing.

```bash
packer validate .
```

## Building the AMI

Build the image with the packer build command. Packer will print output similar to what is shown below.

### Using default variable values

```bash
packer build .
```

### Passing variables via command line

You can override the default variable values using the `-var` flag:

```bash
packer build -var 'region=eu-west-1' -var 'instance_type=t2.micro' -var 'app_version=1.0.0' .
```

### Passing variables via variable file

Create a variable file (e.g., `prod.pkrvars.hcl`):

```hcl
region        = "eu-west-1"
instance_type = "t2.micro"
app_version   = "1.0.0"
```

Then build with the variable file:

```bash
packer build -var-file="prod.pkrvars.hcl" .
```

### Passing variables via environment variables

You can also set variables using environment variables with the `PKR_VAR_` prefix:

```bash
export PKR_VAR_region="eu-west-1"
export PKR_VAR_instance_type="t2.micro"
export PKR_VAR_app_version="1.0.0"
packer build .
```

## Retrieving the AMI ID

- Get the AMI ID created by Packer:

```bash
EXAMPLE_03_AMI_ID=$(aws ec2 describe-images --owners self --filters "Name=name,Values=example-03-django-app-*" --query 'Images | sort_by(@, &CreationDate)[-1].ImageId' --output text)
```

## Using the AMI from Terraform (example_03)

After successfully creating the AMI with Packer, you can use the AMI ID in your Terraform configurations to launch EC2 instances with the custom image.

- [Change AMI ID in ec2.tf file - terraform/example_03](../../terraform/example_03/ec2.tf#L22)

```hcl
module "ec2" {
  source                        = "./modules/ec2_instance"
  ami                           = "ami-03fd334507439f4d1" # Replace with your Packer-built AMI ID

  # ...
}
```

- [Add user data to start django app container on instance boot in ec2.tf file - terraform/example_03](../../terraform/example_03/ec2.tf#L36)

```hcl
module "ec2" {
  # ...

  user_data = <<-EOF
    #!/bin/bash
    # use build docker image from packer - cloud-django:APP_VERSION
    docker run -d --restart always -p 8000:8000 cloud-django:1.0.0
  EOF
}
```

- [Allow HTTP on port 8000 from anywhere creating security group rule in network.tf file - terraform/example_03](../../terraform/example_03/network.tf#L67)

```hcl
# Allow traffic to port 8000
module "allow_8000" {
  source            = "./modules/security_group_rule"
  security_group_id = module.vpc.default_security_group_id
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP on port 8000 from anywhere"
}
```

- Terraform Apply

```bash
# Navigate to the terraform/example_03 directory
pushd ../../terraform/example_03

# Initialize and apply the Terraform configuration
terraform init
terraform apply
```

- After the EC2 instance is running, you can access the nginx web server by navigating to `http://<EC2_INSTANCE_PUBLIC_IP>:8000` in your web browser.

- Terraform Destroy

```bash
terraform destroy

# Return to the previous directory (packer/example_03)
popd
```

## Cleanup AMI and Snapshot

```bash
aws ec2 deregister-image --delete-associated-snapshots --image-id ${EXAMPLE_03_AMI_ID}
```
