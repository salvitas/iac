// Bucket for FrontEnd - Web and App (iOS & Android)
resource "aws_s3_bucket" "web_bucket" {
  bucket = var.bucket_name
  acl    = "public-read"
  force_destroy = true
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = var.bucket_policy_id
    Statement = [
      {
        Sid       = "PublicReadForGetBucketObjects"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.web_bucket.arn}/*"
        ]
      },
    ]
  })
}