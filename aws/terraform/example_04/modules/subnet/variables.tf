variable "vpc_id" {
  type = string
}
variable "subnets" {
  type = map(object({
    cidr_block = string
    az         = string
    tags       = map(string)
  }))
}
