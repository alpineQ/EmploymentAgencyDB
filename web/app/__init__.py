""" Flask сервер работы с EmploymentAgencyDB """
import sys
import logging
from time import sleep
from flask import Flask
import pyodbc

# pylint: disable=invalid-name
app = Flask(__name__)
app.config.from_json('config.json')

for i in range(app.config['RETRIES_NUM']):
    try:
        connection = pyodbc.connect(
            'Driver={ODBC Driver 17 for SQL Server};'
            f"Server={app.config['SERVER']};"
            f"Database={app.config['DATABASE']};"
            f"uid={app.config['USERNAME']};"
            f"PWD={app.config['PASSWORD']}"
        )
    except (pyodbc.InterfaceError, pyodbc.ProgrammingError):
        if i == app.config['RETRIES_NUM'] - 1:
            logging.error('Exceeded amount of retries. Shutting down...')
            sys.exit(-1)
        logging.warning(f"DB is launching... Retry in {app.config['RETRIES_TIMEOUT']}[{i}]")
        sleep(app.config['RETRIES_TIMEOUT'])
logging.info("Successfully connected to db")

cursor = connection.cursor()

# pylint: disable=wrong-import-position
from . import routes