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
