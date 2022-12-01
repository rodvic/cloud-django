# Azure Deployment

> From root repository path

- Install requirements:

~~~
python3 -m venv azure-venv
source azure-venv/bin/activate
pip install -r django/requirements.txt
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

> From path: ./django

~~~
python manage.py runserver
~~~

> NOTE: http://127.0.0.1:8000/

## Build django docker

> From path: ./django

~~~
docker build --pull -t azure-django:latest .
~~~

### Run from docker local

~~~
docker run --rm -p 8000:8000 azure-django:latest
~~~

> NOTE: http://127.0.0.1:8000/

# Azure Active Directory

> NOTE: you can use an azurecli client in docker for az commands:

~~~
docker run --rm -it mcr.microsoft.com/azure-cli bash
~~~

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
az acr list -o tsv

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

- Username: adminuser

- Image: Ubuntu Server 18.04 LTS

- SSH Access:

~~~
ssh adminuser@PUBLICIP
sudo -i
~~~

- configure vm and docker run:

~~~
# Install docker service
apt-get update
apt-get install -y docker.io curl

# Install AZ CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# AZ login
az login --use-device-code

# Container Registry login
az acr login --name proupsaacr

# Docker Run
docker run -d -p 8000:8000 proupsaacr.azurecr.io/azure-django:latest
~~~

> Add port 8000 to Network Security Group

## Create command with ssh-keys

~~~
# Create VM
az vm create -n MyVm -g pro-upsa-acr \
            --image ubuntults --size Standard_DS2_v2 \
            --generate-ssh-keys

# Connect
ssh $(whoami)@PUBLICIP
~~~

# Azure Deployment Services

## Container Instances

### Deploy from template

> URL: https://portal.azure.com/#create/Microsoft.Template

- file: ./templates/container_service.json
  * Change <REGISTRY_NAME> and <REGISTRY_PASSWORD> for imageRegistryCredentials

## AKS

> From root repository path

~~~
# Create AKS
az aks create --resource-group pro-upsa-acr --name myAKSCluster --node-count 1 --generate-ssh-keys

# AKS List
az aks list -o tsv

# Install kubectl-cli
az aks install-cli

# Connect with kubectl
az aks get-credentials --resource-group pro-upsa-acr --name myAKSCluster --admin

# Create kubernetes resources
## Change <REGISTRY_NAME> and <REGISTRY_PASSWORD> for upsa-registry secret
### Encode .dockerconfigjson to base64. Example:
####  .dockerconfigjson: >-
####    eyAiYXV0aHMiOg==

kubectl apply -f ./kubernetes/resources.yml

# List all kubernetes resources
kubectl -n upsa get all

# Run other pod and get bash
kubectl -n upsa run -it --rm mypod --image=ubuntu:18.04 -- bash
~~~

# Other Azure Services

## Database Services

## Databricks
