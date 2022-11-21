if !has("python3")
  echo "vim has to be compiled with +python3 to run this"
  finish
endif

if exists('g:python_breakpoint_loaded')
  finish
endif

python3 << EOF

import socket
import fcntl
import struct

def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])

def generate_breakpoint(ifname, port=5679, reverse=True):
    ip = get_ip_address(ifname.encode())
    return f'breakpoint(host="{ip}", port={port}, reverse={reverse})'
EOF

let g:python_breakpoint_loaded = 1

function GenerateRemotePythonBreakpoint(ifname)
python3 << EOF
vim.command("let l:data = '" + generate_breakpoint(vim.eval("a:ifname")) + "'")
EOF
  call append(line('.'), repeat(' ', indent('.')) . l:data)
endfunction
