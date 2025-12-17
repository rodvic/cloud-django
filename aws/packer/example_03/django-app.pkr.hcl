packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Find the latest Ubuntu 22.04 AMI
data "amazon-ami" "ubuntu" {
  filters = {
    name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "django" {
  ami_name      = "example-03-django-app-${var.app_version}"
  instance_type = var.instance_type
  region        = var.region
  source_ami    = data.amazon-ami.ubuntu.id
  ssh_username  = "ubuntu"
  tags          = local.common_tags
}

build {
  sources = ["source.amazon-ebs.django"]

  # Copy the Django application files to the instance
  provisioner "file" {
    source      = "../../../django"
    destination = "/tmp/django-app"
  }

  # Run the setup script to install Docker and build the Django app
  provisioner "shell" {
    script = "scripts/setup-django.sh"
    environment_vars = [
      "APP_VERSION=${var.app_version}"
    ]
  }
}
