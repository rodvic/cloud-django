module "s3_bucket" {
  source        = "./modules/s3"
  bucket        = "proupsa-bucket-example-04"
  force_destroy = false
  versioning    = true
  tags = {
    Environment = "example_04"
    Name        = "proupsa-bucket-example-04"
  }
}
