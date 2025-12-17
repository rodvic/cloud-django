# Example 02 - Ubuntu with Docker Image on AWS

This example demonstrates how to create a custom Ubuntu-based with a nginx Docker image on AWS using Packer.

> Reference: [Provision](https://developer.hashicorp.com/packer/tutorials/aws-get-started/aws-get-started-provision)

## Prerequisites

- Run docker container with Terraform, Packer and AWS CLI builded from aws/packer directory: [docker build and run instructions](../README.md)

```bash
cd example_02
```

## Add provisioner to template

Using provisioners allows you to completely automate modifications to your image after it is created. In this example, we will use the shell provisioner to install Docker on the Ubuntu image, start the Docker service, and run a nginx Docker container.

```hcl
build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo docker run -d --restart always --name nginx -p 8000:80 nginx"
    ]
  }
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

```bash
packer build .
```

## Retrieving the AMI ID

- Get the AMI ID created by Packer:

```bash
EXAMPLE_02_AMI_ID=$(aws ec2 describe-images --owners self --filters "Name=name,Values=example-02-ubuntu-docker" --query 'Images | sort_by(@, &CreationDate)[-1].ImageId' --output text)
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

# Return to the previous directory (packer/example_02)
popd
```

## Cleanup AMI and Snapshot

```bash
aws ec2 deregister-image --delete-associated-snapshots --image-id ${EXAMPLE_02_AMI_ID}
```
