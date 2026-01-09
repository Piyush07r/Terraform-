# -------------------------------
# S3 Bucket Creation
# ------------------------------

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-terraform-demo-bucket-12345" # Must be globally unique
  force_destroy = true                      # Deletes objects when bucket is destroyed

  tags = {
    Name        = "terraform-s3-bucket"
    Environment = "dev"
  }
}

# -------------------------------
# S3 Bucket Versioning
# -------------------------------

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled" # Enables object versioning
  }
}

# -------------------------------
# S3 Bucket Server-Side Encryption
# -------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # AWS-managed encryption
    }
  }
}

# -------------------------------
# Block Public Access (Best Practice)
# -------------------------------

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
