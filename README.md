# Vault Enterprise Terraform Deploy

This guide will cover a multitude of deployment solutions for an Enterprise install of Vault:
 
 Utilizes Packer to build the images, and Terraform to lay down all of the infrastructure.
 
 Two Vault Clusters:
 * Vault Cluster - Auto-scaling Group
 * Consul Cluster - Auto-scaling Group
 
 Vault Enterprise Features:
 * KMS Auto-Unseal
 * Performance Replication

 Consul Features:
 * Auto-Pilot

 Terraform Enterprise:
 * Utilizes remote state of Primary Cluster

 AWS Specific Features:
 * Creates a Peer Connection between Regions and configures appropriate routing.


## Reference Material
- _[Any relevant reference material that will help the user better understand the use case being solved for]()_

## Estimated Time to Complete
30 Minutes

## Solution
_Paragraph describing the proposed solution._

## Prerequisites
- Have Packer on your system
- Clone this repo onto your machine for utilizing the Packer build files.
- Create EC2 Keys in the Regions you will be deploying to.
- Have AWS Access keys ready to go

## Steps

Through these steps, we'll need to make sure these data items are provided:
* Consul AMI:
* Vault AMI:
* AWS KEY ID:
* AWS SECRET KEY:
* KMS KEY ID


## Step 1: Setup your AMI Images

##Build Your AMIs - Consul & Vault

### Consul Vault Config:

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export CONSUL_ENT_URL=https://s3.amazonaws.com/binaries-azc/consul-enterprise_1.0.7%2Bent_linux_amd64.zip
export VAULT_ENT_URL=https://s3.amazonaws.com/binaries-azc/vault-enterprise_0.10.1%2Bprem_linux_amd64.zip
export AWS_REGION=us-east-2
export CONSUL_VERSION=1.0.7
export VAULT_VERSION=0.10.1
```

From the root directory where you cloned the repo: 
```sh
cd packer-images/vault/
packer build vault.json
```
*Copy the AMI ID for later use.*

### Consul AMI Config:
```sh
cd ../consul
packer build consul.json
```

*Copy the AMI ID for later use.*

### AWS Components

#### AWS KMS Key for Auto-Unseal

Create an AWS KMS Key following the defaults all the way through for creation. 

AWS —> IAM —> Encryption Keys
Create key —> Enter Alias Name —> Next Step —> Optional Tags —> Next Step
Defne Key Administration - Choose who can manage the key - no bearing on Auto Unseal
Define Key Usage Permission - Choose the key which vault will use to access this key for auto unseal

Copy the Key ID after it is created.

E.g.: c1636bfe-08ef-4ca9-9002-41a37eb39fac

#### EC2 Keys - Ensure you have keys created to be specified in your Terraform Variables - these keys will be used for SSH access to the vault and consul servers.

## Setup First Cluster

### Workspace

Create workspace and point to the appropriate directory: `terraform-cluster`

### Assign all of the appropriate variables

```
region: us-east-2
consul_cluster_size: 3
vault_cluster_size: 3
environment_name: VaultEast-[CustomName]
avail_zones: ["us-east-2a","us-east-2b","us-east-2c"]
vault_ami: ami-abced
consul_ami: ami-xyz
cluster: Primary
subnet_count: 1
aws_secrets: 
root_domain: securekeyvault.site

```
## Setup Second Cluster

### Copy AMIs 
Copy the two AMI instances you created to the other region you are going to target.

*Write down the AMI IDs to be used in the Secondary Cluster Configuration*

### Secondary Cluster Configuration

```
region: us-west-2
consul_cluster_size: 3
vault_cluster_size: 3
environment_name: VaultWest-[CustomName] <-- *Make sure to Change*
avail_zones: ["us-west-2a","us-west-2b","us-west-2c"]
vault_ami: ami-abced1
consul_ami: ami-xyz1
cluster: Secondary
subnet_count: 3
aws_secrets: 
root_domain: securekeyvault.site
primary_workspace: VaultEast-[CustomName]
tfe_org: azc
```
