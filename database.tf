resource "aws_db_instance" "example" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "mydbapp"
  username               = "admin"
  password               = "temppass"
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = ["${module.mysql_service.this_security_group_id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.private.name}"
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "private" {
  name       = "main"
  subnet_ids = ["${module.vpc.private_subnets}"]

  tags {
    Name = "ConsulAndDB"
  }
}
