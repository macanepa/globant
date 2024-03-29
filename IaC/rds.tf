resource "aws_db_instance" "database" {
  allocated_storage       = 10
  engine                  = "mysql"
  engine_version          = "8.0.36"
  instance_class          = "db.t3.micro"
  username                = var.rds_username
  password                = var.rds_password
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  publicly_accessible     = true
  apply_immediately       = true # just for testing purposes
  identifier              = "aws-data-pipeline-db"
  backup_retention_period = 7 # we still use this type of backup
  backup_window           = "06:00-07:00"
  maintenance_window      = "Sun:00:00-Sun:03:00"
}
