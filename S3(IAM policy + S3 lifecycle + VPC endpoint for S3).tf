# -------------------------------
# S3 Bucket Creation
# -------------------------------

resource "aws_s3_bucket" "my_bucket" {
  bucket        = "my-terraform-demo-bucket-12345" # Must be globally unique
  force_destroy = true                              # Deletes objects when bucket is destroyed

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
    status = "Enabled"
  }
}

# -------------------------------
# S3 Bucket Server-Side Encryption
# -------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------------------------------
# Block Public Access
# -------------------------------

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------
# S3 Lifecycle Rule (Expire objects after 30 days)
# -------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "expire-objects"
    status = "Enabled"

    expiration {
      days = 30
    }

    filter {
      prefix = "" # Applies to all objects
    }
  }
}

# -------------------------------
# IAM Policy for S3 Access
# -------------------------------

resource "aws_iam_policy" "s3_policy" {
  name        = "S3AccessPolicy"
  description = "IAM policy to allow full access to our Terraform S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.my_bucket.arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      }
    ]
  })
}

# -------------------------------
# VPC Endpoint for S3 (Private access from VPC)
# -------------------------------

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.public_rt.id
    # Add more route tables if needed
  ]

  tags = {
    Name = "S3-VPC-Endpoint"
  }
}



Note :-

Lifecycle rule – auto-delete objects after 30 days.

IAM policy – gives secure access to your bucket.

VPC Endpoint – allows private, secure S3 access from your VPC without going through the internet.
