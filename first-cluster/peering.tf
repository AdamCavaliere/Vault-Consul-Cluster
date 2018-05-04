data "terraform_remote_state" "primary_vault" {
  count   = "${var.cluster == "Secondary" ? 1 : 0}"
  backend = "atlas"

  config {
    name = "azc/${var.primary_workspace}"
  }
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = "${module.vpc.vpc_id}"
  peer_vpc_id = "${data.terraform_remote_state.primary_vault.vpc_id}"
  peer_region = "us-east-2"
  auto_accept = false

  tags {
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
  auto_accept               = true

  tags {
    Side = "Accepter"
  }
}
