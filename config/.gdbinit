# GDB Configuration
set disassembly-flavor intel
set confirm off
set verbose off
set history save on
set history size 10000
set history filename ~/.gdb_history
set print pretty on
set print array on
set print array-indexes on
set python print-stack full

# Architecture detection
python
import subprocess
result = subprocess.run(['uname', '-m'], capture_output=True, text=True)
arch = result.stdout.strip()
if arch == 'x86_64':
    gdb.execute('set architecture i386:x86-64')
end

# Plugin selector (default: pwndbg)
# Change this to 'gef' or 'peda' to use different plugins
define init-pwndbg
    source /opt/tools/pwndbg/gdbinit.py
end

define init-gef
    source /opt/tools/share/gef.py
end

define init-peda
    source /opt/tools/share/peda/peda.py
end

# Default plugin
init-pwndbg

# Custom commands
define hook-stop
    x/10i $pc
    i r
end

# Aliases
alias -a xi = x/10i
alias -a xg = x/10gx
alias -a xw = x/10wx
alias -a xb = x/40bx
alias -a xs = x/10s
alias -a ii = info inferiors
alias -a it = info threads
alias -a if = info functions
alias -a ib = info breakpoints
alias -a ir = info registers
alias -a is = info stack