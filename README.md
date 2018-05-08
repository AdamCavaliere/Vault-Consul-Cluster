# _Guide Template_

_Summary of pain point/challenge/business case and goal of the guide in 2 paragraphs._

## Reference Material
- _[Any relevant reference material that will help the user better understand the use case being solved for]()_

## Estimated Time to Complete
_A rough estimate of time it would take a beginner to read the guide and complete the steps. The assumption is that they completed the prerequisites._

## Personas
_Paragraph describing the personas involved in the challenge and solution._

## Challenge
_Paragraph describing the challenge._

## Solution
_Paragraph describing the proposed solution._

## Prerequisites
- Create EC2 Keys in the Regions you will be deploying.
- Have AWS Access keys ready to go

## Steps

## Step 1: Setup your AMI Images

##Build Your AMIs - Consul & Vault

### Consul Vault Config:

```export CONSUL_ENT_URL=https://s3.amazonaws.com/binaries-azc/consul-enterprise_1.0.7%2Bent_linux_amd64.zip
export VAULT_ENT_URL=https://s3.amazonaws.com/binaries-azc/vault-enterprise_0.10.1%2Bent_linux_amd64.zip
export AWS_REGION=us-east-2
export CONSUL_VERSION=1.0.7
export VAULT_VERSION=0.10.1```

From the root directory where you cloned the repo: `cd packer-images/vault/`

`packer build vault.json`

*Copy the AMI ID for later use.*

### Consul AMI Config:
```sh
cd ../consul
packer build consul.json```

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
