import os
import psycopg2 as ppg
from dotenv import load_dotenv


def query(q):
    '''Queries PostgreSQL using the arguments from `getArgs()` and a `psycopg2` cursor'''
    conn = None
    try:
        conn = ppg.connect(**getArgs())
        c = conn.cursor()
        c.execute(q)
        rows = c.fetchall()
        c.close()
    except (Exception, ppg.DatabaseError) as e:
        print(e)
        return
    finally:
        if conn is not None:
            conn.close()
    return rows


def getArgs():
    '''Returns SQL arguments from `../.env` using `python-dotenv` and a dictionary'''
    load_dotenv('../.env')
    map = {
        'PG_HOST': 'host',
        'PG_PORT': 'port',
        'PG_DATABASE': 'database',
        'PG_USER': 'user',
        'PG_PASSWORD': 'password',
    }
    ret = {}
    for var in map:
        if not var in os.environ:
            raise Exception(f'{var} variable is required in .env.')
        ret[map[var]] = os.environ[var]
    return ret
