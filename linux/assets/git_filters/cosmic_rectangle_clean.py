import os
import re
import subprocess
import sys

# git's %f can be worktree-relative or absolute depending on how the file was
# staged; `:{abs}` would be parsed as a :/root-relative pathspec and fail.
path = sys.argv[1]
top = subprocess.check_output(
    ["git", "rev-parse", "--show-toplevel"], text=True
).strip()
if os.path.isabs(path):
    path = os.path.relpath(path, top)
path = os.path.normpath(path)

pattern = re.compile(rb"(?ms)^[ \t]*last_rectangle: Some\(\(\n.*?^[ \t]*\)\),")
try:
    baseline = subprocess.check_output(["git", "-C", top, "show", f":{path}"])
except subprocess.CalledProcessError:
    # no index version yet (new file): pass content through unchanged
    baseline = b""
source = sys.stdin.buffer.read()
match = pattern.search(baseline)

if match:
    source = pattern.sub(lambda _: match.group(0), source, count=1)

sys.stdout.buffer.write(source)
