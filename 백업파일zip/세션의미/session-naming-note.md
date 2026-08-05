# 4-2. 용어 주의 — "세션" 이중 의미

toyo 프로젝트에서 "세션"은 두 가지 서로 다른 개념을 가리켜서 헷갈리기 쉽다.

- **SQLAlchemy DB 세션** (`Session`, 요청 단위 파이썬 ↔ DB 연결) — `database.py`의
  `SessionLocal`이 매 요청마다 만들어내는 그 세션이다.
- **로그인 세션** (`sessions` 테이블 행) — 계정이 로그인할 때 발급되는 토큰 1건을 뜻한다.
  레거시 `TOYO_ID_INFO.TOKEN`에 대응한다.

두 개념은 이름만 같을 뿐 완전히 다른 대상이라 동명이의어다. 임포트 충돌
(`from sqlalchemy.orm import Session`)을 막기 위해 로그인 세션 모델의 클래스명은
`LoginSession`으로 짓는다(테이블명은 `sessions` 그대로 유지).

```python
from sqlalchemy.orm import Session          # SQLAlchemy DB 세션
from models import LoginSession             # 로그인 세션(= sessions 테이블)
```
