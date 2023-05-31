from typing import List
from fastapi import FastAPI, APIRouter, Request
from fastapi.middleware.cors import CORSMiddleware
from ads_repository import AdsRepository
from dotenv import load_dotenv
import os
import uvicorn
import platform

from models import Ad, AddAd

router = APIRouter()


@router.get("/test")
def test():
    return "Hello, world"

@router.get("/version")
def app_version():
    with open(".version", "r") as f:
        return f.read(), platform.node()

@router.get("/ads")
def ads(request: Request) -> List[Ad]:
    repository: AdsRepository = request.app.ads_repository

    return repository.get_ads()


@router.post("/ads")
async def add_ad(request: Request, ad: AddAd):
    repository: AdsRepository = request.app.ads_repository
    return repository.insert_ad(**ad.dict())


def main():
    load_dotenv()

    print('Starting app...')
    app = FastAPI()
    origins = ["*"]

    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    ads_repository = AdsRepository(endpoint=os.environ.get("ENDPOINT"), database=os.environ.get("DB"))
    ads_repository.connect()
    app.ads_repository = ads_repository

    app.include_router(router)
    uvicorn.run(app, host='0.0.0.0', port=8080)


if __name__ == '__main__':
    main()
