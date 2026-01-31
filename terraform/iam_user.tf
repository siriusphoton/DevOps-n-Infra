# 1. Create the User

resource "aws_iam_user" "audit_user" {

  name = "audit-bot"

}



# 2. Define the Policy (Read Only)

resource "aws_iam_policy" "s3_read_only" {

  name = "S3ReadOnlyPolicy"

  description = "Allow reading from the secure doc bucket only"



  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Action = ["s3:GetObject", "s3:ListBucket"]

        Effect = "Allow"

        Resource = "*" # In real life, restrict to specific bucket ARN

      },

    ]

  })

}



# 3. Attach Policy to User

resource "aws_iam_user_policy_attachment" "audit_attach" {

  user = aws_iam_user.audit_user.name

  policy_arn = aws_iam_policy.s3_read_only.arn

}



# 4. Create Keys (So we can test it)

resource "aws_iam_access_key" "audit_key" {

  user = aws_iam_user.audit_user.name

}



# 5. Output the Keys (To screen)

output "audit_access_key" {

  value = aws_iam_access_key.audit_key.id

}



output "audit_secret_key" {

  value = aws_iam_access_key.audit_key.secret

  sensitive = true

}
