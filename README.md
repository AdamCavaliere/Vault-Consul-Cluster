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

_Note: The Consul and Vault URL will only work if your AWS keys has access to those Object Stores_

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export CONSUL_ENT_URL=https://s3.amazonaws.com/binaries-azc/consul-enterprise_1.0.7%2Bent_linux_amd64.zip
export VAULT_ENT_URL=https://s3.amazonaws.com/binaries-azc/vault-enterprise_0.10.1%2Bprem_linux_amd64.zip
export AWS_REGION=us-east-2
export CONSUL_VERSION=1.0.7
export VAULT_VERSION=0.10.1
```

If you get an error, because you could not acces and download the enterprise bits above, change to the bits that require a license and do the following

- Go to licensing.hashicorp.com and create a license for yourelf for both vault and consul.  See SE Tame Handbook.
Then

```export VAULT_ENT_URL=https://s3-us-west-2.amazonaws.com/hc-enterprise-binaries/vault/ent/0.10.1/vault-enterprise_0.10.1%2Bent_linux_amd64.zip
export export CONSUL_ENT_URL=https://s3-us-west-2.amazonaws.com/hc-enterprise-binaries/consul/ent/1.1.0/consul-enterprise_1.1.0%2Bent_linux_amd64.zip
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
access_key: AWS Access Key ID
secret_key: AWS Secret Key ID
kms_key_id: Key ID 
kms_key_region: KMS key location
region: us-east-2
consul_cluster_size: 3
vault_cluster_size: 3
environment_name: VaultEast-[CustomName]
avail_zones: ["us-east-2a","us-east-2b","us-east-2c"]
vault_ami: ami-abced
consul_ami: ami-xyz
cluster: Primary
root_domain: securekeyvault.site <-- Custom value or don't set it
key_name: EC2 Key
tfe_org: azc

```

Save Plan & Apply

## Setup Second Cluster

### Copy AMIs 
Copy the two AMI instances you created to the other region you are going to target.

*Write down the AMI IDs to be used in the Secondary Cluster Configuration*

### Secondary Cluster Configuration

```
access_key: AWS Access Key ID
secret_key: AWS Secret Key ID
kms_key_id: Key ID 
kms_key_region: KMS key location
region: us-west-2
consul_cluster_size: 3
vault_cluster_size: 3
environment_name: VaultWest-[CustomName] <-- *Make sure to Change*
avail_zones: ["us-west-2a","us-west-2b","us-west-2c"]
vault_ami: ami-abced1
consul_ami: ami-xyz1
cluster: Secondary
root_domain: securekeyvault.site Custom value or don't set it
primary_workspace: VaultEast-[CustomName]
key_name: EC2 Key
tfe_org: azc
```

After the first workspace is completed being built, Save and Apply

## Step 2 - Setup Vault Clusters

### Initialize Primary Cluster

On *Terminal 1*

`export VAULT_LICENSE=<copy the text of your license>`
From root directory:
_Note, you may receive an error "Import requests ImportError: No module named requests"_
_On a mac perform a_
```sudo easy_install -U requests
sudo easy_install -U pip
sudo pip install hvac
```

```sh
cd config-scripts
python Initialize-Vault.py -fqdn URL.From.TFE.Output
```
*Make sure that Initialize-Vault.py has the vault write sys/license code enabled*

*Copy the Root Token for future use.*

At this point Vault is initialized and setup to use the AWS-KMS for unsealing.

 * Follow instructions in the script (Reboot all 3 Vault Servers)
 * Press Enter
 * Copy the 2 export commands and execute them

 Then ssh into Terminal 1 and apply consul license
 ``` ssh -o StrictHostKeyChecking=no -i <your pem file> -o ubuntu:<public IP of one of the Vault Servers>
 consul license put "<contents_of_consul_license>"
```

### Initialize Secondary Cluster

On *Terminal 2*

From root directory:
```sh
cd config-scripts
python Initialize-Vault.py -fqdn URL.From.TFE.Output
```

*Copy the Root Token for future use.*

At this point Vault is initialized and setup to use the AWS-KMS for unsealing.

 * Follow instructions in the script (Reboot all 3 Vault Servers)
 * Press Enter
 * Copy the 2 export commands and execute them

 Then ssh into Terminal 1 and apply consul license
 ``` ssh -o StrictHostKeyChecking=no -i <your pem file> -o ubuntu:<public IP of one of the Vault Servers>
 consul license put "<contents_of_consul_license>"
```

## Step 3 - Configure Replication

### Setup Replication on Primary

Run this command on *Terminal 1*:

* NOTE: You need to have Vault installed on your Mac or local machine *

`vault write -f sys/replication/performance/primary/enable`

After a small amount of time, run this command on *Terminal 1*:

`vault write sys/replication/performance/primary/secondary-token id=1`

Copy the *wrapping_token* for later use.

### Setup Replication on Secondary

Run this command on *Terminal 2*:

`vault write sys/replication/performance/secondary/enable token=[wrapping_token]`

At this point, replication is fully configured between the two clusters. 

## Step 4 - Test Replication

### Write a secret
*Terminal 1*

```sh
echo '
path "*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}' | vault policy-write vault-admin -
vault auth-enable userpass
vault write auth/userpass/users/vault password=vault policies=vault-admin

vault write secret/replTest hello=world
```

### Read a secret
*Terminal 2*

```
vault login -method=userpass username=vault password=vault
```

replace your VAULT_TOKEN Env variable with the output

```
export VAULT_TOKEN=NEW_TOKEN
vault read secret/replTest
```
