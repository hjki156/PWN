
# CTF Environment Configuration
export PS1='\[\033[01;32m\][\u@ctf-pwn]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export EDITOR=nvim
export PAGER=less
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTCONTROL=ignoreboth:erasedups

# Aliases
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias vim='nvim'
alias vi='nvim'
alias cat='bat --style=plain'
alias ls='exa'
alias find='fd'
alias ps='procs'
alias top='htop'
alias du='dust'

# PWN specific aliases
alias checksec='checksec --file'
alias rop='ropper --file'
alias gadget='ROPgadget --binary'
alias objdump='objdump -M intel'
alias gdb='gdb -q'
alias r2='radare2'
alias rz='rizin'
alias strace='strace -f'
alias ltrace='ltrace -f'

# Python with venv
alias python='/opt/venv/bin/python'
alias pip='/opt/venv/bin/pip'
alias ipython='/opt/venv/bin/ipython'

# Functions
pwn-template() {
    cat > exploit.py << 'TEMPLATE'
#!/usr/bin/env python3
from pwn import *

# Configuration
context.update(
    arch='amd64',
    os='linux',
    log_level='debug',
    terminal=['tmux', 'splitw', '-h']
)

# Binary/Remote details
BINARY = './challenge'
HOST = 'localhost'
PORT = 1337

# Create connection
def connect():
    if args.REMOTE:
        return remote(HOST, PORT)
    else:
        return process(BINARY)

# Exploit
def exploit():
    p = connect()
    
    # Your exploit here
    
    p.interactive()

if __name__ == '__main__':
    exploit()
TEMPLATE
    chmod +x exploit.py
    echo "[+] PWN template created: exploit.py"
}

shellcode-template() {
    cat > shellcode.asm << 'SHELLCODE'
; x64 Linux execve("/bin/sh", NULL, NULL)
BITS 64

global _start

section .text

_start:
    xor rsi, rsi
    push rsi
    mov rdi, 0x68732f2f6e69622f
    push rdi
    push rsp
    pop rdi
    mov al, 59
    cdq
    syscall
SHELLCODE
    echo "[+] Shellcode template created: shellcode.asm"
}

libc-find() {
    if [ -z "$1" ]; then
        echo "Usage: libc-find <function_name> <address>"
        return 1
    fi
    python -c "from LibcSearcher import *; libc = LibcSearcher('$1', int('$2', 16)); print(libc)"
}

aslr() {
    if [ "$1" = "on" ]; then
        echo 2 | sudo tee /proc/sys/kernel/randomize_va_space
    elif [ "$1" = "off" ]; then
        echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
    else
        cat /proc/sys/kernel/randomize_va_space
    fi
}

# PATH additions
export PATH="/opt/tools/bin:/opt/venv/bin:${PATH}"
export LD_LIBRARY_PATH="/opt/glibc/2.31:/opt/glibc/2.27:/opt/glibc/2.23:${LD_LIBRARY_PATH}"

# Auto-activate virtual environment
source /opt/venv/bin/activate 2>/dev/null || true

# Welcome message
if [ -z "$WELCOME_SHOWN" ]; then
    export WELCOME_SHOWN=1
    figlet -f slant "CTF PWN" | lolcat
    echo -e "\033[1;32m╔════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;32m║          🚀 Ultimate CTF Pwn Environment Ready! 🚀          ║\033[0m"
    echo -e "\033[1;32m╠════════════════════════════════════════════════════════════╣\033[0m"
    echo -e "\033[1;32m║ 🔧 Tools: pwntools, gdb+pwndbg/gef/peda, radare2, angr     ║\033[0m"
    echo -e "\033[1;32m║ 📚 Libs: Multiple glibc versions, LibcSearcher ready       ║\033[0m"
    echo -e "\033[1;32m║ 🎯 Templates: pwn-template, shellcode-template             ║\033[0m"
    echo -e "\033[1;32m║ 📁 Workdir: /home/CTF/{pwn,reverse,crypto,web,misc}        ║\033[0m"
    echo -e "\033[1;32m║ 💡 Commands: checksec, rop, gadget, libc-find, aslr        ║\033[0m"
    echo -e "\033[1;32m╚════════════════════════════════════════════════════════════╝\033[0m"
fi

# Start in CTF directory
cd /home/CTF 2>/dev/null || cd ~