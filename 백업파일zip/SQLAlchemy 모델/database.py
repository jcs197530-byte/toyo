"""
SQLAlchemy 2.0 엔진 / 세션 부트스트랩

- DB: PostgreSQL 16 (Docker, pg-lab)
- 드라이버: psycopg 3.x (psycopg2 아님) -> "postgresql+psycopg://" 스킴 사용
- models.py 는 여기서 정의한 Base를 그대로 import 해서 사용한다.
"""
import os

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker


class Base(DeclarativeBase):
    pass


# 운영 환경에서는 비밀번호를 코드에 두지 말고 환경변수(.env 등)로 분리할 것.
DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql+psycopg://postgres:postgres@localhost:5432/toyo",
)

engine = create_engine(DATABASE_URL, pool_pre_ping=True, echo=False)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


def get_db():
    """FastAPI Depends용 세션 제너레이터"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
