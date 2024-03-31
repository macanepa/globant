import json
import awswrangler as wr
import pandas as pd
from boto3 import Session
import logging


def get_boto_session():
    try:
        return Session(profile_name='globant')
    except:
        return Session()


def log_errors(count: int, event: dict):
    try:
        api_key_id = event['requestContext']['identity']['apiKeyId']
        message = f'{api_key_id} >> records with errors: {count}'
    except KeyError:
        message = f'UNAUTHENTICATED >> records with errors: {count}'
    logging.warning(message)


def lambda_handler(event, context):
    try:
        session = get_boto_session()

        data = json.loads(event['body'])
        df = pd.DataFrame.from_dict(data['records'])
        if df.shape[0] > 1000:
            return {
                'statusCode': 500,
                'body': json.dumps({'message': 'Exceeded 1000 records limit'})
            }

        with wr.mysql.connect("globant_connection", boto3_session=session) as con:
            query = f"DESCRIBE {data['table']};"
            table_schema = wr.mysql.read_sql_query(query, con=con)

            column_data_types = {}
            for row in table_schema.itertuples():
                column_name = row[1]
                data_type = row[2]
                column_data_types[column_name] = data_type

            columns = list(column_data_types.keys())
            df = df[columns]

            df_with_nan = df[df.isnull().any(axis=1)]
            count_incorrect_records = df_with_nan.shape[0]

            df = df.dropna()
            count_correct_records = df.shape[0]

            if count_incorrect_records > 0:
                log_errors(count=count_incorrect_records, event=event)

            wr.mysql.to_sql(
                df=df,
                table=data['table'],
                schema=data['schema'],
                con=con,
                mode="upsert_duplicate_key"
            )

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Data successfully inserted', 'records_with_errors': count_incorrect_records, 'records_upserted': count_correct_records})
        }
    except Exception as err:
        logging.error(str(err))
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error inserting data'})
        }


if __name__ == '__main__':
    from pprint import pprint
    body = {
        'table': 'departments',
        'schema': 'globant',
        'records': [
            {
                'id': 1,
                'department': 'wiwi'
            },
            {
                'id': 2,
                'department': 'wawa'
            },
            {
                'id': 3
            }
        ]
    }

    event = {'body': json.dumps(body)}
    response = lambda_handler(event, {})
    pprint(response)
