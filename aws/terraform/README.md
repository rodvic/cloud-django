# Terraform examples for AWS

This directory contains an example of using Terraform to manage AWS resources. It includes a Dockerfile to build an image with Terraform and the AWS CLI installed, allowing you to run Terraform commands in a containerized environment.

> Reference: [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS. You must configure the provider with the proper credentials before you can use it.

## Building a Docker Image with Terraform and AWS CLI

This example demonstrates how to build a Docker image that includes Terraform and the AWS CLI, which can be used for managing AWS resources.

- Docker image with Terraform and AWS CLI installed

> From aws/terraform repository path

```bash
docker build --load -t terraform-awscli .
```

## Running the Docker Container

Once the Docker image is built, you can run a container from it. This container will have both Terraform and the AWS CLI installed, allowing you to manage AWS resources using Terraform.

> Mount full repository to /workspace in container `$(pwd)/../..` and set working directory to `/workspace/aws/terraform`.
>
> Use your AWS credentials as environment variables to authenticate with AWS.

```bash
docker run -it --rm \
  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
  -v $(pwd)/../..:/workspace \
  -w /workspace/aws/terraform \
  terraform-awscli \
  /bin/bash
```

## Examples

This directory contains various examples of using Terraform with AWS. Each example is in its own subdirectory, and you can run the Terraform commands within each subdirectory to manage the respective AWS resources.

- [example_01](./example_01/README.md): Create an S3 Bucket
- [example_02](./example_02/README.md): Create Networking Resources with main.tf
- [example_03](./example_03/README.md): Create Networking Resources and EC2 Instance with modules
