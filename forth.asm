[BITS 64]
[ORG 0x0000000000200000]
%INCLUDE "bmdev.asm"
start:	
	mov	r8,[data_stack_base]
	xor	r10, r10
	mov	r9,[data_stack_mask]

	mov	rax,nfa_0
	call	_push
	call	_count
	call	_type
	mov	rax,0x123456789abcdef0
	call	rax_to_hex
	mov	[numbr],rbx
	mov	[numbr+8],rdx
	mov	rsi,numbr
	mov	rcx,16
	call	b_output
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

low_nibble_of_al_to_hex:
	; bl - result
	and	al,0x0f
	add	al,0x30
	mov	bl,al
	ret
	
rax_to_hex:
	;result in rdx,rbx
	mov	rcx,16
	rol	rax,4
	rth:
	push	rax
	shld	rdx,rbx,8
	call	low_nibble_of_al_to_hex
	pop	rax
	rol	rax,4
	loop	rth
	ret

;-----------------------
data_stack_base	dq	0x300000
data_stack_mask	dq	0x0fffff

numbr	dq	0,0
	db	0
nfa_0:
db 7, "FORTH64" ;
db 0 ; oa?ieie?o?ua-au?aaieaa?uea ioee
align 8
dq 0 ;LFA
dq 0 ;CFA8

f86_list:
