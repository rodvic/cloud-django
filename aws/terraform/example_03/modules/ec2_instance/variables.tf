variable "ami" { type = string }
variable "instance_type" { type = string }
variable "key_name" { type = string }
variable "subnet_id" { type = string }
variable "associate_public_ip_address" { type = bool }
variable "security_group_ids" { type = list(string) }
variable "tags" { type = map(string) }
variable "instance_count" {
  type = number
  default = 1
}
variable "user_data" {
  type = string
  default = ""
}
