resource "aws_db_instance" "example" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydbapp"
  username             = "admin"
  password             = "temppass"
  parameter_group_name = "default.mysql5.7"
}
