resource "aws_iam_policy" "policy-globant_lambda" {
  name        = "globant_lambda"
  path        = "/"
  description = "Allow * for AWS Glue and S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "glue:*",
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "iam_role-globant_lambda" {
  name = "globant_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach-globant_lambda" {
  role       = aws_iam_role.iam_role-globant_lambda.name
  policy_arn = aws_iam_policy.policy-globant_lambda.arn
}
