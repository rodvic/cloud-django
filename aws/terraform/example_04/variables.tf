variable "rds_password" {
  description = "Password for the RDS admin user. Set via environment variable TF_VAR_rds_password"
  type        = string
  sensitive   = true
}
