resource "aws_db_instance" "this" {
  identifier                  = var.identifier
  instance_class              = var.instance_class
  engine                      = var.engine
  engine_version              = var.engine_version
  allocated_storage           = var.allocated_storage
  username                    = var.username
  password                    = var.password
  vpc_security_group_ids      = var.vpc_security_group_ids
  publicly_accessible         = var.publicly_accessible
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  multi_az                    = var.multi_az
  db_subnet_group_name        = aws_db_subnet_group.this.name
  skip_final_snapshot         = var.skip_final_snapshot
  deletion_protection         = var.deletion_protection
  apply_immediately           = var.apply_immediately
  tags                        = var.tags
  port                        = var.port
  # engine_lifecycle_support is not a direct argument in Terraform, but can be managed via engine_version and maintenance settings
}
