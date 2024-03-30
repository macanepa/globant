import json
import awswrangler as wr
import polars as pl
from boto3 import Session
import logging
import io
from os import environ


def get_boto_session():
    try:
        return Session(profile_name='globant')
    except:
        return Session()


def lambda_handler(event, context):
    session = get_boto_session()
    try:
        data = json.loads(event['body'])

        table = data['table']
        schema = data['schema']
        prefix = data['prefix']

        s3 = session.client('s3')
        bucket_name = environ['BUCKET_NAME']
        object_key = f'{table}/{prefix}'

        response = s3.get_object(Bucket=bucket_name, Key=object_key)
        data_bytes = response['Body'].read()
        df = pl.read_avro(io.BytesIO(data_bytes))
        df_pandas = df.to_pandas()

        with wr.mysql.connect("globant_connection", boto3_session=session) as con:
            wr.mysql.to_sql(
                df=df_pandas,
                table=table,
                schema=schema,
                con=con,
                mode="overwrite"
            )

            # make sure to set id as primary key
            cursor = con.cursor()
            sql = f"ALTER TABLE {schema}.{table} MODIFY id INT PRIMARY KEY"
            cursor.execute(sql)
            con.commit()

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Table restored successfully'})
        }

    except Exception as e:
        logging.error(str(e))
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }
