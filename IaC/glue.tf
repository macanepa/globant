resource "aws_glue_connection" "database_connection" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${aws_db_instance.database.address}:3306/${var.rds_database}"
    PASSWORD            = var.rds_password
    USERNAME            = var.rds_username
  }

  name = "globant_connection"
}
