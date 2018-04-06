provider "aws" {
  region = "${var.region}"
}

resource "aws_launch_configuration" "vault-server" {
  name          = "vault-server"
  image_id      = "ami-08323d326a7d4bca6"
  instance_type = "t2.small"
  key_name      = "AZC"
  user_data     = "${data.template_file.vault.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  security_groups = [
    "${module.vault_service.this_security_group_id}",
  ]
}

resource "aws_autoscaling_group" "vault_servers" {
  name                 = "vault_servers"
  launch_configuration = "${aws_launch_configuration.vault-server.name}"
  vpc_zone_identifier  = ["${module.vpc.public_subnets}"]
  min_size             = "${var.cluster_size}"
  max_size             = "${var.cluster_size}"
  desired_capacity     = "${var.cluster_size}"
  default_cooldown     = 30
  force_delete         = true
  depends_on           = ["aws_autoscaling_group.consul_servers"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "Vault Server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "AZC"
    propagate_at_launch = true
  }

  tag {
    key                 = "TTL"
    value               = "-1"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment_name"
    value               = "${var.environment_name}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "consul-server" {
  name          = "consul-server"
  image_id      = "ami-02b5dfa7ff74e7215"
  instance_type = "t2.small"
  key_name      = "AZC"
  user_data     = "${data.template_file.consul.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  security_groups = [
    "${module.vault_service.this_security_group_id}",
  ]
}

resource "aws_autoscaling_group" "consul_servers" {
  name                 = "consul_servers"
  launch_configuration = "${aws_launch_configuration.consul-server.name}"
  vpc_zone_identifier  = ["${module.vpc.public_subnets}"]

  lifecycle {
    create_before_destroy = true
  }

  min_size         = "${var.cluster_size}"
  max_size         = "${var.cluster_size}"
  desired_capacity = "${var.cluster_size}"
  default_cooldown = 30
  force_delete     = true

  tag {
    key                 = "Name"
    value               = "Consul Server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "AZC"
    propagate_at_launch = true
  }

  tag {
    key                 = "TTL"
    value               = "-1"
    propagate_at_launch = true
  }
}
