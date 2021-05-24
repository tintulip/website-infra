# website-infra

Manages infrastructure for team Mozart.

## Assumptions

The following resources have been created through a protected endpoint.

- State bucket to already have been created.
- IAM user and role 
- Role has an amazon managed `AmazonS3FullAccess` policy attached to it.
- IAM user Secret and Access Key stored in GitHub Secrets.

## Variables

- AWS Account ID 
- Website Name

## Creates

- S3 bucket for website static files
- Bucket for access logging expired after 30 days and replication rules to log-archive account
- CloudFront distribution for access to static resources
- IAM user and permission to push content to website

## Actions in workflows

Currently we are using the following actions in the CI/CD:
- [checkout](https://github.com/actions/checkout)
- [Set up terraform](https://github.com/hashicorp/setup-terraform)
- [tfsec](https://github.com/triat/terraform-security-scan) 

## CloudFront considerations

Referred to [this reference architecture](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/getting-started-secure-static-website-cloudformation-template.html) and simplified to remove unnecessary elements.
Specifically, only the CF distribution has been kept - the security headers lambda is not worth the price as the main target for the Red Team is to attack our infrastructure rather than attacking our users.
Similar reasoning applies to not adding a WAF, as Checkov and tfsec suggest.
Protocol version has been updated from the suggested one as per tfsec suggestion.

DNS is not in scope as it's not necessary to access the website, costly and there are concerns over which DNS name to use and its management.

## S3 log replication

Website access is logged in an S3 bucket that is replicated in the log archive account. Since objects are encrypted on the source bucket, the replication is using a kms key to encrypt and decrypt the objects during the replication to the destination bucket. This key is stored in the log-archive account.
