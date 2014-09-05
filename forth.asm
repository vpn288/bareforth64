
[BITS 64]
[ORG 0x0000000000200000]
%INCLUDE "bmdev.asm"
start:	
	mov	r8,[data_stack_base]
	xor	r10, r10
	mov	r9,[data_stack_mask]
	mov	rax,nfa_0
	call	_push
	call	_type
	ret	
_pop:
	mov rax , [ r10 + r8 ]
	sub r10 , 8
	and r10 , r9
	ret
_push:
	add r10 , 8
	and r10 , r9
	mov [ r10 + r8 ] , rax
	ret
_typez:
	call	_pop
	mov	rsi,rax
	call	b_output
	ret
_type:
	call	_pop
	mov	rcx,rax
	call	_pop
	mov	rsi,rax
	call	b_output_chars
	ret
_count:
	call	_pop
	mov	cl,[rax]
	and	rcx,0ffh
	inc	rax
	call	_push
	mov	rax,rcx
	call	_push
	ret

;-----------------------
data_stack_base	dq	0x300000
data_stack_mask	dq	0x0fffff
nfa_0:
db 7, "FORTH64" ;
db 0 ; oa?ieie?o?ua-au?aaieaa?uea ioee
align 8
dq 0 ;LFA
dq 0 ;CFA8

f86_list:
