resource "aws_iam_role" "ec2_role" {

  name = "EC2-S3-Access-Role"



  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [{

      Action = "sts:AssumeRole"

      Effect = "Allow"

      Principal = { Service = "ec2.amazonaws.com" }

    }]

  })

}



resource "aws_iam_role_policy_attachment" "s3_access" {

  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"

}



resource "aws_iam_instance_profile" "ec2_profile" {

  name = "ec2-s3-profile"

  role = aws_iam_role.ec2_role.name

}


resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cw_agent" {

  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}
