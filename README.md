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

