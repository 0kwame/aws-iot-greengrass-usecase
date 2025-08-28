terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.53.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
  }
}

provider "awscc" {
  region = "eu-central-1"
}

provider "aws" {
  region = "eu-central-1"
}
