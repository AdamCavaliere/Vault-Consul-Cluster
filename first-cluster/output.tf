output "vault_url" {
  value = "${aws_route53_record.www.name}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

resource "vault_generic_secret" "vault_output" {
  path = "secret/cluster_details"

  data_json = <<EOT
{
  "cluster_address": "${aws_route53_record.www.name}",
  "db_address": "${aws_db_instance.example.address}"
}
EOT
}
