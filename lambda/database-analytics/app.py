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
    query_id = event['queryStringParameters'].get('query')

    if query_id not in ['1', '2']:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'query parameter not defined correctly'})
        }

    session = get_boto_session()
    if query_id == '1':
        query = """
        SELECT 
            d.department, 
            j.job, 
            SUM(CASE WHEN MONTH(h.datetime) BETWEEN 1 AND 3 THEN 1 ELSE 0 END) AS Q1,
            SUM(CASE WHEN MONTH(h.datetime) BETWEEN 4 AND 6 THEN 1 ELSE 0 END) AS Q2,
            SUM(CASE WHEN MONTH(h.datetime) BETWEEN 7 AND 9 THEN 1 ELSE 0 END) AS Q3,
            SUM(CASE WHEN MONTH(h.datetime) BETWEEN 10 AND 12 THEN 1 ELSE 0 END) AS Q4
        FROM globant.hired_employees h
        LEFT JOIN globant.departments d ON h.department_id = d.id
        LEFT JOIN globant.jobs j ON h.job_id = j.id
        WHERE YEAR(h.datetime) = 2021
        GROUP BY d.department, j.job
        ORDER BY d.department, j.job;
        """

        with wr.mysql.connect("globant_connection", boto3_session=session) as con:
            df = wr.mysql.read_sql_query(query, con=con)

        df['Q1'] = df['Q1'].astype('Int64')
        df['Q2'] = df['Q2'].astype('Int64')
        df['Q3'] = df['Q3'].astype('Int64')
        df['Q4'] = df['Q4'].astype('Int64')
        response = df.to_json(orient='records')

    elif query_id == '2':
        query = """
        WITH new_hires_by_department AS (
            SELECT h.department_id, COUNT(0) AS hired
            FROM globant.hired_employees h
            WHERE YEAR (h.datetime) = 2021
            GROUP BY h.department_id 
        )
        SELECT d.id, d.department, hired FROM new_hires_by_department
        JOIN globant.departments d
            ON (d.id = new_hires_by_department.department_id)
        WHERE (SELECT AVG(hired) FROM new_hires_by_department) <= hired
        GROUP BY new_hires_by_department.department_id, d.department
        ORDER BY hired DESC;
        """
        with wr.mysql.connect("globant_connection", boto3_session=session) as con:
            df = wr.mysql.read_sql_query(query, con=con)

        response = df.to_json(orient='records')

    return {
        'statusCode': 200,
        'body': response
    }


if __name__ == '__main__':
    from pprint import pprint
    event = {
        'queryStringParameters': {
            'query': '2'
        }
    }

    response = lambda_handler(event, {})
    pprint(response)
