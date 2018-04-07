module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "VaultCluster VPC"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway                = false
  enable_vpn_gateway                = false
  enable_dns_hostnames              = true
  propagate_public_route_tables_vgw = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "vault_service" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "vault-service"
  description = "vault services"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "consul-webui-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 8200
      to_port     = 8200
      protocol    = "tcp"
      description = "Vault-Server"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_rules = ["all-all"]
}

module "consul_service" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "consul-service"
  description = "consul services"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_rules       = ["consul-dns-tcp", "consul-dns-udp", "consul-serf-lan-tcp", "consul-serf-lan-udp", "consul-tcp"]

  egress_rules = ["all-all"]
}
