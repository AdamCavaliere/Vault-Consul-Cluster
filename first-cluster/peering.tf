data "terraform_remote_state" "primary_vault" {
  count   = "${var.cluster == "Secondary" ? 1 : 0}"
  backend = "atlas"

  config {
    name = "azc/${var.primary_workspace}"
  }
}

resource "aws_vpc_peering_connection" "foo" {
  count = "${var.cluster == "Secondary" ? 1 : 0}"

  peer_vpc_id = "${data.terraform_remote_state.primary_vault.vpc_id}"
  vpc_id      = "${module.vpc.vpc_id}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}
