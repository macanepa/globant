# AWS ETL Pipeline Architecture README

This README file provides an overview of the ETL (Extract, Transform, Load) pipeline architecture implemented on AWS.

## Architecture Overview

The ETL pipeline architecture consists of the following components:

+ **RDS**: MySQL in RDS serves as the target Database.
+ **AWS Glue**: AWS Glue is utilized for database connection and eventually for ETL job orchestration, and serverless extract, transform, load (ETL) capability used for storing AVRO backups dumps in S3.
+ **AWS Lambda**: Lambda functions are employed for serverless execution of API ingestion.
+ **API Gateway**: Allow batch ingestion & backup through REST API.
+ **Amazon S3**: Store AVRO backups in S3 bucket.

## Environment Variables

The following environment variables are required for configuring this architecture:

- `TF_VAR_rds_username`: This variable represents the master username for accessing the target MySQL database.
- `TF_VAR_rds_password`: This variable contains the password for accessing the target MySQL database.
- `TF_VAR_rds_database`: This variable contains the database named used for the MySQL database.
- `TF_VAR_s3_bucket`: This variable contains the name of the bucket used to store AVRO backups.

## Usage

Once the environment variables are set up, the architecture can be deployed using Terraform.

```bash
terraform init
terraform apply
```

## Notes

- Ensure proper IAM (Identity and Access Management) permissions are set for accessing AWS resources. I recommend using aws-cli to setup these credentials in your environment.

## Contributors

- Matías Cánepa
- macanepa@miuandes.cl


---
*This README is subject to change as the architecture evolves.*