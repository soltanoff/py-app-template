import hashlib


def root() -> dict[str, str]:
    return {"message": "Hello World"}


def say_hello(name: str) -> dict[str, str]:
    return {"message": f"Hello {name}"}


def say_goodbye(name: str) -> dict[str, str]:
    return {"message": hashlib.md5(name.encode()).hexdigest()}
