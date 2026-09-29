import re
import subprocess
import sys

path = sys.argv[1]
pattern = re.compile(rb"(?ms)^[ \t]*last_rectangle: Some\(\(\n.*?^[ \t]*\)\),")
baseline = subprocess.check_output(["git", "show", f":{path}"])
source = sys.stdin.buffer.read()
match = pattern.search(baseline)

if match:
    source = pattern.sub(lambda _: match.group(0), source, count=1)

sys.stdout.buffer.write(source)
