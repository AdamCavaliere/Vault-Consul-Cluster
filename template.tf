data "template_file" "consul" {
  template = "${file("${path.module}/init-consul.sh")}"

  vars = {
    cluster_size     = "${var.cluster_size}"
    environment_name = "${var.environment_name}"
    local_region     = "${var.region}"
  }
}

data "template_file" "vault" {
  template = "${file("${path.module}/init-vault.sh")}"

  vars = {
    cluster_size     = "${var.cluster_size}"
    environment_name = "${var.environment_name}"
    local_region     = "${var.region}"
  }
}
