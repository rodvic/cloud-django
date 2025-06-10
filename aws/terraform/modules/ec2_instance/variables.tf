variable "ami" { type = string }
variable "instance_type" { type = string }
variable "key_name" { type = string }
variable "subnet_id" { type = string }
variable "associate_public_ip_address" { type = bool }
variable "security_group_ids" { type = list(string) }
variable "tags" { type = map(string) }

variable "volume_size" { type = number }
variable "volume_type" { type = string }
variable "delete_on_termination" { type = bool }
variable "encrypted" { type = bool }
variable "iops" { type = number }
variable "throughput" { type = number }

variable "cpu_credits" { type = string }
variable "http_endpoint" { type = string }
variable "http_put_response_hop_limit" { type = number }
variable "http_tokens" { type = string }

variable "hostname_type" { type = string }
variable "enable_resource_name_dns_a_record" { type = bool }
variable "enable_resource_name_dns_aaaa_record" { type = bool }

variable "instance_count" {
  type = number
  default = 1
}
