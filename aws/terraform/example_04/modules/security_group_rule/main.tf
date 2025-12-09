resource "aws_security_group_rule" "this" {
  type                     = var.type
  from_port                = var.from_port
  to_port                  = var.to_port
  protocol                 = var.protocol
  cidr_blocks              = var.cidr_blocks
  source_security_group_id = var.source_security_group_id
  security_group_id        = var.security_group_id
  description              = var.description
}
