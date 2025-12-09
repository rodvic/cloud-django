output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_subnets" {
  value = module.public_subnets.subnet_ids
}
output "private_subnets" {
  value = module.private_subnets.subnet_ids
}
output "ec2_instance_id" {
  value = module.ec2.instance_id
}
output "ec2_instance_public_ip" {
  value = module.ec2.public_ip
}
output "ec2_instance_public_dns" {
  value = module.ec2.public_dns
}
output "rds_endpoint" {
  value = module.rds.endpoint
}
output "rds_address" {
  value = module.rds.address
}
output "rds_port" {
  value = module.rds.port
}
output "rds_id" {
  value = module.rds.id
}
output "s3_bucket_name" {
  value = module.s3_bucket.bucket
}
output "s3_bucket_arn" {
  value = module.s3_bucket.arn
}
output "s3_bucket_id" {
  value = module.s3_bucket.id
}
