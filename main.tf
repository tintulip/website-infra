terraform {
  backend "s3" {
    bucket = "cla-production-state"
    key    = "website-infra/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = local.tags
  }
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/website-infra"
  }
}

locals {
  tags = {
    "tf:stack" = "website-infra"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}