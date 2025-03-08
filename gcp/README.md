> Build django docker image: [Django build](../README.md)

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

- List accounts;

```bash
gcloud auth list
```

- Switch accounts if you are logged in to multiple accounts:

```bash
gcloud config set account ACCOUNT
```

# Creating and managing projects

> Reference: [Creating and managing projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects)

- Manage resources / + Create Project
  * Project ID: `proupsa`

```bash
gcloud projects create proupsa
```

- List accounts projects:

```bash
gcloud projects list
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

- IAM and admin / Service accounts / + Create Service Account
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

- Manage resources / `proupsa` / Permissions / + Add Principal
  * `saproupsa` (Service Account) -> `Editor` (Role)

```bash
gcloud projects add-iam-policy-binding proupsa \
  --member="serviceAccount:saproupsa@proupsa.iam.gserviceaccount.com" \
  --role="roles/editor" \
  --condition=None
```

#### To allow users to attach the service account to other resources

- IAM and admin / Service accounts / `saproupsa@proupsa.iam.gserviceaccount.com` / Permissions / + Grant Access
  * `USER_EMAIL` (principals - your user email) -> `Service Account User` (Role)

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
docker tag cloud-django:latest europe-southwest1-docker.pkg.dev/proupsa/proupsaacr/cloud-django:latest
```

- Docker push:

```bash
docker push europe-southwest1-docker.pkg.dev/proupsa/proupsaacr/cloud-django:latest
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

- VPC network / + Create VPC Network:
  * VPC name: `proupsavpc`
  * subnet-mode: custom

```bash
gcloud compute networks create proupsavpc \
  --subnet-mode=custom
```

- List VPCs:

```bash
gcloud compute networks list
```

## Add an IPv4-only subnet

> Reference: [Add an IPv4-only subnet](https://cloud.google.com/vpc/docs/create-modify-vpc-networks#add-subnets)

When you create a subnet, you set a name, a region, and at least a primary IPv4 address range according to the name and IPv4 subnet range limitations.

- VPC network / `proupsavpc` / Subnets / + Add Subnet
  * Subnet name: `proupsasubnet`
  * network: `proupsavpc`
  * range: `10.0.0.0/24`
  * region: `europe-southwest1`

```bash
gcloud compute networks subnets create proupsasubnet \
    --network=proupsavpc \
    --range=10.0.0.0/24 \
    --region=europe-southwest1
```

- List Subnets:

```bash
gcloud compute networks subnets list \
   --network=proupsavpc
```

# VM Instances

## Create a VM instance from a public image

> Reference: [Create a VM instance from a public image](https://cloud.google.com/compute/docs/instances/create-start-instance#publicimage)

- Compute Engine / VM instances / + Create instance
  * Machine Configuration | VM name: `proupsavm01`
  * Machine Configuration | region: `europe-southwest1`
  * Machine Configuration | zone: `Any`
  * Machine Configuration | Machine type: `e2-medium`
  * OS abd storage | Image: `Ubuntu 20.04 LTS`
  * Networking | Network: `proupsavpc`
  * Networking | Subnetwork: `proupsasubnet`
  * Networking | Network Service Tier: `Standard (europe-southwest1)`
  * Security | Service account: `saproupsa@proupsa.iam.gserviceaccount.com`

```bash
gcloud compute instances create proupsavm01 \
    --zone=europe-southwest1-a \
    --machine-type=e2-medium \
    --network-interface=network-tier=STANDARD,stack-type=IPV4_ONLY,subnet=proupsasubnet \
    --service-account=saproupsa@proupsa.iam.gserviceaccount.com \
    --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20241219,mode=rw,size=10,type=pd-balanced
```

## Firewall - Add access rules

- VPC network / `proupsavpc` / Firewalls / + Add Firewall Rule
  * Rule name: `sshrule`
  * Network: `proupsavpc`
  * Priority: `1000`
  * Direcion of traffic: `Ingress`
  * Action on match: `Allow`
  * Targets: `All instances in the network`
  * Source filter | IPv4 ranges | `0.0.0.0/0`
  * Specified Protocols and ports | TCP | `22`

```bash
gcloud compute firewall-rules create sshrule \
  --direction=INGRESS \
  --priority=1000 \
  --network=proupsavpc \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=0.0.0.0/0
```

- VPC network / `proupsavpc` / Firewalls / + Add Firewall Rule
  * Rule name: `httprule`
  * Network: `proupsavpc`
  * Priority: `1000`
  * Direcion of traffic: `Ingress`
  * Action on match: `Allow`
  * Targets: `All instances in the network`
  * Source filter | IPv4 ranges | `0.0.0.0/0`
  * Specified Protocols and ports | TCP | `8000`

```bash
gcloud compute firewall-rules create httprule \
  --direction=INGRESS \
  --priority=1000 \
  --network=proupsavpc \
  --action=ALLOW \
  --rules=tcp:8000 \
  --source-ranges=0.0.0.0/0
```

## SSH access and VM configuration

- SSH access (empty for no passphrase):

```bash
gcloud compute ssh "proupsavm01"
```

- Configure VM and docker run:

```bash
# root user
sudo -i

# Install docker service
apt-get update
apt-get install -y docker.io

# gcloud auth configure-docker with service account
gcloud auth configure-docker \
  europe-southwest1-docker.pkg.dev \
  --quiet

# Docker Run
docker run -d -p 8000:8000 europe-southwest1-docker.pkg.dev/proupsa/proupsaacr/cloud-django:latest
```

## Test Service (from local)

- List instances:

```bash
gcloud compute instances list

# Command output example:
NAME         ZONE                 MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP   STATUS
proupsavm01  europe-southwest1-b  e2-medium                  10.0.0.3     34.0.215.213  RUNNING
```

- Use EXTERNAL_IP:

```bash
# use curl or browse IP/port
curl http://<EXTERNAL_IP>:8000
```

# GCP Deployment Services

## Deploying container images to Cloud Run

> Reference: [Deploying container images to Cloud Run](https://cloud.google.com/run/docs/deploying)

Deploy container images to a new Cloud Run service or to a new revision of an existing Cloud Run service.

```bash
gcloud run deploy cloud-django \
  --image=europe-southwest1-docker.pkg.dev/proupsa/proupsaacr/cloud-django@latest \
  --region=europe-southwest1 \
&& gcloud run services update-traffic cloud-django --to-latest
```
