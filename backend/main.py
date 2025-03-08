from fastapi import FastAPI

import service
import settings


app = FastAPI(
    title="Python App Template",
    description="So, you want to create a Python app? This is the template you need",
    version=settings.VERSION,
)


@app.get("/")
async def root():
    return service.root()


@app.get("/hello/{name}")
async def say_hello(name: str):
    return service.say_hello(name)


@app.get("/goodbye/{name}")
async def say_goodbye(name: str):
    return service.say_goodbye(name)
