resource "aws_s3_bucket" "website_root" {
  #checkov:skip=CKV_AWS_52:Bucket is created by a pipeline
  #checkov:skip=CKV_AWS_144:Not required to have cross region enabled
  bucket = "${var.website_name}-root"

  acl = "private"
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

resource "aws_s3_bucket_public_access_block" "website_root" {
  bucket = aws_s3_bucket.website_root.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}


resource "aws_s3_bucket" "website_logs" {
  #checkov:skip=CKV_AWS_52:Bucket is created by a pipeline
  #checkov:skip=CKV_AWS_18:Access logging needs to go into a cross account bucket
  #checkov:skip=CKV_AWS_144:Not required to have cross region enabled

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

resource "aws_s3_bucket_public_access_block" "website_logs" {
  bucket = aws_s3_bucket.website_logs.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

}

locals {
  s3_origin_id = "cla-website-root"
}

resource "aws_cloudfront_origin_access_identity" "cla-website" {
  comment = "Origin access identity for CLA website"
}

data "aws_iam_policy_document" "cla-website-accessible-from-cdn" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cla-website-root.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cla-website.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cla-website-accessible-from-cdn" {
  bucket = aws_s3_bucket.cla-website-root.id
  policy = data.aws_iam_policy_document.cla-website-accessible-from-cdn.json
}

# ignoring AWS045 and CKV_AWS_68 - it wants a WAF in front of this. good suggestion actually but need to review scope of #15 then!
# tfsec:ignore:AWS045
resource "aws_cloudfront_distribution" "cla-website" {
  #checkov:skip=CKV_AWS_68:WAF not confirmed to be in scope of #15 yet
  origin {
    domain_name = aws_s3_bucket.website_root.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cla-website.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CLA website"
  default_root_object = "index.html"
  http_version        = "http2"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.website_logs.id
    prefix          = "cdn/"
  }

  # aliases = ["cla.tintulip.??"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = "PriceClass_100"

  tags = {
    Name        = "CLA Website CDN"
    Environment = "Production"
  }

  viewer_certificate {
    # this needs to change to an ACM cert as part of #15, but we don't have it yet!
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2019"
  }

  restrictions {
    restriction_type = "none"
  }
}

output "cloudfront-default-url" {
  value = aws_cloudfront_distribution.cla-website.domain_name
}
