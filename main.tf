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

# 1. S3 Bucket for Data and ML Models
resource "aws_s3_bucket" "data_bucket" {
  bucket = "s3-g1mg06"  
  force_destroy = true 
}

# Enable versioning for the data bucket (Best Practice)
resource "aws_s3_bucket_versioning" "data_bucket_versioning" {
  bucket = aws_s3_bucket.data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. ECR Repository for Docker Images
resource "aws_ecr_repository" "mlops_repo" {
  name                 = "ecr-g1mg06" 
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Output the names to confirm creation
output "s3_bucket_name" {
  value = aws_s3_bucket.data_bucket.bucket
}

output "ecr_repository_url" {
  value = aws_ecr_repository.mlops_repo.repository_url
}


# 1. IAM Role: Allows App Runner to pull images from ECR
resource "aws_iam_role" "apprunner_role" {
  name = "apprunner-role-g1mg06"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# Attach permissions to the role
resource "aws_iam_role_policy_attachment" "apprunner_policy" {
  role       = aws_iam_role.apprunner_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# 2. App Runner Service: The actual running API
resource "aws_apprunner_service" "api_service" {
  service_name = "apprunner-g1mg06" 

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }

    image_repository {
      image_identifier      = "${aws_ecr_repository.mlops_repo.repository_url}:latest"
      image_repository_type = "ECR"
      
      image_configuration {
        port = "8000" 
        
        # Pass environment variables to the running container
        runtime_environment_variables = {
          AWS_REGION = "eu-west-3"
        }

        instance_role_arn = aws_iam_role.app_instance_role.arn
      }
    }
    
    # Enable Auto-Deploy: Updates automatically when you push a new image!
    auto_deployments_enabled = true
  }

  depends_on = [aws_iam_role_policy_attachment.apprunner_policy]
}

# Output the public URL
output "app_url" {
  value = aws_apprunner_service.api_service.service_url
}

resource "aws_iam_role" "app_instance_role" {
  name = "apprunner-instance-role-g1mg06"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# Give it Read-Only access to S3
resource "aws_iam_role_policy_attachment" "app_s3_access" {
  role       = aws_iam_role.app_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}