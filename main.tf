terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" 
}

# This bucket stores the access logs.
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "my-app-s3-access-logs-unique-suffix"
  force_destroy = true
}


resource "aws_s3_bucket_ownership_controls" "log_bucket_oc" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Grant the Log Delivery group WRITE and READ_ACP permissions.
resource "aws_s3_bucket_acl" "log_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.log_bucket_oc]

  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}


# This is your main bucket that will generate logs.
resource "aws_s3_bucket" "source_bucket" {
  bucket = "my-main-data-bucket-unique-suffix"
}

# Link the source bucket to the log bucket
resource "aws_s3_bucket_logging" "source_bucket_logging" {
  bucket = aws_s3_bucket.source_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/" 
}