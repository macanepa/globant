variable "region" {
  description = "This is the cloud hosting region where your webapp will be deployed."
}

variable "rds_username" {
  description = "Username for the master user in RDS instance"
}

variable "rds_password" {
  description = "Password for the master user in RDS instance"
}

variable "rds_database" {
  description = "Database name for the RDS"
}

variable "s3_bucket" {
  description = "S3 bucket for AVRO backup"
}
