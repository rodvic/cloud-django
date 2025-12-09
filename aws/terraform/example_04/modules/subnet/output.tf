output "subnet_ids" {
  value = [for s in aws_subnet.this : s.id]
}

output "subnet_map" {
  value = { for k, s in aws_subnet.this : k => s.id }
}
