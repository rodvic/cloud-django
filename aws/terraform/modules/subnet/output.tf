output "subnet_ids" {
  value = [for s in aws_subnet.this : s.id]
}
