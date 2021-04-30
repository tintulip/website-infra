# website-infra

Manages infrastructure for team mozart.

## Assumptions
The following resources have been created manually through a protected end point.

- State bucket to already have been created.
- IAM user and role 
- Role has an amazon managed `AmazonS3FullAccess` policy attached to it.
- IAM user Secret and Access Key stored in GitHub Secrets.

## Variables
- AWS Account ID 
- Website Name

## Created
- Two S3 buckets created
- Logging bucket and website bucket.

## Actions in workflows

Currently we are using the following actions in the CI/CD:
- [checkout](https://github.com/actions/checkout)
- [Set up terraform](https://github.com/hashicorp/setup-terraform)
- [tfsec](https://github.com/triat/terraform-security-scan) 

