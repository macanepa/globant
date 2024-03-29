# AWS ETL Pipeline Architecture README

This README file provides an overview of the ETL (Extract, Transform, Load) pipeline architecture implemented on AWS.

## Architecture Overview

The ETL pipeline architecture consists of the following components:

+ **RDS**: MySQL in RDS serves as the target Database.

## Environment Variables

The following environment variables are required for configuring this architecture:

- `TF_rds_username`: This variable represents the master username for accessing the target MySQL database.
- `TF_rds_password`: This variable contains the password for accessing the target MySQL database.


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