terraform {
  backend "s3" {
    bucket = "cla-production-state-bucket"
    key    = "mozart/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = local.tags
  }
}

locals {
  tags = {
    "tf:stack" = "mozart-infra"
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