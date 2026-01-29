resource "aws_s3_bucket" "help_site" {

  bucket = "${var.project_name}-help-site-${random_id.bucket_suffix.hex}"

}



resource "aws_s3_bucket_website_configuration" "site_config" {

  bucket = aws_s3_bucket.help_site.id



  index_document {

    suffix = "index.html"

  }

}



resource "aws_s3_bucket_public_access_block" "public_access" {

  bucket = aws_s3_bucket.help_site.id



  block_public_acls = false

  block_public_policy = false

  ignore_public_acls = false

  restrict_public_buckets = false

}



resource "aws_s3_bucket_policy" "public_read" {

  bucket = aws_s3_bucket.help_site.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Sid = "PublicReadGetObject"

        Effect = "Allow"

        Principal = "*"

        Action = "s3:GetObject"

        Resource = "${aws_s3_bucket.help_site.arn}/*"

      },

    ]

  })

  depends_on = [aws_s3_bucket_public_access_block.public_access]

}
