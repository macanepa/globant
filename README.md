# AWS ETL Pipeline Architecture

This README file provides an overview of the ETL (Extract, Transform, Load) pipeline architecture implemented on AWS.

## Metabase Dashboard Demo
Here is a public dashboard that displays some insights of the data used in this project.

https://metabase.databam.cl/public/dashboard/810e3558-5fc6-4e9e-879e-dde76b51a0d2


## Architecture Overview

The ETL pipeline architecture consists of the following components:

+ **RDS**: MySQL in RDS serves as the target Database.
+ **AWS Glue**: AWS Glue is utilized for database connection
+ **AWS Lambda**: Lambda functions are employed for serverless execution of API ingestion, backups & analytics.
+ **ECR**: Container registry storing lambda procedures as docker images.
+ **API Gateway**: Allow batch ingestion, backups & analytics through REST API.
+ **Amazon S3**: Store AVRO backups in S3 bucket.
+ **Event Bridge**: Trigger database backups based on a CRON.
+ **Cloud Watch**: Logging for ingestion, backups & analytics lambdas.

## Environment Variables

The following environment variables are required for configuring this architecture:

- `TF_VAR_rds_username`: This variable represents the master username for accessing the target MySQL database.
- `TF_VAR_rds_password`: This variable contains the password for accessing the target MySQL database.
- `TF_VAR_rds_database`: This variable contains the database named used for the MySQL database.
- `TF_VAR_s3_bucket`: This variable contains the name of the S3 bucket used to store AVRO backups.

## Usage

Once the environment variables have been set up, the architecture can be deployed using Terraform.

```bash
# inside IaC folder
terraform init
terraform apply
```

### API
An API will be created in API Gateway. Look for the generated `endpoint` and the `API Key`.

<hr>

#### Ingestion
Upsert (based on key columns) records in batch to the RDS database.

This method requires the `table`, `schema` and an array of the `records` to ingest.

> [!NOTE]  
> If any record is missing a field, that record will be excluded. This will be logged in Cloud Watch

Example:
``` bash
curl --request POST \
  --url {{ENDPOINT}}/deploy/ingestion \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: {{API_KEY}}' \
  --data '{
	"table": "departments",
	"schema": "globant",
	"records": [
		{
			"id": 1,
			"department": "Finance"
		}
	]
}'
```

<hr>

#### Create Backup
Backup a table in S3 bucket using AVRO format.

This method requires the `table` and `schema`.
There is an optional parameter `prefix` which is the prefix of the AVRO file. If `prefix` is not provided, it will use the current datetime instead.


> [!NOTE]  
> The backup file will be stored in the following path `s3://{{BUCKET_NAME}}/{{TABLE_NAME}}/{{prefix}}`

Example:
``` bash
curl --request POST \
  --url {{ENDPOINT}}/deploy/create-backup \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: {{API_KEY}}' \
  --data '{
	"table": "departments",
	"schema": "globant",
	"prefix": "my_backup"
}'
```

<hr>

#### Restore Backup
Restore a table using an AVRO backup.

This method requires the `table` and `schema` and `prefix` of the AVRO file (the same used when generating the backup).

> [!WARNING]  
> This will overwrite the current table with the backup. The `id` will be set as primary key.

Example:
``` bash
curl --request POST \
  --url {{ENDPOINT}}/deploy/restore-backup \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: {{API_KEY}}' \
  --data '{
	"table": "jobs",
	"schema": "globant",
	"prefix": "my_backup"
}'
```

<hr>

#### Database Analytics
Returns relevant insights from the RDS database in JSON format.

This method requires the `query` parameter. This value can be either `1` or `2`. The definition of these queries are located at `analytics/queries.sql`

Example:
``` bash
curl --request GET \
  --url '{{ENDPOINT}}/deploy/database-analytics?query=1' \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: {{API_KEY}}'
```




## Notes

- Ensure proper IAM (Identity and Access Management) permissions are set for accessing AWS resources. The use of aws-cli is recommended for setting up these credentials in your environment.

## Architecture Diagram
<div style="text-align:center;">
    <img src="Data Architecture.svg" alt="Data Architecture" width="auto"/>
</div>


## Contributors

- Matías Cánepa
- macanepa@miuandes.cl


---
*This README is subject to change as the architecture evolves.*