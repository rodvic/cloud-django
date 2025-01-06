> Build django docker image: [Django build](./README.md)

# Google Cloud

> Reference: [Install the gcloud CLI](https://cloud.google.com/sdk/docs/install)

## Installing the Google Cloud CLI Docker image

> Reference: [Installing the Google Cloud CLI Docker image](https://cloud.google.com/sdk/docs/downloads-docker)

```bash
docker run --rm -it gcr.io/google.com/cloudsdktool/google-cloud-cli:stable bash
```

## gcloud client login commands

> Reference: [Run gcloud auth login](https://cloud.google.com/sdk/docs/authorizing#auth-login)

- Login with user/password:

```bash
gcloud auth login
```

# Creating and managing projects

> Reference: [Creating and managing projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects)

- Manage resources / + Create Project
  * Project ID: `proupsa`

```bash
gcloud projects create proupsa
```

- Set current project:

```bash
gcloud config set project proupsa
```

# Identity and Access Management (IAM)

> Reference: [IAM overview](https://cloud.google.com/iam/docs/overview)

IAM lets you grant granular access to specific Google Cloud resources and helps prevent access to other resources. IAM lets you adopt the security principle of least privilege, which states that nobody should have more permissions than they actually need.

## Service accounts

> Reference: [Service accounts overview](https://cloud.google.com/iam/docs/service-account-overview)

### Create Service Account

> Reference: [Create a service account](https://cloud.google.com/iam/docs/service-accounts-create#creating)

- IAM / Service accounts / + Create Service Account
  * Service account ID: `saproupsa`
  * Service account name: `saproupsa`
  * Service account description: `saproupsa`

```bash
gcloud iam service-accounts create saproupsa \
  --description="saproupsa" \
  --display-name="saproupsa"
```

> Email (`SERVICE_ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com`): `saproupsa@proupsa.iam.gserviceaccount.com`

#### To grant your service account an IAM role (Editor) on your project

- Manage resources / proupsa / Permissions / + Add Principal
  * `saproupsa` (Service Account) -> `Editor` (Role)

```bash
gcloud projects add-iam-policy-binding proupsa \
  --member="serviceAccount:saproupsa@proupsa.iam.gserviceaccount.com" \
  --role="roles/editor" \
  --condition=None
```

#### To allow users to attach the service account to other resources

- IAM and admin
  * member: `user:USER_EMAIL` -> your user email

```bash
gcloud iam service-accounts add-iam-policy-binding \
  saproupsa@proupsa.iam.gserviceaccount.com \
  --member="user:USER_EMAIL" \
  --role="roles/iam.serviceAccountUser"
```

# Artifact Registry

> Reference: [Repository overview](https://cloud.google.com/artifact-registry/docs/repositories)

Artifact Registry enables you to store different artifact types, create multiple repositories in a single project, and associate a specific regional or multi-regional location with each repository. 

## Create Container registries

> Reference: [Create standard repositories](https://cloud.google.com/artifact-registry/docs/repositories/create-repos)

- Artifact Registry / Repositories / Create Repository
  * Repository name: proupsaacr
  * Repository format: docker
  * location: europe-southwest1

```bash
# Create registry
gcloud artifacts repositories create proupsaacr \
    --repository-format=docker \
    --location=europe-southwest1

# List registries
gcloud artifacts repositories list
```

## Configure authentication to Artifact Registry for Docker

> Reference: [gcloud CLI credential helper](https://cloud.google.com/artifact-registry/docs/docker/authentication#gcloud-helper)

```bash
# Run the following command to configure gcloud as the credential helper for the Artifact Registry domain associated with this repository's location:
gcloud auth configure-docker \
    europe-southwest1-docker.pkg.dev
```

## Docker push to registry

- Docker tag:

> Format: `LOCATION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE`

```bash
docker tag azure-django:latest europe-southwest1-docker.pkg.dev/proupsa/proupsaacr/azure-django:latest
```

- Docker push:

```bash
docker push europe-southwest1-docker.pkg.dev/proupsa/proupsaacr/azure-django:latest
```

- Artifacts list:

```bash
gcloud artifacts docker images list europe-southwest1-docker.pkg.dev/proupsa/proupsaacr --include-tags
```

# VPC networks

> Reference: [VPC networks](https://cloud.google.com/vpc/docs/vpc)

A Virtual Private Cloud (VPC) network is a virtual version of a physical network that is implemented inside of Google's production network by using Andromeda.

## Create an auto mode VPC network

> Reference: [Create an auto mode VPC network](https://cloud.google.com/vpc/docs/create-modify-vpc-networks#create-auto-network)

- VPC networks / Create VPC Network:

  * n 

```bash
gcloud compute networks create proupsavpc
```

- List VPCs:

```bash
gcloud compute networks list
```

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
