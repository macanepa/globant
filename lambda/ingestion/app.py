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


def lambda_handler(event, context):
    try:
        session = get_boto_session()
        con = wr.mysql.connect("globant_connection", boto3_session=session)

        data = json.loads(event['body'])
        df = pd.DataFrame.from_dict(data['records'])

        wr.mysql.to_sql(
            df=df,
            table=data['table'],
            schema=data['schema'],
            con=con,
            mode="upsert_duplicate_key"
        )

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Data successfully inserted'})
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
        ]
    }

    event = {'body': json.dumps(body)}
    response = lambda_handler(event, {})
    pprint(response)
