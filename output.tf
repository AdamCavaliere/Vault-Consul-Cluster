output "db_address" {
  value = "${aws_db_instance.example.address}"
}

output "db_port" {
  value = "${aws_db_instance.example.port}"
}

output "vault_url" {
  value = "${aws_route53_record.www.name}"
}

output "ip_addresses" {
  value = "${data.aws_instances.vault_servers.public_ips}"
}

resource "vault_generic_secret" "vault_output" {
  path = "secret/cluster_details"

  data_json = <<EOT
{
  "cluster_address": "${aws_route53_record.www.name}"
  "db_address": "${aws_db_instance.example.address}"
}
EOT
}
