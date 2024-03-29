variable "region" {
  description = "This is the cloud hosting region where your webapp will be deployed."
}

variable "rds_username" {
  description = "username for the master user in RDS instance"
}

variable "rds_password" {
  description = "password for the master user in RDS instance"
}
