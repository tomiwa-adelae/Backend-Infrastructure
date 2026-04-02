resource "aws_s3_bucket" "cornerstone_bucket" {
  bucket = var.bucket_name

  tags = {
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.cornerstone_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership]
  bucket = aws_s3_bucket.cornerstone_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.cornerstone_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}


data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = [
      "${aws_s3_bucket.cornerstone_bucket.arn}",
      "${aws_s3_bucket.cornerstone_bucket.arn}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

