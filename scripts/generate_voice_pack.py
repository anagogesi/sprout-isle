#!/usr/bin/env python3
"""
Generate bundled studio-quality offline neural voice pack (.m4a + VoiceManifest.json)
for SproutIsle (小芽岛) using Microsoft Neural TTS via edge-tts + macOS afconvert.

Usage:
    uv run --with edge-tts python3 scripts/generate_voice_pack.py
"""

from __future__ import annotations

import asyncio
import hashlib
import json
import re
import subprocess
import tempfile
from pathlib import Path

import edge_tts

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "SproutIsle" / "Resources" / "Voices"
MANIFEST_PATH = OUT_DIR / "VoiceManifest.json"

ZH_VOICE = "zh-CN-XiaoyiNeural"
ZH_RATE = "-6%"
EN_VOICE = "en-US-AnaNeural"
EN_RATE = "-8%"

CONCURRENCY = 8


def sha256_key(text: str) -> str:
    return hashlib.sha256(text.strip().encode("utf-8")).hexdigest()[:16]


def parse_swift_calls(path: Path, struct_name: str) -> list[dict[str, str]]:
    """Extract string literal field assignments from Swift struct initializers."""
    src = path.read_text(encoding="utf-8")
    items: list[dict[str, str]] = []
    pattern = re.compile(rf"{re.escape(struct_name)}\s*\(")
    pos = 0
    while True:
        m = pattern.search(src, pos)
        if not m:
            break
        start = m.end()
        depth = 1
        i = start
        in_str = False
        escaped = False
        while i < len(src) and depth > 0:
            ch = src[i]
            if in_str:
                if escaped:
                    escaped = False
                elif ch == "\\":
                    escaped = True
                elif ch == '"':
                    in_str = False
            else:
                if ch == '"':
                    in_str = True
                elif ch == "(":
                    depth += 1
                elif ch == ")":
                    depth -= 1
            i += 1
        body = src[start : i - 1]
        pos = i

        fields: dict[str, str] = {}
        for fm in re.finditer(r'(\w+)\s*:\s*"((?:[^"\\]|\\.)*)"', body):
            key = fm.group(1)
            val = fm.group(2).replace('\\"', '"').replace("\\n", "\n")
            if key not in fields:
                fields[key] = val

        # Also extract string arrays like words: ["太阳", "日出", "生日"]
        for am in re.finditer(r"(\w+)\s*:\s*\[([^\]]*)\]", body):
            key = am.group(1)
            arr_vals = re.findall(r'"((?:[^"\\]|\\.)*)"', am.group(2))
            if arr_vals:
                fields[f"{key}__array"] = "||".join(arr_vals)
        items.append(fields)
    return items


def collect_phrases() -> list[tuple[str, str]]:
    """Return list of (text, lang) where lang is 'zh' or 'en'."""
    phrases: dict[str, str] = {}

    def add(text: str, lang: str = "zh") -> None:
        cleaned = text.strip()
        if cleaned:
            phrases[cleaned] = lang

    # 1. Island welcome speeches & Home mascot greetings
    for line in [
        "欢迎来到汉字谷！我们来认识汉字和拼音吧！",
        "欢迎来到数字屋！一起数一数，算一算！",
        "Welcome to English Cove! 一起来玩趣味英语吧！",
        "欢迎来到故事树！想听绘本故事，还是问十万个为什么呢？",
        "欢迎来到星星塔！看看今天的好习惯和漂亮的贴纸墙吧！",
        "你好呀！今天想去哪座小岛探险呢？",
        "点点小岛卡片，我们一起玩着学本领！",
        "收集亮晶晶的小星星，帮我长成魔法大树吧！",
        "你真是个爱学习的小天才，为你点赞！",
        "记得每天去星星塔打卡好习惯哦！",
        "点一点汉字卡片听读音，还可以打开描红画板用手指写一写哦！",
        "点一点声调滑梯，再把声母和韵母小火车拼在一起吧！",
        "听声音，找出组成词语的正确汉字！",
        "选一本喜欢的绘本点开听故事，或者用魔法绘本机创作新故事吧！",
        "有什么好奇的为什么？点一点气泡，或者问小芽宝吧！",
        "完成每天的好习惯点一点打卡，就能赢得闪闪小星星！",
        "用攒下来的星星解锁漂亮贴纸，把它们贴到你的小芽岛画板上吧！",
        "还差一点星星哦，去学习小岛收集更多星星吧！",
        "看一看前面的图形是怎么排队的，猜猜问号里应该放哪一个呢？",
        "数一数小图案，再试一次吧！",
        "再仔细看看前面的排队顺序哦！",
        "故事讲完啦！你真棒！",
        "答对啦！你真棒！",
    ]:
        add(line, "zh")

    # 2. Numbers 1..20 + Math Shapes + Counting themes
    for n in range(1, 21):
        add(str(n), "zh")

    shapes = [
        ("圆形", "像圆圆的太阳和西瓜"),
        ("正方形", "像方方的小饼干和积木"),
        ("三角形", "像美味的披萨和小山坡"),
        ("五角星", "像夜空里闪闪的小星星"),
        ("爱心", "像爸爸妈妈满满的爱"),
        ("菱形", "像飞在天空里的小风筝"),
    ]
    for cname, ex in shapes:
        add(f"{cname}，{ex}", "zh")

    math_themes = [
        ("个", "苹果"),
        ("只", "小鸭"),
        ("颗", "星星"),
        ("朵", "小花"),
        ("只", "蝴蝶"),
        ("个", "气球"),
        ("颗", "草莓"),
        ("个", "蛋糕"),
    ]
    for mw, name in math_themes:
        add(f"请数一数，草地上有几{mw}{name}呢？", "zh")
        add(f"再点一点{name}慢慢数哦！", "zh")

    # 3. Literacy: Hanzi Cards, Pinyin, Blends
    lit_path = ROOT / "SproutIsle" / "Data" / "LiteracyCatalog.swift"
    for card in parse_swift_calls(lit_path, "HanziCard"):
        ch = card["character"]
        meaning = card["meaning"]
        mnemonic = card["mnemonic"]
        words = card.get("words__array", "").split("||") if card.get("words__array") else [meaning]
        first_word = words[0] if words else meaning

        add(f"{ch}。{first_word}。{mnemonic}", "zh")
        add(f"太棒啦！你学会了{ch}！", "zh")
        add(f"写得真棒！这就是{ch}！", "zh")
        add(f"答对啦！这是{ch}！", "zh")
        add(f"那是{ch}，再找一找哦！", "zh")
        sample_word = next((w for w in words if ch in w), ch)
        add(f"小朋友，请找出「{sample_word}」里面的「{ch}」字吧！", "zh")
        for w in words:
            add(w, "zh")

    for py in parse_swift_calls(lit_path, "PinyinItem"):
        sc = py["sampleChar"]
        sw = py["sampleWord"]
        add(sc, "zh")
        add(f"{sw}的{sc}", "zh")
        if py["id"] in {"py_a", "py_o", "py_e", "py_i", "py_u", "py_v"}:
            for tone_label in ["一声平", "二声扬", "三声拐弯", "四声降"]:
                add(f"{tone_label}，{sc}", "zh")

    for bl in parse_swift_calls(lit_path, "PinyinBlend"):
        ch = bl["character"]
        word = bl["word"]
        add(f"{ch}，{word}", "zh")
        add(f"{ch}，{word}！拼读成功！", "zh")

    # 4. English: Phonics A-Z & Vocabulary Words
    eng_path = ROOT / "SproutIsle" / "Data" / "EnglishCatalog.swift"
    for ph in parse_swift_calls(eng_path, "PhonicsCard"):
        letter = ph["letter"]
        word = ph["word"]
        sentence = ph["sentence"]
        add(f"{letter}. {word}!", "en")
        add(f"{letter}, {word}", "en")
        add(f"{letter}. {word}. {sentence}", "en")
        add(f"{letter}, {word}! {sentence}", "en")
        add(f"Great job! {letter} is for {word}!", "en")
        add(f"{letter} is for {word}!", "en")

    for wc in parse_swift_calls(eng_path, "EnglishWordCard"):
        word = wc["word"]
        sentence = wc["sentence"]
        add(word, "en")
        add(f"{word}. {sentence}", "en")
        add(f"Wonderful! {word}!", "en")
        add(f"Where is the {word}? {word}!", "en")
        add(f"Where is the {word}?", "en")
        add(f"Yes! {word}! Awesome!", "en")
        add(f"That is {word}. Try again!", "en")
        add(f"Super! {word}! Good job!", "en")

    # 5. Stories & 100k Whys
    story_path = ROOT / "SproutIsle" / "Data" / "StoryCatalog.swift"
    for page in parse_swift_calls(story_path, "StoryPage"):
        title = page.get("title", "")
        narration = page.get("narration", "")
        if title and narration and "\\(" not in title and "\\(" not in narration:
            add(f"{title}。{narration}", "zh")

    for choice in parse_swift_calls(story_path, "StoryChoice"):
        outcome = choice.get("outcomeText", "")
        if outcome and "\\(" not in outcome:
            add(outcome, "zh")

    for qa in parse_swift_calls(story_path, "WhyQAItem"):
        q = qa.get("question", "")
        sa = qa.get("shortAnswer", "")
        exp = qa.get("kidExplanation", "")
        if q and sa and exp and "\\(" not in exp:
            add(f"{q}。{sa}。{exp}", "zh")

    # 6. Habits & Stickers
    hab_path = ROOT / "SproutIsle" / "Data" / "HabitStickerCatalog.swift"
    for hab in parse_swift_calls(hab_path, "HabitItem"):
        add(hab["encourageText"], "zh")
    for st in parse_swift_calls(hab_path, "StickerItem"):
        add(f"恭喜解锁{st['name']}贴纸！", "zh")

    return list(phrases.items())


async def synthesize_one(
    sem: asyncio.Semaphore,
    text: str,
    lang: str,
    tmp_dir: Path,
) -> tuple[str, str, bool]:
    key = sha256_key(text)
    filename = f"v_{lang}_{key}.m4a"
    out_file = OUT_DIR / filename

    if out_file.exists() and out_file.stat().st_size > 512:
        return (key, filename, False)

    voice = ZH_VOICE if lang == "zh" else EN_VOICE
    rate = ZH_RATE if lang == "zh" else EN_RATE
    mp3_path = tmp_dir / f"{key}.mp3"

    async with sem:
        for attempt in range(3):
            try:
                communicate = edge_tts.Communicate(text=text, voice=voice, rate=rate)
                await communicate.save(str(mp3_path))
                subprocess.run(
                    ["afconvert", "-f", "m4af", "-d", "aac", "-b", "36000", str(mp3_path), str(out_file)],
                    check=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                mp3_path.unlink(missing_ok=True)
                return (key, filename, True)
            except Exception as exc:
                if attempt == 2:
                    raise RuntimeError(f"Failed to synthesize '{text[:25]}': {exc}") from exc
                await asyncio.sleep(0.8 * (attempt + 1))

    return (key, filename, False)


async def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    items = collect_phrases()
    print(f"Collected {len(items)} unique phrases to synthesize...")

    sem = asyncio.Semaphore(CONCURRENCY)
    manifest: dict[str, str] = {}
    generated_count = 0
    cached_count = 0

    with tempfile.TemporaryDirectory() as tmp:
        tmp_dir = Path(tmp)
        tasks = [synthesize_one(sem, text, lang, tmp_dir) for text, lang in items]
        done = 0
        for coro in asyncio.as_completed(tasks):
            key, filename, was_new = await coro
            manifest[key] = filename
            done += 1
            if was_new:
                generated_count += 1
            else:
                cached_count += 1
            if done % 50 == 0 or done == len(items):
                print(f"Progress: {done}/{len(items)} (new={generated_count}, cached={cached_count})")

    MANIFEST_PATH.write_text(
        json.dumps(dict(sorted(manifest.items())), ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    total_bytes = sum(p.stat().st_size for p in OUT_DIR.glob("*.m4a"))
    print(f"Done! {len(manifest)} voice clips written to {OUT_DIR} ({total_bytes / 1024 / 1024:.2f} MB)")


if __name__ == "__main__":
    asyncio.run(main())
