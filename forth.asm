[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.asm"

  start:
	mov	r8,[data_stack_base]
	xor	r10, r10
	mov	r9,[data_stack_mask]
	
	call	_cr
	mov	rax,nfa_0
	call	_push
	call	_count
	call	_type	
	call	_cr
	call	_space
	mov	rdi, rkey
	mov	rcx,64
	
	call	[b_input]
	mov	[nkey],rcx
	;mov	rax,[rkey]
	mov	rax,rcx
	call	_push
	call	_hex_dot

	call	_interpret
	
	mov	rax,[f64_list]
	mov	rax,[rax]
	;mov     rax,3A34567890abcdefh
	call	_push
	call	_hex_dot
	mov	rax,rcx
	call	_push
	call	_hex_dot
	ret	

data_stack_base	dq	0x300000
data_stack_mask	dq	0x0fffff

value:		dq	1234567890abcdefh
val128:			
digitslow	dq	0
val129:
digitshigh	dq	0	
		db	20h,0	

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

_hex_dot:
	call	_pop
        mov     rbx,rax
      
	mov	rdx,0f0f0f0f0f0f0f0fh
	
	shr	rbx,4
        and     rax,rdx	
        and     rbx,rdx
      
        mov	r13, 0606060606060606h
	mov	r11,0d0d0d0d0d0d0d0dh

	mov	rdx,rax
	add	rdx,r13
	
	
	mov	r10,0f0f0f0f0f0f0f0f0h
	mov	r12,007070707070707070h
	and	rdx,r10
	shr	rdx,2
	mov	r12,rdx
	shr	r12,1
	or	rdx,r12
	shr	r12,1
	or	rdx,r12
	add	rax,rdx
	
	mov	rdx,rbx
	add	rdx,r13
	and	rdx,r10
	shr	rdx,2
	mov	r12,rdx
	shr	r12,1
	or	rdx,r12
	shr	r12,1
	or	rdx,r12
	add	rbx,rdx

	mov	rdx,3030303030303030h 
	add	rax,rdx
	add	rbx,rdx
	bswap	rax
	bswap	rbx
	mov	[digitslow],rax
	mov	[digitshigh],rbx
	movdqu	xmm0,[val128]
	movdqu	xmm1,[val129]
	punpcklbw	xmm1,xmm0
	movdqu	[val128],xmm1

	call	_space
	mov	rsi,val128
	mov	rcx,16
	call	[b_output_chars]
	call	_space
	ret

;-----------------------

_space:
	mov	rax,' '
	call	_push
	call	_emit
	ret

;------------------------
_emit:
	;call	_pop
	;mov	[_emit0],al
	lea	rsi,[r10 + r8] ;_emit0
	mov	rcx,1
	call	[b_output_chars]
	ret
;------------------------
_cr:
	mov	rcx,2
	mov	rsi,_cr_symb
	call	[b_output_chars]
	ret
_cr_symb	db 0dh,0ah
;------------------------
_type:
	call	_pop
	mov	rcx,rax
	call	_pop
	mov	rsi,rax
	call	[b_output_chars]
	ret
;-------------------------
_count:
	call	_pop
	mov	rbx,rax	
	mov	rbx,[rax]
	and	rbx,03fh
	inc	rax
	
	call	_push
	mov	rax,rbx
	
	call	_push
	ret
;-------------------------
_variable_code:
	add	rax,4
	call 	_push
	ret
;-------------------------
execute_code:
	call 	_pop
_execute:
	call qword [rax]
	ret
;------------------------
_fetch:
	call _pop
	mov rax,[rax]
	call _push
	ret
;-------------------------
_interpret:
	call	_bl
	call	_word
	call	_find
	;call	_execute
	ret

_bl:
	ret

;-------------------------
;get string from input buffer parse it and put to top of wordlist

_word:
	mov	rsi,rkey
	mov	rdi,[f64_list]
	mov	rbx,rdi
	mov	rcx,[nkey]
	xor	rdx,rdx
	inc	rdi
_word1:
	lodsb
	cmp	al,20h
	je	_word1
	stosb
	inc	rdx
	dec	rcx
	je	_word2
_word3:
	lodsb
	cmp	al,20h
	je	_word2
	stosb
	inc	rdx
	dec	rcx
	jne	_word3
	
_word2:
	
	mov	[rdi],byte 0
	mov	[rbx],dl
	ret
;-------------------------------
;search string from top of wordlist in wordlist

_find:

	ret

msg:	db	' msgmsg', 0 
align 32 , db 0cch

rkey	times 64 db	0 
nkey	dq	0
align 16 , db 0aah
  nfa_0:
	db 7, "FORTH64" ; neiaa?u aey neia ?aaeuiiai, ae?ooaeuiiai 86
	db 0 ; oa?ieie?o?ua-au?aaieaa?uea ioee
	align 8 , db 0
	dq 0 ;LFA
	dq 0 ;CFA
 f64_list:
	dq nfa_a ;PFA - oeacaoaeu ia eoa iineaaiaai ii?aaaeaiiiai neiaa
	dq 0 ; nnueea ia i?

nfa_1:
	db	4,"HEX." ,0
	align	8 , db 0
	dq	nfa_0 
	dq	_hex_dot
	dq	0
nfa_2:
	db	4,"EMIT",0
	align	8 , db 0
	dq	nfa_1
	dq	_emit
	dq	0
nfa_3:
	db	2,"CR",0
	align	8, db 0
	dq	nfa_2
	dq	_cr
	dq	0
nfa_4:
	db	4,"TYPE",0
	align	8, db 0
	dq	nfa_3
	dq	_type
	dq	0
nfa_5:
	db	5,"COUNT",0
	align	8, db 0
	dq	nfa_4
	dq	_count
	dq	0
nfa_6:
	db	5,"SPACE",0
	align	8, db 0
	dq	nfa_5
	dq	_space
	dq	0
nfa_7:
	db	1,"@",0
	align	8, db 0
	dq	nfa_6
	dq	_fetch
	dq	0	
nfa_a:
