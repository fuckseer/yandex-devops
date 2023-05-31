from pydantic import BaseModel
import datetime


class Ad(BaseModel):
    ad_id: str
    author: str
    text: str
    title: str
    created_at: datetime.datetime


class AddAd(BaseModel):
    author: str
    text: str
    title: str
