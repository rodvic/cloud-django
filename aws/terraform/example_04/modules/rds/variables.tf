variable "identifier" { type = string }
variable "instance_class" { type = string }
variable "engine" { type = string }
variable "engine_version" { type = string }
variable "allocated_storage" { type = number }
variable "username" { type = string }
variable "password" { type = string }
variable "vpc_security_group_ids" { type = list(string) }
variable "publicly_accessible" { type = bool }
variable "auto_minor_version_upgrade" { type = bool }
variable "iam_database_authentication_enabled" { type = bool }
variable "multi_az" { type = bool }
variable "db_subnet_group_name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "skip_final_snapshot" {
  type = bool
  default = true
}
variable "deletion_protection" {
  type = bool
  default = false
}
variable "apply_immediately" {
  type = bool
  default = true
}
variable "tags" {
  type = map(string)
  default = {}
}
variable "port" {
  type = number
  default = 3306
}
