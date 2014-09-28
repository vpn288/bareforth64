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
_f_system:
	call	_cr
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
_f_system:
	call	_cr
	mov	qword [_in_value],0
	rdtsc
	shl	rax,32
	shrd	rax,rdx,32
	call	_push
	call	_hex_dot
	mov	rsi,msgf
	
	call	[b_output]
	;call	_cr

	mov	rdi, rkey
	mov	rcx,64
	
	call	[b_input]
	mov	[nkey],rcx
	;mov	rax,rcx
	;call	_push
	;call	_hex_dot
	call	_interpret
	
	jmp	_f_system
	
	ret	

msgf	db	'forth>',0 
data_stack_base	dq	0x300000
data_stack_mask	dq	0x0fffff

;------------------------------
  _pop:
        mov rax , [ r10 + r8 ]
        sub r10 , 8
	and r10 , r9
	ret
;------------------------------	    
  _push:
        add r10 , 8
        and r10 , r9
        mov [ r10 + r8 ] , rax
        ret
;--------------------------------
_hex_dot:
	call	_pop
        mov     [value],rax
      
	movdqu	xmm0,[value]
	pxor	xmm1,xmm1
	punpcklbw	xmm0,xmm1
	movdqa	xmm1,xmm0
	pand	xmm1,[efes]
	psllq	xmm0,4
	pand	xmm0,[efes]
	por	xmm0,xmm1
	movdqa	xmm1,xmm0
	paddb	xmm1,[sixes]
	psrlq	xmm1,4
	pand	xmm1,[efes]
	pxor	xmm9,xmm9
	psubb	xmm9,xmm1
	pand	xmm9,[sevens]
	paddb	xmm0,xmm9
	paddb	xmm0,[zeroes]
	movdqu	[hexstr],xmm0
	mov	rax,[hexstr]
	mov	rbx,[hexstr+8]
	bswap	rax
	bswap	rbx
	mov	[hexstr],rbx
	mov	[hexstr+8],rax

	call	_space
	mov	rsi,hexstr
	mov	rcx,16
	call	[b_output_chars]
	call	_space
	ret

value	dq	0
	dq	0
hexstr times 16 db 0

efes:	dq	0f0f0f0f0f0f0f0fh
	dq	0f0f0f0f0f0f0f0fh
zeroes:	dq	3030303030303030h
	dq	3030303030303030h
sixes:	dq	0606060606060606h
	dq	0606060606060606h
sevens:	dq	0707070707070707h
	dq	0707070707070707h

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
	call	_pop
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
	add	rax,8
	call 	_push
	ret
;-------------------------
_execute_code:
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
_dup:
	call	_pop
	call	_push
	call	_push
	ret
;-------------------------
_interpret:
	;call	_bl
	call	_word
	call	_find
	call	_pop
	;call	_hex_dot
	;call	_dup	
	;call	_hex_dot	
	call	_execute_code
	jmp	_interpret

_bl:
	ret

;-------------------------
;get string from input buffer parse it and put to top of wordlist

_word:
	
	
	xor	rdx,rdx
	mov	rsi,rkey
	add	rsi,[_in_value]
	
	;push	rsi
	;mov	rsi,msg6
	;call	[b_output]
	;pop	rsi
	;push	rsi
	;call	[b_output]
	;mov	rax,rsi
	;call	_push
	;call	_hex_dot
	;pop	rsi

	mov	rdi,_here
	mov	rbx,rdi
	; clear 32 bytes
	xor	rax,rax
	mov	rcx,4
	rep	stosq
	mov	rdi,rbx
	mov	rcx,[nkey]
	cmp	rcx,rdx
	jl	_word2	

	inc	rdi
	
_word1:
	; skip delimeters
	;push	rsi
	;mov	rsi,msg5
	;call	[b_output]
	;pop	rsi
	
	sub	qword [nkey],1
	jb	_word2
	lodsb
	inc	qword [_in_value]
	cmp	al,20h
	je	_word1

_word3:
	
	stosb
	inc	rdx

	;push	rsi
	;mov	rsi,msg4
	;call	[b_output]
	;mov	rax,[nkey]
	;;push	rbx
	;call	_push
	;call	_hex_dot
	;pop	rbx
	;pop	rsi

	sub	qword [nkey],1
	
	jb	_word4
	lodsb
	inc	qword [_in_value]	
	cmp	al,20h
	jne	_word3
	

_word4:
	;dec	rsi
	;mov	r11,rsi
	; string to validate
	mov	[rbx],dl
	;sub	rsi,rkey
	;mov	r11,rsi
	;add	[_in_value],rsi
	;dec	qword [_in_value]
	;mov	rax,r11
	
	;push	rbx
	;call	_push
	;call	_hex_dot
	;pop	rbx
	;mov	rsi,msg2
	;call	[b_output]
	;mov	rsi,rbx
	;call	[b_output]
	;mov	rax,[rbx]
	;call	_push
	;call	_hex_dot
	;call	_cr
	ret

_word2:
	
	; empty string
	;mov	rsi,msg3
	;call	[b_output]
	mov	qword [rbx],6 ;dl
	mov	qword [_in_value],0
	;mov	rax,[_in_value]
	
	ret

msg2	db	' String prepared to find:',0
msg3	db	' empty string ',0
msg4	db	' push symbol ',0
msg5	db	' skips ',0
msg6	db	' source string ',0
;-------------------------------
;search string from top of wordlist in wordlist

_find:
	mov	rsi,nfa_last ;[f64_list]
_find2:
	movzx	rbx,byte [rsi]
	inc	bl
	and	bl,0f8h
	mov	rdi,_here
	cmpsq
	
	je	_find1
	add	rsi,rbx
	mov	rsi,[rsi]
	;push	rdi
	;push	rsi
	;mov	rax,rsi
	;;call	_push
	;call	_hex_dot
	;pop	rsi
	
	;push	rsi
	;call	[b_output]
	;pop	rsi
	
	;pop	rdi
	
	test	rsi,rsi
	jne	_find2
	;mov	rax,_here
	mov	rax,ret_
	call	_push
	xor	rax,rax
	call	_push
	ret
	
_find1:
	add	rsi,rbx
	mov	rax,rsi
	add	rax,8
	call	_push
	xor	rax,rax
	dec	rax
	call	_push
	ret
;-------------------
_ret:
	pop	rax
	pop	rax
	
	ret
;--------------------
_constant:
 	mov 	rax,[rax+8]
	call 	_push
	ret
;----------------------
_addr_interp:
	add rax,8
	push rax
	mov rax,[rax]
	call qword [rax]
	pop rax
	jmp _addr_interp

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
	dq nfa_last ;PFA - oeacaoaeu ia eoa iineaaiaai ii?aaaeaiiiai neiaa
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

nfa_8:
	db	7,"CONTEXT",0
	align	8, db 0
	dq	nfa_7
	dq	_variable_code
	dq	f64_list

nfa_9:	
	db	3,">IN",0
	align	8, db 0
	dq	nfa_8
	dq	_variable_code
_in_value:
	dq	0

nfa_10:	
	db	3,"DUP",0
	align	8, db 0
	dq	nfa_9
	dq	_addr_interp
	dq	pop_
	dq	push_
	dq	push_
	dq	ret_

nfa_11:	
	db	3,"pop",0
	align	8, db 0
	dq	nfa_10
pop_:
	dq	_pop
	dq	0

nfa_12:
	db	4,"push",0
	align	8, db	0
	dq	nfa_11
push_:
	dq	_push
	dq	0

nfa_13:
	db	3,"pet",0
	align	8, db	0
	dq	nfa_12

	dq	_constant
	dq	0200480h
	
nfa_last:
	db	6,0,0
	align	8, db 0
	dq	nfa_13
ret_:
	dq	_ret
	dq	0
_here:
	mov	qword [_in_value],0
	rdtsc
	shl	rax,32
	shrd	rax,rdx,32
	call	_push
	call	_hex_dot
	mov	rsi,msgf
	
	call	[b_output]
	;call	_cr

	mov	rdi, rkey
	mov	rcx,64
	
	call	[b_input]
	mov	[nkey],rcx
	;mov	rax,rcx
	;call	_push
	;call	_hex_dot
	call	_interpret
	
	jmp	_f_system
	
	ret	

msgf	db	'forth>',0 
data_stack_base	dq	0x300000
data_stack_mask	dq	0x0fffff

;------------------------------
  _pop:
        mov rax , [ r10 + r8 ]
        sub r10 , 8
	and r10 , r9
	ret
;------------------------------	    
  _push:
        add r10 , 8
        and r10 , r9
        mov [ r10 + r8 ] , rax
        ret
;--------------------------------
_hex_dot:
	call	_pop
        mov     [value],rax
      
	movdqu	xmm0,[value]
	pxor	xmm1,xmm1
	punpcklbw	xmm0,xmm1
	movdqa	xmm1,xmm0
	pand	xmm1,[efes]
	psllq	xmm0,4
	pand	xmm0,[efes]
	por	xmm0,xmm1
	movdqa	xmm1,xmm0
	paddb	xmm1,[sixes]
	psrlq	xmm1,4
	pand	xmm1,[efes]
	pxor	xmm9,xmm9
	psubb	xmm9,xmm1
	pand	xmm9,[sevens]
	paddb	xmm0,xmm9
	paddb	xmm0,[zeroes]
	movdqu	[hexstr],xmm0
	mov	rax,[hexstr]
	mov	rbx,[hexstr+8]
	bswap	rax
	bswap	rbx
	mov	[hexstr],rbx
	mov	[hexstr+8],rax

	call	_space
	mov	rsi,hexstr
	mov	rcx,16
	call	[b_output_chars]
	call	_space
	ret

value	dq	0
	dq	0
hexstr times 16 db 0

efes:	dq	0f0f0f0f0f0f0f0fh
	dq	0f0f0f0f0f0f0f0fh
zeroes:	dq	3030303030303030h
	dq	3030303030303030h
sixes:	dq	0606060606060606h
	dq	0606060606060606h
sevens:	dq	0707070707070707h
	dq	0707070707070707h

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
	call	_pop
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
	add	rax,8
	call 	_push
	ret
;-------------------------
_execute_code:
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
_dup:
	call	_pop
	call	_push
	call	_push
	ret
;-------------------------
_interpret:
	;call	_bl
	call	_word
	call	_find
	call	_pop
	;call	_hex_dot
	;call	_dup	
	;call	_hex_dot	
	call	_execute_code
	jmp	_interpret

_bl:
	ret

;-------------------------
;get string from input buffer parse it and put to top of wordlist

_word:
	
	
	xor	rdx,rdx
	mov	rsi,rkey
	add	rsi,[_in_value]
	
	;push	rsi
	;mov	rsi,msg6
	;call	[b_output]
	;pop	rsi
	;push	rsi
	;call	[b_output]
	;mov	rax,rsi
	;call	_push
	;call	_hex_dot
	;pop	rsi

	mov	rdi,_here
	mov	rbx,rdi
	; clear 32 bytes
	xor	rax,rax
	mov	rcx,4
	rep	stosq
	mov	rdi,rbx
	mov	rcx,[nkey]
	cmp	rcx,rdx
	jl	_word2	

	inc	rdi
	
_word1:
	; skip delimeters
	;push	rsi
	;mov	rsi,msg5
	;call	[b_output]
	;pop	rsi
	
	sub	qword [nkey],1
	jb	_word2
	lodsb
	inc	qword [_in_value]
	cmp	al,20h
	je	_word1

_word3:
	
	stosb
	inc	rdx

	;push	rsi
	;mov	rsi,msg4
	;call	[b_output]
	;mov	rax,[nkey]
	;;push	rbx
	;call	_push
	;call	_hex_dot
	;pop	rbx
	;pop	rsi

	sub	qword [nkey],1
	
	jb	_word4
	lodsb
	inc	qword [_in_value]	
	cmp	al,20h
	jne	_word3
	

_word4:
	;dec	rsi
	;mov	r11,rsi
	; string to validate
	mov	[rbx],dl
	;sub	rsi,rkey
	;mov	r11,rsi
	;add	[_in_value],rsi
	;dec	qword [_in_value]
	;mov	rax,r11
	
	;push	rbx
	;call	_push
	;call	_hex_dot
	;pop	rbx
	;mov	rsi,msg2
	;call	[b_output]
	;mov	rsi,rbx
	;call	[b_output]
	;mov	rax,[rbx]
	;call	_push
	;call	_hex_dot
	;call	_cr
	ret

_word2:
	
	; empty string
	;mov	rsi,msg3
	;call	[b_output]
	mov	qword [rbx],6 ;dl
	mov	qword [_in_value],0
	;mov	rax,[_in_value]
	
	ret

msg2	db	' String prepared to find:',0
msg3	db	' empty string ',0
msg4	db	' push symbol ',0
msg5	db	' skips ',0
msg6	db	' source string ',0
;-------------------------------
;search string from top of wordlist in wordlist

_find:
	mov	rsi,nfa_last ;[f64_list]
_find2:
	movzx	rbx,byte [rsi]
	inc	bl
	and	bl,0f8h
	mov	rdi,_here
	cmpsq
	
	je	_find1
	add	rsi,rbx
	mov	rsi,[rsi]
	;push	rdi
	;push	rsi
	;mov	rax,rsi
	;;call	_push
	;call	_hex_dot
	;pop	rsi
	
	;push	rsi
	;call	[b_output]
	;pop	rsi
	
	;pop	rdi
	
	test	rsi,rsi
	jne	_find2
	;mov	rax,_here
	mov	rax,ret
	call	_push
	xor	rax,rax
	call	_push
	ret
	
_find1:
	add	rsi,rbx
	mov	rax,rsi
	add	rax,8
	call	_push
	xor	rax,rax
	dec	rax
	call	_push
	ret
;-------------------
_ret:
	pop	rax
	pop	rax
	
	ret
;--------------------
_constant:
 	mov 	rax,[rax+8]
	call 	_push
	ret


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
	dq nfa_last ;PFA - oeacaoaeu ia eoa iineaaiaai ii?aaaeaiiiai neiaa
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

nfa_8:
	db	7,"CONTEXT",0
	align	8, db 0
	dq	nfa_7
	dq	_variable_code
	dq	f64_list

nfa_9:	
	db	3,">IN",0
	align	8, db 0
	dq	nfa_8
	dq	_variable_code
_in_value:
	dq	0

nfa_10:	
	db	3,"DUP",0
	align	8, db 0
	dq	nfa_9
	dq	_dup
	dq	0
nfa_11:	
	db	2,"dq",0
	align	8, db 0
	dq	nfa_10
	dq	_constant
	dq	200500h	
nfa_last:
	db	6,0,0
	align	8, db 0
	dq	nfa_11
ret:
	dq	_ret
	dq	0
_here:
