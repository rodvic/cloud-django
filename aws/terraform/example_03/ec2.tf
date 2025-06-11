# Generates an RSA private key
resource "tls_private_key" "rsa-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate the key pair
resource "aws_key_pair" "ec2-key-pair" {
  key_name   = "example_03_ec2_key_pair"
  public_key = tls_private_key.rsa-key.public_key_openssh
}

# Save the private key to a local file
resource "local_file" "ssh-key" {
  content         = tls_private_key.rsa-key.private_key_pem
  filename        = "${path.module}/ec2_key.pem"
  file_permission = "0400"
}

module "ec2" {
  source                        = "./modules/ec2_instance"
  ami                           = "ami-03fd334507439f4d1"
  instance_type                 = "t2.micro"
  key_name                      = aws_key_pair.ec2-key-pair.key_name
  subnet_id                     = module.subnets.subnet_ids[0] # Using the first subnet for the instance
  associate_public_ip_address   = true
  security_group_ids            = [module.vpc.default_security_group_id]
  tags = {
    Environment = "example_03"
    Name        = "example_03_ec2_instance"
  }
  instance_count                = 1
}
