resource "aws_s3_bucket" "backup" {
  bucket = var.s3_bucket
}
