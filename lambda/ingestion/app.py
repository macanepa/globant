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
    session = get_boto_session()
    con = wr.mysql.connect("globant_connection", boto3_session=session)

    data = event['body']
    df = pd.DataFrame.from_dict(data['records'])

    try:
        wr.mysql.to_sql(
            df=df,
            table=data['table'],
            schema=data['schema'],
            con=con,
            mode="upsert_duplicate_key"
        )
    except Exception as err:
        logging.error(str(err))


if __name__ == '__main__':
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

    event = {'body': body}
    lambda_handler(event, {})
