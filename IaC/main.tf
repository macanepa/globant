terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = "globant"
  default_tags {
    tags = {
      environment = "globant"
      terraform   = true
      project     = "aws-data-pipeline"
    }
  }
}
