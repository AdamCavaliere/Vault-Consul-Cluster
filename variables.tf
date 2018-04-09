variable "region" {
  description = "Main Region to Deploy instances"
  default     = "us-east-2"
}

variable "cluster_size" {
  description = "Size of cluster"
  default     = 3
}

variable "environment_name" {
  description = "base name of environment"
  default     = "notSet"
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
