set debuginfod enabled off
set print pretty on
set print frame-arguments scalars
set print static-members off
set print elements 32
set print vtbl off

# gdb-dashboard (cloned by install.sh; guarded for machines without it)
python
import os
p = os.path.expanduser('~/.local/share/gdb-dashboard/.gdbinit')
if os.path.exists(p):
    gdb.execute('source ' + p)
end
