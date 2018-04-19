data "vault_generic_secret" "aws_stuff" {
  path = "secret/aws/azc"
}

data "template_file" "consul" {
  template = "${file("${path.module}/init-consul.sh")}"

  vars = {
    cluster_size     = "${var.consul_cluster_size}"
    environment_name = "${var.environment_name}"
    local_region     = "${var.region}"
  }
}

data "template_file" "vault" {
  template = "${file("${path.module}/init-vault.sh")}"

  vars = {
    cluster_size     = "${var.vault_cluster_size}"
    environment_name = "${var.environment_name}"
    local_region     = "${var.region}"
    access_key       = "${data.vault_generic_secret.aws_stuff.data['access_key']}"
    secret_key       = "${data.vault_generic_secret.aws_stuff.data['secret_key']}"
    kms_key_id       = "${data.vault_generic_secret.aws_stuff.data['kms_key_id']}"
  }
}
