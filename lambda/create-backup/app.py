import json
import awswrangler as wr
import polars as pl
from boto3 import Session
import logging
import io
from datetime import datetime
from os import environ


def get_boto_session():
    try:
        return Session(profile_name='globant')
    except:
        return Session()


def lambda_handler(event, context):
    try:
        session = get_boto_session()

        data = json.loads(event['body'])
        with wr.mysql.connect("globant_connection", boto3_session=session) as con:
            df = wr.mysql.read_sql_table(
                table=data['table'],
                schema=data['schema'],
                con=con
            )

        df_polars = pl.from_pandas(df)
        buffer = io.BytesIO()
        df_polars.write_avro(buffer)

        s3 = session.client('s3')
        bucket_name = environ['BUCKET_NAME']
        current_date = datetime.now()

        file_name = data.get(
            'prefix') or f'{current_date.strftime("%Y-%m-%d %H:%M:%S")}'
        file_name = f'{data["table"]}/{file_name}'

        s3.put_object(Bucket=bucket_name, Key=file_name,
                      Body=buffer.getvalue())

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Data saved successfully'})
        }

    except Exception as e:
        logging.error(str(e))
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }
