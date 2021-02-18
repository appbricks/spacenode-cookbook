#
# S3 bucket for persisting minecraft server state
#

resource "aws_s3_bucket" "minecraft" {
  bucket_prefix = "${var.cb_vpc_name}-minecraft-server-"
  
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name = "${var.cb_vpc_name}: ${var.name} server storage"
  }
}

#
# Bucket public access configuration
#

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.minecraft.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# Policy to allow access to S3 resources
#

resource "aws_iam_role_policy" "mc_allow_ec2_to_s3" {
  name = "${var.cb_vpc_name}-minecraft-server-storage"
  role = aws_iam_role.minecraft.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.minecraft.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["${aws_s3_bucket.minecraft.arn}/*"]
    }
  ]
}
EOF
}
