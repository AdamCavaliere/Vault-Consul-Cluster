variable "region" {
  description = "Main Region to Deploy instances"
  default     = "us-east-1"
}

variable "consul_cluster_size" {
  description = "Size of consul cluster"
  default     = 3
}

variable "vault_cluster_size" {
  description = "Size of vault cluster"
  default     = 3
}

variable "environment_name" {
  description = "base name of environment"
}

variable "avail_zones" {
  description = "availability zones to deploy into"
  type        = "list"
}

variable "vault_ami" {
  description = "Vault AMI Image"
}

variable "consul_ami" {
  description = "Consul AMI Image"
}

variable "cluster" {
  description = "Primary or Secondary Cluster"
  default     = "Primary"
}

variable "primary_workspace" {
  description = "Required to be set with workspace name if this is the secondary"
  default     = "notSet"
}

variable "subnet_count" {
  description = "Number to use for creating subnets"
  default     = 1
}

variable "aws_secrets" {
  description = "Vault path of secrets used throughout this project"
  default     = "secret/aws/azc"
}

variable "root_domain" {
  description = "Base FQDN of domain"
  default     = "notSet"
}

variable "key_name" {
  description = "EC2 Keys"
  default     = "AZC"
}

variable "tfe_org" {
  description = "ORG that contains your remote state"
  default     = "azc"
}

variable "access_key" {
  description = "AWS Access Key"
}

variable "secret_key" {
  description = "AWS Secret Key"
}

variable "kms_key_id" {
  description = "KMS Key ID for Auto Unseal"
}

variable "kms_key_region" {
  description = "Region the KMS key is located"
}
