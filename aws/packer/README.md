# Packer examples for AWS

This directory contains examples of using Packer to manage AWS resources. It includes a Dockerfile to build an image with Terraform, Packer and the AWS CLI installed, allowing you to run Packer commands in a containerized environment.

> Reference: [Packer - Amazon Integration](https://developer.hashicorp.com/packer/integrations/hashicorp/amazon)

The Amazon plugin can be used with HashiCorp Packer to create custom images on AWS. To achieve this, the plugin comes with multiple builders, data sources, and a post-processor to build the AMI depending on the strategy you want to use.

## Building a Docker Image with Terraform, Packer and AWS CLI

This example demonstrates how to build a Docker image that includes Terraform, Packer and the AWS CLI, which can be used for managing AWS resources.

> From aws/packer repository path (using the Dockerfile located in aws/terraform):

```bash
docker build --load -t terraform-packer-awscli . -f ../terraform/Dockerfile
```

## Running the Docker Container

Once the Docker image is built, you can run a container from it. This container will have both Terraform, Packer and the AWS CLI installed, allowing you to manage AWS resources using Terraform and Packer.

> Mount full repository to /workspace in container `$(pwd)/../..` and set working directory to `/workspace/aws/packer`.
>
> Use your AWS credentials as environment variables to authenticate with AWS.

```bash
docker run -it --rm \
  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
  -v $(pwd)/../..:/workspace \
  -w /workspace/aws/packer \
  terraform-packer-awscli \
  /bin/bash
```

## Examples

This directory contains various examples of using Packer with AWS. Each example is in its own subdirectory, and you can run the Packer commands within each subdirectory to manage the respective AWS resources.

- [example_01](./example_01/README.md): build an AWS Ubuntu AMI
- [example_02](./example_02/README.md): Ubuntu with Docker Image on AWS
- [example_03](./example_03/README.md): Ubuntu with django Docker Image on AWS
