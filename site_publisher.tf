resource "aws_iam_user" "site_publisher" {
  name = "site-publisher"
  path = "/mozart/"

  tags = {
    name       = "site-publisher"
    managed_by = "terraform"
    team       = "mozart"

  }
}

resource "aws_iam_group" "site_publisher" {
  name = "site-publisher"
  path = "/"

}

resource "aws_iam_access_key" "site_publisher_key" {
  user    = aws_iam_user.site_publisher.name
  pgp_key = "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"

}

resource "aws_iam_group_membership" "site_publisher" {
  name = "site-publisher-group-membership"

  users = [
    aws_iam_user.site_publisher.name

  ]

  group = aws_iam_group.site_publisher.name

}

resource "aws_iam_group_policy" "site_publisher_policy" {
  name   = "site-publisher-policy"
  group  = aws_iam_group.site_publisher.name
  policy = data.aws_iam_policy_document.site_publisher_assume_role.json

}

resource "aws_iam_role" "site_publisher_role" {
  name               = "site-publisher"
  assume_role_policy = data.aws_iam_policy_document.site_publisher_trust_role_policy.json
  inline_policy {
    name   = "site_publisher_policy"
    policy = data.aws_iam_policy_document.publish_website_s3_policy.json

  }

  tags = {
    name       = "site-publisher"
    managed_by = "terraform"
    team       = "mozart"
  }
}

data "aws_iam_policy_document" "site_publisher_trust_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.site_publisher.arn]
    }
  }
}

data "aws_iam_policy_document" "site_publisher_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    resources = [aws_iam_role.site_publisher_role.arn]

  }
}

data "aws_iam_policy_document" "publish_website_s3_policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [aws_s3_bucket.website_root.arn]
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.website_root.arn}/*"]
  }


}

resource "aws_iam_role" "log-replication" {
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

resource "aws_iam_policy" "log-replication-policy" {
  policy = data.aws_iam_policy_document.log-replication-policy.json
  name   = "log-replication"
}

data "aws_iam_policy_document" "log-replication-policy" {
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
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
      "s3:ReplicateTags"
    ]

    resources = [
      "arn:aws:s3:::cla-app-logs/*"
    ]
  }
}