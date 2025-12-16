terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configuration du backend S3 pour stocker le state
  backend "s3" {
    bucket  = "infrastats-g1mg06"
    key     = "g1mg06.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}
