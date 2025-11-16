#!/usr/bin/env python3
"""
Convert JSONL (or JSON array) of Movielens users -> TSV (no header).

Usage:
  python3 /tmp/convert_jsonl_to_tsv_users.py /tmp/users_stripped.json /tmp/users_fixed.tsv

Output fields (tab-separated):
  _id    name    gender    age    occupation    ratings
Where ratings is:
  movieid:rating:timestamp|movieid:rating:timestamp|...

The script is defensive: tries json.loads on each line, falls back to ast.literal_eval,
and if file looks like a single JSON array it will parse that too.
"""
import sys
import json
import ast
from pathlib import Path
from typing import Any, Dict, List

def extract_ratings(movies: Any) -> str:
    if not movies:
        return ""
    parts = []
    # movies expected as list of dicts
    if isinstance(movies, list):
        for m in movies:
            try:
                mid = int(m.get("movieid", m.get("movieId", m.get("id"))))
                rating = int(m.get("rating"))
                ts = int(m.get("timestamp"))
                parts.append(f"{mid}:{rating}:{ts}")
            except Exception:
                # tolerant: try to find numeric values in dict-like object
                try:
                    vals = [str(int(v)) for v in (m if isinstance(m, (list,tuple)) else list(m.values()))[:3]]
                    if len(vals) >= 3:
                        parts.append(":".join(vals[:3]))
                except Exception:
                    continue
    else:
        # if movies is a string (rare), try to parse ints
        import re
        nums = re.findall(r"(\d+)", str(movies))
        for i in range(0, len(nums), 3):
            chunk = nums[i:i+3]
            if len(chunk) == 3:
                parts.append(":".join(chunk))
    return "|".join(parts)

def parse_line_jsonl(line: str):
    line = line.strip()
    if not line:
        return None
    # try standard JSON
    try:
        return json.loads(line)
    except Exception:
        pass
    # try Python literal
    try:
        return ast.literal_eval(line)
    except Exception:
        pass
    return None

def convert(path_in: Path, path_out: Path):
    # Try to parse as JSONL lines first
    total = 0
    written = 0
    skipped = 0
    with path_out.open("w", encoding="utf-8") as outf:
        # First pass: try per-line parse
        for line in path_in.open("r", encoding="utf-8", errors="replace"):
            total += 1
            obj = parse_line_jsonl(line)
            if obj is None:
                skipped += 1
                continue
            # expected fields
            uid = obj.get("_id") if isinstance(obj, dict) else None
            if uid is None:
                skipped += 1
                continue
            name = obj.get("name", "")
            gender = obj.get("gender", "")
            age = obj.get("age", "")
            occupation = obj.get("occupation", "")
            movies = obj.get("movies", obj.get("ratings", None))
            ratings = extract_ratings(movies)
            # write TSV line (no header)
            outf.write(f"{uid}\t{name}\t{gender}\t{age}\t{occupation}\t{ratings}\n")
            written += 1

    # If nothing written but file not empty, try reading entire file as JSON array
    if written == 0 and total > 0:
        try:
            data = json.loads(path_in.read_text(encoding="utf-8", errors="replace"))
            if isinstance(data, list):
                written2 = 0
                with path_out.open("w", encoding="utf-8") as outf:
                    for obj in data:
                        uid = obj.get("_id")
                        if uid is None:
                            continue
                        name = obj.get("name", "")
                        gender = obj.get("gender", "")
                        age = obj.get("age", "")
                        occupation = obj.get("occupation", "")
                        movies = obj.get("movies", obj.get("ratings", None))
                        ratings = extract_ratings(movies)
                        outf.write(f"{uid}\t{name}\t{gender}\t{age}\t{occupation}\t{ratings}\n")
                        written2 += 1
                print(f"WROTE {path_out} (from array), LINES_WRITTEN {written2}")
                return
        except Exception:
            pass

    print(f"WROTE {path_out}")
    print(f"TOTAL_LINES_READ {total}")
    print(f"LINES_WRITTEN {written}")
    print(f"LINES_SKIPPED {skipped}")

def main():
    if len(sys.argv) < 3:
        print("Usage: convert_jsonl_to_tsv_users.py INPUT_JSONL OUTPUT_TSV")
        sys.exit(2)
    infile = Path(sys.argv[1])
    outfile = Path(sys.argv[2])
    if not infile.exists():
        print("INPUT_NOT_FOUND", infile)
        sys.exit(1)
    convert(infile, outfile)

if __name__ == "__main__":
    main()