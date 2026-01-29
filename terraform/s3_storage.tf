resource "random_id" "bucket_suffix" {

  byte_length = 4

}



resource "aws_s3_bucket" "app_storage" {

  bucket = "${var.project_name}-storage-${random_id.bucket_suffix.hex}"

}



resource "aws_s3_bucket_lifecycle_configuration" "app_lifecycle" {

  bucket = aws_s3_bucket.app_storage.id



  rule {

    id = "MoveToGlacier"

    status = "Enabled"



    filter {

      prefix = ""

    }



    transition {

      days = 30

      storage_class = "GLACIER"

    }

  }

}
