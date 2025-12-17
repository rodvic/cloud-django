#!/bin/bash
set -e

# Install Docker service
sudo apt-get update
sudo apt-get install -y docker.io

# Configure Docker service to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Build Docker image
cd /tmp/django-app
sudo docker build --pull -t cloud-django:${APP_VERSION} .
