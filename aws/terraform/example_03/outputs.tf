output "vpc_id" {
  value = module.vpc.vpc_id
}
output "subnet_ids" {
  value = module.subnets.subnet_ids
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
