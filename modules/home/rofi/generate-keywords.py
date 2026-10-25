import json
import re
import sys
from pathlib import Path

rofimoji_data_dir = Path(sys.argv[1])
en_annotations_path = Path(sys.argv[2])
en_annotations_derived_path = Path(sys.argv[3])
out_dir = Path(sys.argv[4])

GROUPS = [
    "emojis_smileys_emotion",
    "emojis_people_body",
    "emojis_animals_nature",
    "emojis_food_drink",
    "emojis_activities",
    "emojis_travel_places",
    "emojis_objects",
    "emojis_symbols",
    "emojis_flags",
]

# CLDR keys sometimes omit the variation selector present in rofimoji's own characters.
VS_RE = re.compile("[︎️]")


def strip_vs(s: str) -> str:
    return VS_RE.sub("", s)


en_ann = json.loads(en_annotations_path.read_text())["annotations"]["annotations"]
en_der = json.loads(en_annotations_derived_path.read_text())["annotationsDerived"]["annotations"]


def build_stripped(d: dict) -> dict:
    stripped = {}
    for k, v in d.items():
        stripped.setdefault(strip_vs(k), v)
    return stripped


en_ann_stripped = build_stripped(en_ann)
en_der_stripped = build_stripped(en_der)

# Known CLDR keyword oddities/slang not worth surfacing in a picker.
NOISE = {"143", "ily", "xoxo", "bae", "rewindershins"}
WORD_RE = re.compile(r"^[a-zA-Z][a-zA-Z -]*$")


def cldr_keywords(char: str) -> list[str]:
    entry = (
        en_ann.get(char)
        or en_der.get(char)
        or en_ann_stripped.get(strip_vs(char))
        or en_der_stripped.get(strip_vs(char))
    )
    return entry.get("default", []) if entry else []


out_dir.mkdir(parents=True, exist_ok=True)

for group in GROUPS:
    csv_path = rofimoji_data_dir / f"{group}.csv"
    out_lines = []
    for line in csv_path.read_text().strip("\n").split("\n"):
        char, desc = line.split(" ", 1)
        desc_lower = desc.lower()
        new_keywords = []
        for kw in cldr_keywords(char):
            if kw in NOISE or not WORD_RE.match(kw) or kw.lower() in desc_lower:
                continue
            if kw not in new_keywords:
                new_keywords.append(kw)
        if new_keywords:
            out_lines.append(f"{char} {', '.join(new_keywords)}")

    (out_dir / f"{group}.additional.csv").write_text("\n".join(out_lines) + "\n")
