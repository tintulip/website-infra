resource "aws_s3_bucket" "website_root" {
  bucket = "${var.website_name}-root"
  acl    = "public-read" #tfsec:ignore:AWS001 
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
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"

      }
    }
  }
}

resource "aws_s3_bucket" "website_logs" {
  bucket = "${var.website_name}-logs"
  acl    = "log-delivery-write"

  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}
