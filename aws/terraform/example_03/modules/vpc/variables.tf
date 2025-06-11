variable "cidr_block" {
  type = string
}
variable "enable_dns_hostnames" {
  type    = bool
  default = true
}
variable "tags" {
  type    = map(string)
  default = {}
}
