# Azure Deployment

> From root repository path

- Install requirements:

~~~
python3 -m venv azure-venv
source azure-venv/bin/activate
pip install -r mysite/requirements.txt
~~~

# Django build

## Create default site

~~~
django-admin startproject mysite
mv mysite/* django
~~~

> NOTE: The content of the created directory is moved to django directory

> NOTE: Already created in reposity

## Run from local

> From path: django

~~~
python manage.py runserver
~~~

> NOTE: http://127.0.0.1:8000/

## Build django docker

> From path: django

~~~
docker build --pull -t azure-django:latest .
~~~

# Azure Active Directory

## App registrations

- New app
- Certificates & secrets | New client secret

# Subscriptions

## Access control (IAM)

- Assign permissions on a subscription -> b4b3803e-5030-42a0-a734-4eda0e4e191e

## Resource providers

## Commands

> Reference: https://docs.microsoft.com/es-es/azure/container-registry/container-registry-get-started-docker-cli

~~~
# AZ login
az login --use-device-code

## OR
az login --service-principal -u ceac1788-70f4-448c-82bf-8d4863b0f704 -p "" --tenant 7058ea36-d3d2-4deb-ae56-8d1217dcdba4

# List subscriptions
az account show

# Change default subscription
az account set -s SUBSCRIPTION_ID
~~~

# Resource group

## Create

- Name: pro-upsa-acr
- Location: northeurope

~~~
# Create
az group create -n pro-upsa-acr -l northeurope

# List
az group list
~~~

# Azure Container Registry

## Create Container registries

- resource group: pro-upsa-acr
- name: proupsaacr
- sku: basic

~~~
# Create
az acr create -n proupsaacr -g pro-upsa-acr --sku basic

# Enable Administrator Account
az acr update -n proupsaacr --admin-enabled true

# List
az acr list

# List access keys
az acr credential show --name proupsaacr

# Container Registry login
az acr login --name proupsaacr
~~~

# Docker build and push

Docker tag:

~~~
docker tag azure-django:latest proupsaacr.azurecr.io/azure-django:latest
~~~

Docker push:

~~~
docker push proupsaacr.azurecr.io/azure-django:latest
~~~

# Azure Virtual Machines

Username: adminuser

Image: Ubuntu Server 18.04 LTS

SSH Access

    ssh adminuser@PUBLICIP
    sudo -i

Install AZ CLI

    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

Install docker service

    sudo apt-get update
    sudo apt-get install -y docker.io

AZ login

    az login --use-device-code

Container Registry login

    az acr login --name proupsaacr

Docker Run

    docker run -d -p 80:80 proupsaacr.azurecr.io/azure-django:latest

> Add port 80 to Network Security Group

## Create command with ssh-keys

~~~
# Create
az vm create -n MyVm -g pro-upsa-acr \
            --image ubuntults --size Standard_DS2_v2 \
            --generate-ssh-keys

# Connect
ssh localuser@PUBLICIP
~~~

# Azure Deployment Services

## App Services

## Container Instances

## AKS

~~~
# Create
az aks create --resource-group pro-upsa-acr --name myAKSCluster --node-count 1

# List
az aks list

# Connect with kubectl
az aks get-credentials --resource-group pro-upsa-acr --name myAKSCluster --admin

# List all pods
kubectl get pods -A

# Run pod
kubectl run -it --rm mypod --image=ubuntu -- bash
~~~

# Other Azure Services

## Database Services

## Databricks
