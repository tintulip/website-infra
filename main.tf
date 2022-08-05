terraform {
  backend "s3" {
    bucket   = "tfstate-073232250817-production"
    key      = "website-infra/terraform.tfstate"
    region   = "eu-west-2"
    role_arn = "arn:aws:iam::073232250817:role/website-infra"
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
      version = "~> 4.25"
    }
  }
}