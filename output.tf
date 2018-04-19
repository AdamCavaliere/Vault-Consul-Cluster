output "db_address" {
  value = "${aws_db_instance.example.address}"
}

output "db_port" {
  value = "${aws_db_instance.example.port}"
}

output "vault_url" {
  value = "${aws_route53_record.www.name}"
}
