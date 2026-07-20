#!/usr/bin/env python3
"""重新產生 src/app/fonts/noto-sans-tc-*.woff2。

Google Fonts 對 CJK 字型用 unicode-range 分片下發；本站文案零散分佈在整個
CJK Unified 區段，實測仍要下載 22 個檔（~1.6MB），拖慢 FCP。改用「只含網站
實際用到的字」的自架子集字型：從原始碼與種子 JSON 掃出所有出現過的字元，
用 fonttools 對 Google 提供的完整字重檔案子集化。

用法（文案新增字元後要重跑一次）：
    pip install fonttools brotli
    python scripts/subset-noto-sans-tc.py

需要網路連線（向 fonts.googleapis.com / fonts.gstatic.com 下載完整字重檔）。
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "src"
API_DATA_DIR = ROOT.parent / "api" / "data"
FONTS_OUT = SRC_DIR / "app" / "fonts"
WEIGHTS = ["400", "500", "600", "700", "900"]
# 基本拉丁字母/數字/標點 + 常見全形標點，即使暫時沒在文案出現也保留，
# 避免之後隨手加一個英數字元就要重跑腳本
EXTRA_RANGES = "U+0020-007E,U+2013-2014,U+2018-201D,U+2026,U+3000-303F,U+FF00-FFEF"

UA = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/125.0 Safari/537.36"
)


def collect_used_text() -> str:
    chunks: list[str] = []
    for path in SRC_DIR.rglob("*.ts*"):
        chunks.append(path.read_text(encoding="utf-8"))
    for path in API_DATA_DIR.glob("*.json"):
        chunks.append(path.read_text(encoding="utf-8"))
    return "".join(chunks)


def fetch_full_weight_ttf(weight: str, dest: Path) -> None:
    # 不帶現代瀏覽器 UA：Google Fonts 對辨識不出的 UA 只回傳單一未分片的
    # TTF（老式相容格式），正好是我們要子集化的完整字重來源
    url = f"https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@{weight}"
    with urllib.request.urlopen(url) as res:  # noqa: S310 — 固定信任來源
        css = res.read().decode("utf-8")
    match = re.search(r"url\((https://fonts\.gstatic\.com/[^)]+\.ttf)\)", css)
    if not match:
        raise RuntimeError(f"weight {weight}: 找不到字型檔網址，Google Fonts 回應：{css}")
    req = urllib.request.Request(match.group(1), headers={"User-Agent": UA})
    with urllib.request.urlopen(req) as res:  # noqa: S310
        dest.write_bytes(res.read())


def subset(src_ttf: Path, text_file: Path, dest_woff2: Path) -> None:
    subprocess.run(
        [
            sys.executable,
            "-m",
            "fontTools.subset",
            str(src_ttf),
            f"--text-file={text_file}",
            f"--unicodes={EXTRA_RANGES}",
            "--flavor=woff2",
            f"--output-file={dest_woff2}",
            "--layout-features=*",
            "--no-hinting",
        ],
        check=True,
    )


def main() -> None:
    FONTS_OUT.mkdir(parents=True, exist_ok=True)
    text = collect_used_text()
    chars = "".join(sorted(set(text)))
    print(f"掃到 {len(set(text))} 個不重複字元")

    tmp_dir = ROOT / ".font-subset-tmp"
    tmp_dir.mkdir(exist_ok=True)
    text_file = tmp_dir / "chars.txt"
    text_file.write_text(chars, encoding="utf-8")

    for weight in WEIGHTS:
        full_ttf = tmp_dir / f"notosanstc-{weight}.ttf"
        print(f"下載完整字重 {weight}…")
        fetch_full_weight_ttf(weight, full_ttf)
        dest = FONTS_OUT / f"noto-sans-tc-{weight}.woff2"
        print(f"子集化 → {dest.relative_to(ROOT)}")
        subset(full_ttf, text_file, dest)
        print(f"  {full_ttf.stat().st_size // 1024}KB → {dest.stat().st_size // 1024}KB")

    for f in tmp_dir.glob("*"):
        f.unlink()
    tmp_dir.rmdir()
    print("完成。記得重新 build 並確認 Lighthouse 分數。")


if __name__ == "__main__":
    main()
