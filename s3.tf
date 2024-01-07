resource "aws_s3_bucket" "my-web" {
  bucket = "get-message-app"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site-config" {
  bucket = aws_s3_bucket.my-web.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket = aws_s3_bucket.my-web.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "s3-versioningg" {
  bucket = aws_s3_bucket.my-web.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "owner-controls" {
  bucket = aws_s3_bucket.my-web.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-public-block" {
  bucket = aws_s3_bucket.my-web.id
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_acl" "s3-acl" {
  bucket = aws_s3_bucket.my-web.id
  acl = "public-read"
  depends_on = [ 
    aws_s3_bucket_ownership_controls.owner-controls,
    aws_s3_bucket_public_access_block.s3-public-block
   ]
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.my-web.id
   policy = jsonencode({
  "Id": "Policy",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.my-web.bucket}/*",
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    }
  ]
})
}

resource "aws_s3_object" "web-obj" {
  bucket       = aws_s3_bucket.my-web.id
  key          = "index.html"
  source       = "./web-app/index.html"
  content_type = "text/html"
}


output "app-url" {
    value = "http://${aws_s3_bucket.my-web.bucket}.s3-website.${data.aws_region.current.name}.amazonaws.com"
}
