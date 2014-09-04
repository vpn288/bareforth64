

[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.asm"

start:	
	mov	r13,[start+rax+r8]	
	ret	
	
	_pop:
        mov eax , [ r7 + r8 ]
        sub r7 , 8
	and r7 , r9
	ret
	    
  _push:
        add r7 , 8
        and r7 , r9
        mov [ r7 + r8 ] , eax
        ret
