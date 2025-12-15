# Example 01 - build an AWS Ubuntu AMI

This example demonstrates how to build an AWS Ubuntu AMI using Packer.

> Reference: [Build an image](https://developer.hashicorp.com/packer/tutorials/aws-get-started/aws-get-started-build-image)

## Prerequisites

- Run docker container with Terraform, Packer and AWS CLI builded from aws/packer directory: [docker build and run instructions](../README.md)

```bash
cd example_01
```

## Packer template

A Packer template is a configuration file that defines the image you want to build and how to build it. Packer templates use the Hashicorp Configuration Language (HCL).

- The `packer` block contains Packer settings, including specifying a required Packer version.

- The `source` block configures a specific builder plugin, which is then invoked by a build block. Source blocks use builders and communicators to define what kind of virtualization to use, how to launch the image you want to provision, and how to connect to it.

- The `build` block defines what Packer should do with the EC2 instance after it launches.

## Packer Initialization

Before running the Packer commands, ensure you have initialized the Packer configuration. This step downloads the necessary plugins.

```bash
packer init .
```

- Example output if not previously initialized:

```bash
Installed plugin github.com/hashicorp/amazon v1.3.9 in "/root/.config/packer/plugins/github.com/hashicorp/amazon/packer-plugin-amazon_v1.3.9_x5.0_linux_amd64"
```

- List installed plugins:

```bash
packer plugins installed
```

- Example output:

```bash
/root/.config/packer/plugins/github.com/hashicorp/amazon/packer-plugin-amazon_v1.3.9_x5.0_linux_amd64
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

- Output:

```bash
The configuration is valid.
```

## Building the AMI

Build the image with the packer build command. Packer will print output similar to what is shown below.

```bash
packer build .
```

- Example output:

```bash
example-01.amazon-ebs.ubuntu: output will be in this color.

==> example-01.amazon-ebs.ubuntu: Prevalidating any provided VPC information
==> example-01.amazon-ebs.ubuntu: Prevalidating AMI Name: example-01-linux-aws
    example-01.amazon-ebs.ubuntu: Found Image ID: ami-0f27749973e2399b6
==> example-01.amazon-ebs.ubuntu: Creating temporary keypair: packer_693e9eb1-8204-0b0d-d223-92694fbed11f
==> example-01.amazon-ebs.ubuntu: Creating temporary security group for this instance: packer_693e9eb4-660c-ed40-3b7e-23f6881587bd
==> example-01.amazon-ebs.ubuntu: Authorizing access to port 22 from [0.0.0.0/0] in the temporary security groups...
==> example-01.amazon-ebs.ubuntu: Launching a source AWS instance...
    example-01.amazon-ebs.ubuntu: Instance ID: i-0912e50b767ed3c12
==> example-01.amazon-ebs.ubuntu: Waiting for instance (i-0912e50b767ed3c12) to become ready...
==> example-01.amazon-ebs.ubuntu: Using SSH communicator to connect: 176.34.159.0
==> example-01.amazon-ebs.ubuntu: Waiting for SSH to become available...
==> example-01.amazon-ebs.ubuntu: Connected to SSH!
==> example-01.amazon-ebs.ubuntu: Stopping the source instance...
    example-01.amazon-ebs.ubuntu: Stopping instance
==> example-01.amazon-ebs.ubuntu: Waiting for the instance to stop...
==> example-01.amazon-ebs.ubuntu: Creating AMI example-01-linux-aws from instance i-0912e50b767ed3c12
==> example-01.amazon-ebs.ubuntu: Attaching run tags to AMI...
    example-01.amazon-ebs.ubuntu: AMI: ami-002738ad6a4079cf8
==> example-01.amazon-ebs.ubuntu: Waiting for AMI to become ready...
==> example-01.amazon-ebs.ubuntu: Skipping Enable AMI deprecation...
==> example-01.amazon-ebs.ubuntu: Skipping Enable AMI deregistration protection...
==> example-01.amazon-ebs.ubuntu: Terminating the source AWS instance...
==> example-01.amazon-ebs.ubuntu: Cleaning up any extra volumes...
==> example-01.amazon-ebs.ubuntu: No volumes to clean up, skipping
==> example-01.amazon-ebs.ubuntu: Deleting temporary security group...
==> example-01.amazon-ebs.ubuntu: Deleting temporary keypair...
Build 'example-01.amazon-ebs.ubuntu' finished after 4 minutes 10 seconds.

==> Wait completed after 4 minutes 10 seconds

==> Builds finished. The artifacts of successful builds are:
--> example-01.amazon-ebs.ubuntu: AMIs were created:
eu-west-1: ami-002738ad6a4079cf8
```

## Managing the Image

Packer only builds images. It does not attempt to manage them in any way. After they're built, it is up to you to launch or destroy them as you see fit.

- To list your AMIs using AWS CLI, run:

```bash
aws ec2 describe-images --owners self
```

- Example output:

```bash
{
    "Images": [
        {
            "PlatformDetails": "Linux/UNIX",
            "UsageOperation": "RunInstances",
            "BlockDeviceMappings": [
                {
                    "Ebs": {
                        "DeleteOnTermination": true,
                        "SnapshotId": "snap-05f12ad6d88ff7380",
                        "VolumeSize": 8,
                        "VolumeType": "gp2",
                        "Encrypted": false
                    },
                    "DeviceName": "/dev/sda1"
                },
                {
                    "DeviceName": "/dev/sdb",
                    "VirtualName": "ephemeral0"
                },
                {
                    "DeviceName": "/dev/sdc",
                    "VirtualName": "ephemeral1"
                }
            ],
            "EnaSupport": true,
            "Hypervisor": "xen",
            "Name": "example-01-linux-aws",
            "RootDeviceName": "/dev/sda1",
            "RootDeviceType": "ebs",
            "SriovNetSupport": "simple",
            "VirtualizationType": "hvm",
            "BootMode": "uefi-preferred",
            "SourceInstanceId": "i-0912e50b767ed3c12",
            "DeregistrationProtection": "disabled",
            "SourceImageId": "ami-0f27749973e2399b6",
            "SourceImageRegion": "eu-west-1",
            "FreeTierEligible": true,
            "ImageId": "ami-002738ad6a4079cf8",
            "ImageLocation": "985539770271/example-01-linux-aws",
            "State": "available",
            "OwnerId": "985539770271",
            "CreationDate": "2025-12-14T11:27:57.000Z",
            "Public": false,
            "Architecture": "x86_64",
            "ImageType": "machine"
        }
    ]
}
```

- Get the AMI ID created by Packer:

```bash
EXAMPLE_01_AMI_ID=$(aws ec2 describe-images --owners self --filters "Name=name,Values=example-01-ubuntu" --query 'Images | sort_by(@, &CreationDate)[-1].ImageId' --output text)
```

- List from AWS Management Console: [Amazon Machine Images (AMIs) - owned-by-me](https://eu-west-1.console.aws.amazon.com/ec2/home?region=eu-west-1#Images:visibility=owned-by-me)

## Launch an EC2 Instance from the AMI

You can launch an EC2 instance from the created AMI using the AWS Management Console or AWS CLI.

- Launch from AWS Management Console: [Launch Instance Wizard](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#LaunchInstanceWizard:)

## Cleanup AMI and Snapshot

You can remove the AMI by first deregistering it on the AWS AMI management page. Next, delete the associated snapshot on the AWS snapshot management page. It is important to delete the snapshot after deregistering the AMI to avoid incurring storage costs.

- Deregister AMI: [Amazon Machine Images (AMIs) - owned-by-me](https://eu-west-1.console.aws.amazon.com/ec2/home?region=eu-west-1#Images:visibility=owned-by-me)

- Delete snapshot: [Snapshots](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Snapshots:)

- Alternatively, you can use the AWS CLI to deregister the AMI and delete the snapshot in one command by using the `--delete-associated-snapshots` flag:

```bash
aws ec2 deregister-image --delete-associated-snapshots --image-id ${EXAMPLE_01_AMI_ID}
```

- Example output:

```bash
{
    "Return": true,
    "DeleteSnapshotResults": [
        {
            "SnapshotId": "snap-05f12ad6d88ff7380",
            "ReturnCode": "success"
        }
    ]
}
```
