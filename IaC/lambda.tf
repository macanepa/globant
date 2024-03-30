resource "aws_lambda_function" "ingestion" {
  function_name = "ingestion"
  role          = aws_iam_role.iam_role-globant_lambda.arn
  image_uri     = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/ingestion:latest"
  memory_size   = 1024
  timeout       = 60
  package_type  = "Image"
}

resource "aws_lambda_function" "create-backup" {
  function_name = "create-backup"
  role          = aws_iam_role.iam_role-globant_lambda.arn
  image_uri     = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/create-backup:latest"
  memory_size   = 1024
  timeout       = 60
  package_type  = "Image"
}

