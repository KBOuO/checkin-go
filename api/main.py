"""打卡趣 CheckinGo — 行銷資料 API（唯讀種子資料，無資料庫）。"""

import json
import os
from datetime import datetime, timezone
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

DATA_DIR = Path(__file__).parent / "data"


class Spot(BaseModel):
    id: str
    name: str
    city: str
    description: str
    tags: list[str]
    lat: float
    lng: float
    checkin_radius_m: int


class Campaign(BaseModel):
    id: str
    title: str
    slogan: str
    description: str
    starts_at: datetime
    ends_at: datetime
    stamp_goal: int
    reward: str
    spot_ids: list[str]


def _load(name: str):
    # utf-8-sig：Windows 工具鏈可能混入 BOM，防禦性讀取
    with open(DATA_DIR / name, encoding="utf-8-sig") as f:
        return json.load(f)


SPOTS = [Spot(**s) for s in _load("spots.json")]
CAMPAIGNS = [Campaign(**c) for c in _load("campaigns.json")]

app = FastAPI(title="CheckinGo Marketing API", version="0.1.0")

_origins = [
    o.strip()
    for o in os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(",")
    if o.strip()
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins,
    allow_methods=["GET"],
    allow_headers=["*"],
)


@app.get("/api/spots", response_model=list[Spot])
def list_spots(city: str | None = None):
    if city is None:
        return SPOTS
    return [s for s in SPOTS if s.city == city]


@app.get("/api/spots/{spot_id}", response_model=Spot)
def get_spot(spot_id: str):
    for s in SPOTS:
        if s.id == spot_id:
            return s
    raise HTTPException(status_code=404, detail="spot not found")


@app.get("/api/campaigns/current", response_model=Campaign)
def current_campaign():
    now = datetime.now(timezone.utc)
    for c in CAMPAIGNS:
        if c.starts_at <= now <= c.ends_at:
            return c
    raise HTTPException(status_code=404, detail="no active campaign")
