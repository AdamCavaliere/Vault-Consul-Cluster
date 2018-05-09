output "vault_url" {
  value = "${var.root_domain == "notSet" ? aws_elb.vault_elb.dns_name : join(" ",aws_route53_record.www.*.name)}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "pub_route_table_id" {
  value = "${module.vpc.public_route_table_ids}"
}
