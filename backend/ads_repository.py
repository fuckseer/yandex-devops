from typing import List, Optional
import ydb.credentials
import uuid
from models import Ad
import datetime

_TABLE_NAME = 'series'
_INITIAL_QUERY = '''
CREATE table `{}` (
    `ad_id` String,
    `author` String,
    `title` String,
    `text` String,
    `created_at` Datetime,
    PRIMARY KEY (`ad_id`)
)
'''.format(_TABLE_NAME)



class AdsRepository:

    def __init__(self, endpoint: str, database: str):
        self._endpoint = endpoint
        self._database = database
        self._driver = ydb.DriverConfig(
            endpoint=endpoint,
            database=database,
            credentials=ydb.credentials_from_env_variables())
        self._pool: Optional[ydb.SessionPool] = None

    def _init_db(self, session: ydb.Session):
        session.execute_scheme(_INITIAL_QUERY)

    def connect(self):
        self._driver.wait(timeout=5, fail_fast=True)
        self._pool = ydb.SessionPool(self._driver)
        self._pool.retry_operation_sync(self._init_db)

    def close(self):
        self._driver.stop(timeout=5)

    def insert_ad(self, author: str, title: str, text: str):
        def callee(session) -> Ad:
            generated_uuid = uuid.uuid4()
            current_date = datetime.datetime.today()
            current_date_formatted = current_date.strftime("%Y-%m-%dT%H:%M:%SZ")
            query = '''
                INSERT INTO {} (ad_id, author, title, text, created_at)
                VALUES ("{}", "{}", "{}", '{}', DATETIME('{}'));
            '''.format(_TABLE_NAME, generated_uuid, author, title, text, current_date_formatted)
            session.transaction().execute(query, commit_tx=True)

            return Ad(ad_id=str(generated_uuid), author=author, text=text, title=title, created_at=current_date_formatted)
        
        return self._pool.retry_operation_sync(callee)
    
    def get_ads(self) -> List[Ad]:
        def callee(session):
            result: List[Ad] = []
            query = '''
                SELECT ad_id, author, title, text, created_at FROM {};
            '''.format(_TABLE_NAME)
            query_result = session.transaction().execute(query)

            for row in query_result[0].rows:
                print(row.created_at)
                result.append(Ad(
                    ad_id=row.ad_id.decode(),
                    author=row.author.decode(),
                    title=row.title.decode(),
                    text=row.text.decode(),
                    created_at=row.created_at
                ))
            
            return result
        
        return self._pool.retry_operation_sync(callee)