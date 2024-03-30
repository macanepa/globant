resource "aws_cloudwatch_event_rule" "departments" {
  name                = "trigger-dump-departments"
  description         = "Triggers the backup procedure for departments table"
  schedule_expression = "cron(30 * ? * * *)"
  is_enabled          = true
}
resource "aws_cloudwatch_event_target" "departments" {
  rule      = aws_cloudwatch_event_rule.departments.name
  target_id = aws_lambda_function.create-backup.function_name
  arn       = aws_lambda_function.create-backup.arn
  input     = <<JSON
{"body": "{\"table\": \"departments\",\"schema\": \"globant\"}"}
JSON
}
resource "aws_lambda_permission" "departments" {
  statement_id  = "AllowExecutionFromCloudWatch_departments"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create-backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.departments.arn
}




resource "aws_cloudwatch_event_rule" "jobs" {
  name                = "trigger-dump-jobs"
  description         = "Triggers the backup procedure for jobs table"
  schedule_expression = "cron(30 * ? * * *)"
  is_enabled          = true
}
resource "aws_cloudwatch_event_target" "jobs" {
  rule      = aws_cloudwatch_event_rule.jobs.name
  target_id = aws_lambda_function.create-backup.function_name
  arn       = aws_lambda_function.create-backup.arn
  input     = <<JSON
{"body": "{\"table\": \"jobs\",\"schema\": \"globant\"}"}
JSON
}
resource "aws_lambda_permission" "jobs" {
  statement_id  = "AllowExecutionFromCloudWatch_jobs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create-backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.jobs.arn
}




resource "aws_cloudwatch_event_rule" "hired_employees" {
  name                = "trigger-dump-hired_employees"
  description         = "Triggers the backup procedure for hired_employees table"
  schedule_expression = "cron(30 * ? * * *)"
  is_enabled          = true
}
resource "aws_cloudwatch_event_target" "hired_employees" {
  rule      = aws_cloudwatch_event_rule.hired_employees.name
  target_id = aws_lambda_function.create-backup.function_name
  arn       = aws_lambda_function.create-backup.arn
  input     = <<JSON
{"body": "{\"table\": \"hired_employees\",\"schema\": \"globant\"}"}
JSON
}
resource "aws_lambda_permission" "hired_employees" {
  statement_id  = "AllowExecutionFromCloudWatch_hired_employees"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create-backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.hired_employees.arn
}
