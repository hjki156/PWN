from pwn import *
context(arch='amd64', os='linux', log_level='debug')

# offline

io = process('./pwn')
gdb.attach(io)

# online 

# io = connect('localhost', '9999')

io.interactive()