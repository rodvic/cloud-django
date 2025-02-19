# Django build

> Reference: https://www.djangoproject.com/start/

## Initial requirements

> From root repository path

- Install requirements:

~~~
python3 -m venv azure-venv
source azure-venv/bin/activate
pip install -r django/requirements.txt
~~~

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

> Reference: https://docs.docker.com/get-started/

> From path: ./django

~~~
docker build --load --pull -t azure-django:latest .
~~~

### Run from docker local

~~~
docker run --rm -p 8000:8000 azure-django:latest
~~~

> NOTE: http://127.0.0.1:8000/

# Azure services

> NOTE: you can use an azurecli client in docker for az commands:

~~~
docker run --rm -it mcr.microsoft.com/azure-cli bash
~~~

# Azure Active Directory

> Reference: https://azure.microsoft.com/en-us/products/active-directory/

- Secure your environment with multicloud identity and access management

## App registrations

- New app
- Certificates & secrets | New client secret
  * Get AZURE_TENANT_ID - Directory (tenant) ID
  * Get AZURE_CLIENT_ID - Application (client) ID
  * Get AZURE_CLIENT_SECRET - Client secret

# Subscriptions

- Get AZURE_SUBSCRIPTION_ID - Subscription ID

## Access control (IAM)

- Assign permissions (roles) to user/app on a subscription

## Resource providers

## azurecli login commands

~~~
# AZ login with user/password
az login --use-device-code

## OR
## AZ login with service-principal (AZURE_TENANT_ID / AZURE_CLIENT_ID / AZURE_CLIENT_SECRET)
az login --service-principal -u <AZURE_CLIENT_ID> -p "<AZURE_CLIENT_SECRET>" --tenant <AZURE_TENANT_ID>

# List subscriptions
az account show

# Change default subscription
az account set -s <AZURE_SUBSCRIPTION_ID>
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

> Reference: https://docs.microsoft.com/en-gb/azure/container-registry/container-registry-get-started-docker-cli

- An Azure container registry stores and manages private container images and other artifacts, similar to the way Docker Hub stores public Docker container images.

## Create Container registries

- resource group: pro-upsa-acr
- name: proupsaacr
- sku: basic

~~~
# Create registry
az acr create -n proupsaacr -g pro-upsa-acr --sku basic

# Enable Administrator Account
az acr update -n proupsaacr --admin-enabled true

# List registries
az acr list -o tsv

# List access keys (username/passwords) of registry
az acr credential show --name proupsaacr

# Container Registry login (automatic docker login)
az acr login --name proupsaacr

## OR
## docker login container registry
docker login proupsaacr.azurecr.io
~~~

## Docker push to registry

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

## VM create command with ssh-keys

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

> Reference: https://azure.microsoft.com/en-gb/products/container-instances/#overview

- Easily run containers on Azure without managing servers.

### Deploy from template

> URL: https://portal.azure.com/#create/Microsoft.Template

- file: ./templates/container_service.json
  * Change <REGISTRY_NAME> and <REGISTRY_PASSWORD> for imageRegistryCredentials

## Azure Kubernetes Service (AKS)

> Reference: https://azure.microsoft.com/en-gb/products/kubernetes-service/

- Build and scale with managed Kubernetes

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

> Reference: https://azure.microsoft.com/en-gb/products/category/databases/

- Azure offers a choice of fully managed relational, NoSQL, and in-memory databases, spanning proprietary and open-source engines, to fit the needs of modern app developers.

## Storage accounts

> Reference: https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview

- An Azure storage account contains all of your Azure Storage data objects, including blobs, file shares, queues, tables, and disks.

## Azure HDInsight

> Reference: https://azure.microsoft.com/en-gb/products/hdinsight/#features

- Provision cloud Hadoop, Spark, R Server, HBase, and Storm clusters

## Databricks

> Reference: https://azure.microsoft.com/en-gb/products/databricks/

- Design AI with Apache Spark™-based analytics

> Tutorial: Query data with notebooks: https://learn.microsoft.com/en-us/azure/databricks/getting-started/quick-start

> Tutorial: ML engineering: https://learn.microsoft.com/en-us/azure/databricks/getting-started/ml-quick-start
