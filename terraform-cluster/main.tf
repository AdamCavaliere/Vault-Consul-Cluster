resource "aws_launch_configuration" "vault-server" {
  name_prefix          = "vault-server-"
  image_id             = "${var.vault_ami}"
  instance_type        = "t2.small"
  key_name             = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.hashistack.id}"

  user_data = "${data.template_file.vault.rendered}"

  security_groups = [
    "${module.vault_service.this_security_group_id}",
    "${module.consul_service.this_security_group_id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "vault_servers" {
  name                 = "vault_servers-${var.environment_name}"
  launch_configuration = "${aws_launch_configuration.vault-server.name}"
  vpc_zone_identifier  = ["${module.vpc.public_subnets}"]
  min_size             = "${var.vault_cluster_size}"
  max_size             = "${var.vault_cluster_size}"
  desired_capacity     = "${var.vault_cluster_size}"
  default_cooldown     = 30
  force_delete         = true
  depends_on           = ["aws_autoscaling_group.consul_servers"]
  load_balancers       = ["${aws_elb.vault_elb.id}"]

  tag {
    key                 = "Name"
    value               = "Vault Server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "${var.key_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "TTL"
    value               = "-1"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "consul-server" {
  name_prefix          = "consul-server-"
  image_id             = "${var.consul_ami}"
  instance_type        = "t2.small"
  key_name             = "${var.key_name}"
  user_data            = "${data.template_file.consul.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.hashistack.id}"

  security_groups = [
    "${module.vault_service.this_security_group_id}",
    "${module.consul_service.this_security_group_id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "consul_servers" {
  name                 = "consul_servers-${var.environment_name}"
  launch_configuration = "${aws_launch_configuration.consul-server.name}"
  vpc_zone_identifier  = ["${module.vpc.private_subnets}"]

  min_size         = "${var.consul_cluster_size}"
  max_size         = "${var.consul_cluster_size}"
  desired_capacity = "${var.consul_cluster_size}"
  default_cooldown = 30
  force_delete     = true

  tag {
    key                 = "Name"
    value               = "Consul Server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "${var.key_name}"
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

  lifecycle {
    create_before_destroy = true
  }
}

#resource "aws_instance" "bastion_host" {
#  ami                         = "${var.consul_ami}"
#  instance_type               = "t2.micro"
#  key_name                    = "${var.key_name}"
#  user_data                   = "${data.template_file.consul-agent.rendered}"
#  iam_instance_profile        = "${aws_iam_instance_profile.hashistack.id}"
#  subnet_id                   = "${element(module.vpc.public_subnets, 0)}"
#  associate_public_ip_address = true


#  security_groups = [
#    "${module.vault_service.this_security_group_id}",
#    "${module.consul_service.this_security_group_id}",
#  ]


#  tags {
#    Name  = "BastionHost"
#    owner = "Adam"
#    ttl   = "5h"
#  }
#}

