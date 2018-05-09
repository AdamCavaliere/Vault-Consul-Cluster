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
    lb_addr          = "${var.root_domain == "notSet" ? aws_elb.vault_elb.dns_name : join(" ",aws_route53_record.www.*.name)}"
    access_key       = "${var.access_key}"
    secret_key       = "${var.secret_key}"
    kms_key_id       = "${var.kms_key_id}"
    kms_key_region   = "${var.kms_key_region}"
  }
}

data "template_file" "consul-agent" {
  template = "${file("${path.module}/init-consul-agent.sh")}"

  vars = {
    cluster_size     = "${var.consul_cluster_size}"
    environment_name = "${var.environment_name}"
    local_region     = "${var.region}"
  }
}
