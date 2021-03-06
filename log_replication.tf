resource "aws_iam_role" "log_replication" {
  name = "log-replication"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

locals {
  log_rep_kms_key = "arn:aws:kms:eu-west-2:689141309029:key/108cb585-3def-4a0a-99c7-fe150c257d6a"
}

data "aws_kms_key" "s3" {
  key_id = "alias/aws/s3"
}

resource "aws_iam_policy" "log_replication" {
  policy = data.aws_iam_policy_document.log_replication.json
  name   = "log-replication"
}

resource "aws_iam_role_policy_attachment" "log_replication" {
  policy_arn = aws_iam_policy.log_replication.arn
  role       = aws_iam_role.log_replication.name
}

data "aws_iam_policy_document" "log_replication" {
  #checkov:skip=CKV_AWS_111:Allow KMS decrypt/encrypt on any resource
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:PutReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.website_logs.arn
    ]
  }

  statement {
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging"
    ]

    resources = [
      "${aws_s3_bucket.website_logs.arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetObjectVersionTagging",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]

    resources = [
      "arn:aws:s3:::cla-app-logs/*"
    ]
  }

  statement {
    actions = [
      "kms:Decrypt"
    ]

    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.eu-west-2.amazonaws.com"]
    }

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      data.aws_kms_key.s3.arn
    ]
  }

  statement {
    actions = [
      "kms:Encrypt"
    ]

    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.eu-west-2.amazonaws.com"]
    }

    resources = [
      "*"
    ]
  }
}


resource "aws_s3_bucket" "website_logs" {
  #checkov:skip=CKV_AWS_52:Bucket is created by a pipeline
  #checkov:skip=CKV_AWS_18:Access logging needs to go into a cross account bucket
  #checkov:skip=CKV_AWS_144:Not required to have cross region enabled
  #checkov:skip=CKV_AWS_145:Cannot use KMS for cross-account log replication
  bucket = "${var.website_name}-logs"
  acl    = "log-delivery-write"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "log-expire"
    enabled = true

    tags = {
      rule      = "log-expire"
      autoclean = "true"
    }

    expiration {
      days = 30
    }
  }

  replication_configuration {
    role = aws_iam_role.log_replication.arn


    rules {
      id     = "cla-archive-app-logs"
      status = "Enabled"


      destination {
        bucket             = "arn:aws:s3:::cla-app-logs"
        storage_class      = "STANDARD"
        account_id         = "689141309029"
        replica_kms_key_id = local.log_rep_kms_key

        access_control_translation {
          owner = "Destination"
        }
      }

      source_selection_criteria {
        sse_kms_encrypted_objects {
          enabled = true
        }
      }

    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
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

data "aws_iam_policy_document" "cla_website_logs" {
  statement {
    actions   = ["s3:PutReplicationConfiguration"]
    resources = [aws_s3_bucket.website_logs.arn]
    principals {
      identifiers = [aws_iam_role.log_replication.arn]
      type        = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "cla_website_logs" {
  bucket = aws_s3_bucket.website_logs.id
  policy = data.aws_iam_policy_document.cla_website_logs.json
}
