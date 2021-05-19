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
inline_policy {
    name   = "log-replication-policy"
    policy = data.aws_iam_policy_document.log-replication-policy.json

  }

}

data "aws_iam_policy_document" "log-replication-policy" {
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