resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = var.security_group_ids
  tags                        = var.tags

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = var.delete_on_termination
    encrypted             = var.encrypted
    iops                  = var.iops
    throughput            = var.throughput
  }

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  metadata_options {
    http_endpoint               = var.http_endpoint
    http_put_response_hop_limit = var.http_put_response_hop_limit
    http_tokens                 = var.http_tokens
  }

  private_dns_name_options {
    hostname_type                           = var.hostname_type
    enable_resource_name_dns_a_record       = var.enable_resource_name_dns_a_record
    enable_resource_name_dns_aaaa_record    = var.enable_resource_name_dns_aaaa_record
  }

  count = var.instance_count
}
