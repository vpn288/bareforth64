_hex_dot:
call	_pop
mov	[value],rax
movdqu xmm0, [value] ;
pxor xmm1,xmm1
punpcklbw xmm0,xmm1
movdqa xmm1,xmm0
pand xmm1,[fes]
psllq xmm0,4
pand xmm0,[fes]
por xmm0,xmm1
movdqa xmm1,xmm0
paddb xmm1,[sixes]
psrlq xmm1,4
pand xmm1,[fes]
pxor xmm9,xmm9
psubb xmm9,xmm1
pand xmm9,[sevens]
paddb xmm0,xmm9
paddb xmm0,[zeroes]
movdqu [hexstr],xmm0
mov	rax,[hexstr]
mov	r15,[hexstr+8]
bswap	rax
bswap	r15
mov	[hexstr],r15
mov	[hexstr+8],rax
mov	byte [hexstr+17],0
call	_space
mov	rsi,hexstr
mov	rcx,16
call os_output
call	_space
ret
