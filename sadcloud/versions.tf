terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = ">= 2.34.0"
  }
}

provider "aws" {
  region = "us-east-1"  # You can change this to your preferred region
}
