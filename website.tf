resource "aws_s3_bucket" "website_root" {
  bucket = "${var.website_name}-root"
  acl    = "public-read"
  tags = {
    Name        = "CLA Website"
    Environment = "Production"
  }
  website {
    index_document = "index.html"
    error_document = "404.html"
  }
  logging {
    target_bucket = aws_s3_bucket.website_logs.id
    target_prefix = "logs/"
  }
}

resource "aws_s3_bucket" "website_logs" {
  bucket = "${var.website_name}-logs"
  acl    = "log-delivery-write"
}
