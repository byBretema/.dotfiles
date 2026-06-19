import sys, json

for line in sys.stdin:

    line = line.strip()
    if not line:
        continue

    try:

        obj = json.loads(line)
        if obj.get("type") != "match":
            continue

        data = obj.get("data", {})
        path = data.get("path", {}).get("text", "")

        line_number = data.get("line_number", 0)

        lines_text = data.get("lines", {}).get("text", "")
        line_count = lines_text.count(chr(10))

        col_start = data["submatches"][0].get("start", 0)
        col_end = data["submatches"][0].get("end", 0)

        if path and line_number:
            print(f"{path}@{line_number}@{col_start}@{col_end}@{line_count}")

    except:
        continue
