
# 1. we load the AWS provider, and define the variables for region and access credentials

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

# 2. we create the new S3 bucket

resource "aws_s3_bucket" "veeam-iac-demo" {
    bucket = "${var.bucket_name}" 
    object_lock_enabled = true
}

# 3. we define the ownership of the bucket

resource "aws_s3_bucket_ownership_controls" "veeam-iac-demo" {
  bucket = aws_s3_bucket.veeam-iac-demo.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# 4. we set the ACL for the bucket to be private

resource "aws_s3_bucket_acl" "veeam-iac-demo" {
  depends_on = [aws_s3_bucket_ownership_controls.veeam-iac-demo]

  bucket = aws_s3_bucket.veeam-iac-demo.id
  acl    = "private"
}

# 5. we configure Object Lock for the bucket

resource "aws_s3_bucket_object_lock_configuration" "veeam-iac-demo" {
  bucket = aws_s3_bucket.veeam-iac-demo.id 

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 5
    }
  }
}