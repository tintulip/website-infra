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
      "sts:AssumeRole"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_group.site_publisher.arn]
    }
  }
}

data "aws_iam_policy_document" "site_publisher_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    resources = [aws_iam_role.site_publisher_role.arn]

  }
}

data "aws_iam_policy_document" "publish_website_s3_policy" {
  statement {
    actions = [
      "s3:GetBucketWebsite",
      "s3:GetBucket",
      "s3:ListBucket",
      "s3:PutBucketWebsite"
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