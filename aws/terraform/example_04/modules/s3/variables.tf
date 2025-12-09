variable "bucket" { type = string }
variable "force_destroy" {
  type = bool
  default = false
}
variable "versioning" {
  type = bool
  default = false
}
variable "sse_algorithm" {
  type = string
  default = "AES256"
}
variable "tags" {
  type = map(string)
  default = {}
}
