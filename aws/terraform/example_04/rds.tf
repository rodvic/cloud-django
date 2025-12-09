module "rds" {
  source                         = "./modules/rds"
  identifier                     = "example-04-proupsa-db"
  instance_class                 = "db.t3.micro"
  engine                         = "mysql"
  engine_version                 = "8.0.40"
  allocated_storage              = 20
  username                       = "admin"
  password                       = var.rds_password
  vpc_security_group_ids         = [aws_security_group.rds.id]
  publicly_accessible            = false
  auto_minor_version_upgrade     = false
  iam_database_authentication_enabled = false
  multi_az                       = false
  db_subnet_group_name           = "example-04-proupsa-subnet-group"
  subnet_ids                     = module.private_subnets.subnet_ids
  skip_final_snapshot            = true
  deletion_protection            = false
  apply_immediately              = true
  tags = {
    Environment = "example_04"
    Name        = "example_04_proupsa-db"
  }
  port = 3306
}
