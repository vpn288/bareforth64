
 sti
 tracefind equ 0
  
	mov	r8,[data_stack_base]
	xor	r10, r10
	mov	r9,[data_stack_mask]
	mov	rsp,0x300000
	mov	byte [0xb8010],0x33
	mov	rax,' '
	call	os_print_char

	mov	rax,msgf
	
	mov	[fid],rax
	
	call	_push

	call	_push
	
	call	_type
	

	mov		rax,nfa_0
	call	_push
	call	_count
	call	_type

	call	_cr
	call	_space
_f_system:
	call	_cr
	mov	qword [_in_value],0
	
	call	_timer
	call	_hex_dot
	
	mov	rsi,msgf
	call	 os_output
	call	_cr
	
	call	 _expect
	
	;mov	rax,rcx
	;call	_push
	;call	_hex_dot
	call	_interpret
	;call	_0x
	jmp	_f_system
	
	ret
;----------------------
_break:	
	push	rax
	push	rsi
	call	os_print_newline
	mov		rsi,_break2
	call	os_output
	pop		rsi
	mov		rax,[rsp+8]
	call	os_debug_dump_rax
	pop		rax
	call	os_dump_regs
	push	rax
_break1:
	call	os_input_key
	jnb	_break1
	pop		rax
	ret
_break2	db	"Control point:",0

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
_timer: 
	rdtsc
	shl	rax,32
	shrd	rax,rdx,32
	call	_push
	ret
;---------------------
_type:
	call	_pop
	mov	rcx,rax
	call	_pop
	mov	rsi,rax
	call	os_output
	ret
;--------------------------------	

	
_filen: db	"forth.blk", 0
fid:	dq	0
msgf:	db	"forth>",0 

_hex_dot:
	call	_pop
	mov	[value],rax

	movdqu	xmm0, [value] ;
	pxor	xmm1,xmm1
	punpcklbw	xmm0,xmm1
	movdqa	xmm1,xmm0
	pand	xmm1,[fes]

	psllq	xmm0,4
	pand	xmm0,[fes]
	por	xmm0,xmm1
	movdqa	xmm1,xmm0
	paddb	xmm1,[sixes]
	psrlq	xmm1,4
	pand	xmm1,[fes]
	pxor	xmm9,xmm9
	psubb	xmm9,xmm1
	pand	xmm9,[sevens]
	paddb	xmm0,xmm9
	paddb	xmm0,[zeroes]
	movdqu	[hexstr],xmm0
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
	call    os_output

	call	_space
	ret
;align 8

data_stack_base dq	0x200000
data_stack_mask dq	0x00ffff
value	dq	0abcdefh
		dq	0

zeroes: dq	3030303030303030h
		dq	3030303030303030h

sixes:	dq	0606060606060606h
		dq	0606060606060606h

sevens: dq	0707070707070707h
		dq	0707070707070707h
fes	 	dq	 0x0f0f0f0f0f0f0f0f
		dq	0x0f0f0f0f0f0f0f0f
 
hexstr: times 33  db 0 

;-----------------------
;_emit:


_space:
	mov	rax,' '
	call	_push
	call	_emit
	ret

;------------------------
	

_emit:
	call	_pop
	;mov	[_emit0],al
	;lea	rsi,[r10 + r8] ;_emit0
       ;mov	rcx,1
	;call	_pop
	call    os_output_char
	;call	_pop
	ret

;------------------------
_cr:
	mov	rcx,2
	mov	rsi,_cr_symb
	
	call	os_print_newline
	
	ret
_cr_symb	db 0dh,0ah
;------------------------

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
	add		rax,8
	call	_push
	ret
;-------------------------
_execute_code:
	call	_pop
_execute:
	call  [rax]
	ret
;------------------------
_fetch:
	call _pop
	mov rax,[rax]
	call _push
	ret
;-------------------------
_store:
	call	_pop	; address
	mov		rbx,rax
	call	_pop	;data
	mov		[rbx],rax
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
	mov		rax,context_value
	call	_push
	call	_find_task_frame
	call	_pop
		
	;	call	_dup	
	;	call	_hex_dot	
	call	_execute_code
	jmp	_interpret

_bl:
	ret

;-------------------------
;get string from input buffer parse it and put to top of wordlist
_word:
	mov		rax,[block_value+8]
	mov		[nkey],rax
	mov		rax,[block_value+16]
	call	_push
	mov		rax,[here_value]
	call	_push
	call	_enclose
	ret

;--------------------------------
_enclose:
	call	_pop	;	to address
	mov		rdi,rax
	call	_pop	; from address
	mov		rsi,rax
	
	xor	rdx,rdx
	add	rsi,[_in_value]
	
	;push	rsi
	;mov	rsi,msg6
	;call	os_output
	;pop	rsi
	;push	rsi
	;call	os_output
	;mov	rax,rsi
	;call	_push
	;call	_hex_dot
	;pop	rsi

	;mov	rdi,[here_value]
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
	
	call	_skip_delimeters

_word3:
	
	stosb
	inc	rdx	
	sub	qword [nkey],1	
	jb	_word4
	lodsb
	inc	qword [_in_value]	
	cmp	al,20h
	jnbe	_word3
	

_word4:
	
	; string to validate
	mov	[rbx],dl

	
	;push	rbx
	;
	;call	_push
	;call	_hex_dot
	;pop	rbx
	;mov	rsi,msg2
	;call	os_output
	;mov	rsi,rbx
	;call	os_output
;	mov	r14,0x23456789
;call	_break
	;mov	rax,[rbx]
	;call	_push
	;call	_hex_dot
	;call	_cr
	ret

_word2:
	
	; empty string
	;mov	rsi,msg7
	;call	os_output
	mov	qword [rbx],6 ;dl
	mov	qword [_in_value],0
	;mov	r14,0x12345678
;call	_break
	;mov	rax,[_in_value]
	
	ret

msg2	db	' String prepared to find:',0
msg7	db	' empty string ',0
msg8	db	' push symbol ',0
msg5	db	' skips ',0
msg6	db	' source string ',0
;-------------------------------
;search string from top of wordlist in wordlist
_find_task:
	call	_pop
	test	rax,rax
	je	_find_task2 ; end of task
	inc	rax
	je	_find_task	; empty slot
	dec	rax
	mov	rsi,rax
	call	_sfind2
	call	_pop
	mov	rbx,rax
	call	_pop
	mov	rcx,rax
_find_task3:
	call	_pop
	test	rax,rax
	jne	_find_task3
	mov	rax,rcx
	call	_push
	mov	rax,rbx
	call	_push		
_find_task2:
	ret
	
_find_task_frame:
	call	_pop	;address of context frame
	push	rax
ftf1:
mov	byte [0xb8156],"N"
	pop		rax
	add		rax,8
	mov		rsi,[rax-8]
	;mov	r14,0x456
	;call	_break
	;push	rax
	;push	rsi
	;mov		rax,rsi
	;call	_cr
	;call	_push
	;call	_hex_dot
	;call	_cr
	;pop		rax
	;pop		rsi
	;int 3
	test	rsi,rsi
	je		ftf		; last slot - zero
	inc		rsi
	je		ftf1
	dec		rsi	
	push	rax
mov	byte [0xb8158],"Q"
	call	_sfind2
	call	_pop
	
	test	rax,rax
	je		ftf1		;nothing found

	call	_push
	pop		rax	
	ret
ftf:
;mov	byte [0xb815a],"E"
;mov	r14,'ABCDE'
;call	_break
	call	_push
	pop		rax
	ret

_find:
	mov	rax,[context_value]
	call	_push

_sfind:
	call	_pop
	mov		rsi,rax
	call	_sfind2
	ret

_sfind2:
	;mov	rsi,[context_value]	
	mov	rsi,[rsi]
_find2:
	movzx	rbx,byte [rsi]
	inc	bl
	and	bl,078h
	mov	rdi,[here_value]
	;mov	r14,0x777
	;call	_break
	cmpsq
	;mov	byte [0xb8154],"S"
	je	_find1
	add	rsi,rbx
	mov	rsi,[rsi]

;	 %if tracefind = 1
;			 push	 rdi
;			 push	 rsi
;			 mov	 rax,rsi
; 			 call	 _push
; 			 call	 _hex_dot
; 			 pop	 rsi
; 			 push	 rsi
; 			 call	 os_output
; 			 pop	 rsi
; 			 pop	 rdi
 ;	 %endif
	
	test	rsi,rsi
	jne	_find2
	mov	rax,ret_
	call	_push
	xor	rax,rax
	call	_push
	ret			; nothing to find
	
_find1:
mov	byte [0xb8152],"F"
	add	rsi,rbx
	mov	rax,rsi
	add	rax,8
	call	_push
	xor	rax,rax
	dec	rax
	call	_push		; word found
	ret
;-------------------
_ret:
	pop	rax
	pop	rax
	
	ret
;--------------------
_constant:
	mov	rax,[rax+8]
	call	_push
	ret
;----------------------
_addr_interp:
	add rax,8
	push rax
	mov rax,[rax]
	call qword [rax]
	pop rax
	jmp _addr_interp

;------------------
_0x:
	call	_pop
	mov		rbx,[rax]
	bswap	rbx
	
	mov		rcx,[rax+8]
	bswap	rcx
	mov	[rax+8],rbx
	mov	[rax],rcx
	
	movdqu		xmm0,[rax]
	
	movdqu		xmm2,[fes]
	movdqu		xmm3,[sixes]
	movdqu		xmm4,[zeroes]
	movdqu		xmm7,[bytemask]
	psubb		xmm0,xmm4	; ????? ????
	paddb		xmm0,xmm3	; ???? ?????
	movdqa		xmm5,xmm0	;
	pand		xmm0,xmm2	
	psubb		xmm0,xmm3	;????? ?????
	psrlq		xmm5,4
	pand		xmm5,xmm2	;???????? ?????? ????????
	paddb		xmm0,xmm5
	psllq		xmm5,3
	por			xmm0,xmm5
	movdqa		xmm6,xmm0
	
	pxor		xmm8,xmm8
	
	pand		xmm0,xmm7
	psrlq		xmm6,8
	pand		xmm6,xmm7
	
	packsswb	xmm0,xmm8
	packsswb	xmm6,xmm8
	psllq		xmm6,4
	por			xmm0,xmm6

	movdqu	 [ value],xmm0
	mov		rax,  [ value]
	call	_push
	ret

bytemask	dq	0ff00ff00ff00ffh
			dq	0ff00ff00ff00ffh
;------------------
_skip_delimeters:
	
	;push	rsi
	;mov	rsi,msg5
	;call	[b_output]
	;pop	rsi
	;push	rsi
	;push	rax
	;push	rdi
	;mov		rax,[nkey]
	;call	_push
	;call	_hex_dot
	;pop		rdi
	;pop		rax
	;pop		rsi
	sub	qword [nkey],1
	jb	_word2
	lodsb
	inc	qword [_in_value]
	cmp	al,20h
	jbe	_skip_delimeters
	ret
	
	
;--------------------
_number:
	mov		rax,[block_value+8]
	mov		[nkey],rax
	mov		rsi,[block_value+16]	
	xor	rdx,rdx 
	add	rsi,[_in_value]
	mov	rdi,[here_value]
	mov	rbx,rdi
	; fill 32 bytes with zeroes
	mov	rax,30h
	mov	rcx,32
	rep	stosb
	
	mov	rdi,rbx
	mov	rcx,[nkey]
	cmp	rcx,rdx ; rdx=0
	jl	number2 

	inc	rdi
	
	call	_skip_delimeters
	mov		rdi,[here_value]
	add		rdi,15
	
number3:
	; move to here +15
	stosb
	inc	rdx
	sub	qword [nkey],1	
	jb	number4
	lodsb
	inc	qword [_in_value]	
	cmp	al,20h
	jne	number3

number4:
	;normalize number
	; rdx - count of dihits
	sub		rdi,16
	mov		rax,rdi
	call	_push
	ret

number2:
	
	; empty string
	mov	qword [rbx],6 ;dl
	mov	qword [_in_value],0
	ret
;--------------------------
_nlink: 
	call	_pop
	mov		rsi,rax
	call	nlink2
	mov		rax,rsi
	call	_push
	ret
	
nlink2:
	movzx	rbx,byte [rsi]
	inc	bl
	and	bl,078h
	add	rsi,rbx
	add	rsi,8
	ret
;--------------------------
_name:
	call	_pop
	call	nlink2
	;add		rsi,8
	mov		rax,rsi
	call	_push
	ret
;--------------------------

_create:
	call	_word
	mov	rsi,[here_value]
	call	nlink2		;rsi - address of lf
	call	latest_code2	;rax - latest
	mov	[rsi],rax	;fill link field	
	add	rsi,8
	mov	qword [rsi],_variable_code
	mov	rbx,[here_value]
	mov	rax,[current_value]
	mov	[rax],rbx	; here to latest
	add	rsi,8
	mov	[here_value],rsi
	ret
;--------------------------------
_header:
	call	_word
	mov	rsi,[here_value]
	call	nlink2		;rsi - address of lf
	call	latest_code2	;rax - latest
	mov	[rsi],rax	;fill link field
	mov	rbx,[here_value]
	mov	rax,[current_value]
	mov	[rax],rbx	; here to latest
	add	rsi,8
	mov	[here_value],rsi
	ret
;--------------------------------
_vocabulary:
	add		rax,8
	;mov		[context_value],rax ;[current_value],rax;
	call	_push
	;call	_hex_dot
	ret
	
;--------------------------------
_latest:
	call	latest_code2
	call	_push
	ret

latest_code2:
	mov	rax,[current_value]
	mov	rax,[rax] ; rax = latest nfa of curent vocabulary
	ret
;--------------------------------
_comma:
	mov	rbx,[here_value]
	call	_pop	
	mov	[rbx],rax
	add	qword [here_value],8
	ret
;--------------------------------
_vocabulary_create:
	call	_header
	mov	rsi,[here_value]
	mov		rax,rsi
	
	mov	qword [rsi],_vocabulary
	add	rsi,16
	mov	[rsi-8],rsi	;link to empty word, which is last in this list
	;add	rsi,8
	; set zero word 
	mov	qword [rsi],6
	add	rsi,8
	xor	rax,rax
	mov	[rsi],rax
	
	add	rsi,8
	mov	qword [rsi],_ret
	add	rsi,8
	mov	[here_value],rsi
		
	mov		rax,rsi
	call	_push
	call	_hex_dot
	ret
;--------------------------------
_cellp:
	add	qword [r10 + r8],8
	ret
;--------------------------------
_cellm:
	sub	qword [r10 + r8],8
	ret
;--------------------------------

_dump:
	call	_pop
	mov		rdx,rax
	mov		rcx,16
_dump2:
	push	rcx
	mov		rax,[rdx]
	call	_push
	call	_hex_dot
	call	_space
	add		rdx,8
	pop		rcx
	loop	_dump2
	ret
;--------------------------------
_rdblock:
	call	_pop	; block number
	mov		rcx,rax
	inc		rcx
	shl		rcx,13
	call	_pop	; buffer
	mov		rdi,rax
	mov		rax,[fid]
	;call	 [b_file_read]
	
	ret
;--------------------------------
_allot:
	call	_pop
	add		[here_value],rax
	ret
;--------------------------------
_expect:
	mov	rdi,tibb
	mov	rcx,[tibb-8]
	call	 os_input
	mov		qword [nkey],rcx
	
	ret
;--------------------------------
align 32
db 0cch

test4:	db	'1234567890ABCDEF'
rkey:	 times 64  db	  0
nkey	dq	0
align 16 


nfa_0:
	db 7, "FORTH64" ; neiaa?u aey neia ?aaeuiiai, ae?ooaeuiiai 86
	db 0 ; oa?ieie?o?ua-au?aaieaa?uea ioee
	align 8, db 0
	dq  0 ;LFA
	dq _vocabulary ;CFA
 f64_list:
	dq nfa_last ;PFA - oeacaoaeu ia eoa iineaaiaai ii?aaaeaiiiai neiaa
nfa_0.5:
	db	6,0,0
	align 8, db 0
	dq	nfa_0
ret_:
	dq	_ret

nfa_1:
	db	4,"HEX." ,0
	align 8, db 0
	dq	nfa_0.5 
	dq	_hex_dot
	dq	0
nfa_2:
	db	4,"EMIT",0
	align 8, db 0
	dq	nfa_1
	dq	_emit
	dq	0
nfa_3:
	db	2,"CR",0
	align 8, db 0
	dq	nfa_2
	dq	_cr
	dq	0
nfa_4:
	db	4,"TYPE",0
	align 8, db 0
	dq	nfa_3
type_:
	dq	_type
	dq	0
nfa_5:
	db	5,"COUNT",0
	align 8, db 0
	dq	nfa_4
count_:
	dq	_count
	dq	0
nfa_6:
	db	5,"SPACE",0
	align 8, db 0
	dq	nfa_5
	dq	_space
	dq	0
nfa_7:
	db	1,"@",0
	align 8, db 0
	dq	nfa_6
fetch_:
	dq	_fetch
	dq	0	

nfa_8:
	db	7,"CONTEXT",0
	align 8, db 0
	dq	nfa_7
	dq	_variable_code
context_value:	
	dq	f64_list
	dq	0
	dq	-1
	dq	-1
	dq	-1
	dq	-1
	dq	-1
	dq	0
	
	
nfa_9:	
	db	3,">IN",0
	align 8, db 0
	dq	nfa_8
	dq	_variable_code
_in_value:
	dq	0

nfa_10: 
	db	3,"DUP",0
	align 8, db 0
	dq	nfa_9
	dq	_addr_interp
	dq	pop_
	dq	push_
	dq	push_
	dq	ret_

nfa_11: 
	db	3,"pop",0
	align 8, db 0
	dq	nfa_10
pop_:
	dq	_pop
	dq	0

nfa_12:
	db	4,"push",0
	align 8, db 0
	dq	nfa_11
push_:
	dq	_push
	dq	0

nfa_13:
	db	4,"(0x)",0
	align 8, db 0
	dq	nfa_12
_0x_:
	dq	_0x
	dq	0

nfa_14:
	db	4,"HERE",0
	align 8, db 0
	dq	nfa_13
	dq	_constant
here_value:
	dq	_here

nfa_15:
	db	2,"0x",0
	align 8, db 0
	dq	nfa_14
	dq	_addr_interp
	dq	number_
	dq	_0x_
	dq	ret_
	
nfa_16:

	db	12,"parse_number",0
	align 8, db 0
	dq	nfa_15
number_:
	dq	_number
	dq	0

nfa_17:
	db	7,"CURRENT",0
	align 8, db 0
	dq	nfa_16
current_:
	dq	_variable_code
current_value:
	dq	f64_list
	
nfa_18:
	db	6,"CREATE",0
	align 8, db 0
	dq	nfa_17
	dq	_create
	dq	0
	
nfa_19: 
	db	6,"N>LINK",0
	align 8, db 0
	dq	nfa_18
nlink_:
	dq	_nlink
	dq	0
	
nfa_20:
	db	6,"LATEST",0
	align 8, db 0
	dq	nfa_19
latest_:
	dq	_latest
	dq	0
	
	;dq	_addr_interp
	;dq	current_
	;dq	fetch_
	;dq	fetch_
	;dq	ret_
	
nfa_21:
	db	7,"_CREATE",0
	align 8, db 0
	dq	nfa_20
create_:
	dq	_addr_interp
	dq	header_
	dq	variableb_
	dq	comma_
	dq	ret_
	
nfa_22: 
	db	5,"BLOCK",0
	align 8, db 0
	dq	nfa_21
block_:
	dq	_variable_code
block_value:
	dq	0		;block number
	dq	64		;size of buffer
	dq	tibb	;address of input buffer

nfa_23:
	db	4,"prev",0
	align 8, db 0
	dq	nfa_22
	dq	_addr_interp
	dq	latest_
	dq	nlink_
	dq	fetch_
	dq	count_
	dq	type_
	dq	ret_
	
nfa_24:
	db	1,",",0
	align 8, db 0
	dq	nfa_23
comma_:
	dq	_comma
	dq	0

nfa_25:
	db	1,"'",0
	align 8, db 0
	dq	nfa_24
	dq	_addr_interp
	dq	word_
	dq	find_
	dq	pop_
	dq	ret_
	
nfa_26:
	db	4,"WORD",0
	align 8, db 0
	dq	nfa_25
word_:
	dq	_word
	dq	0

nfa_27:
	db	4,"FIND",0
	align 8, db 0
	dq	nfa_26
find_:
	dq	_find
	dq	0

nfa_28:
	db	7,"EXECUTE",0
	align 8, db 0
	dq	nfa_27
	dq	_execute_code
	dq	0

nfa_29:
	db	10,"interpret#",0
	align 8, db 0
	dq	nfa_28
	dq	_constant
	dq	_addr_interp
	
nfa_30:
	db	9,"constant#",0
	align 8, db 0
	dq	nfa_29
constantb_:
	dq	_constant
	dq	_constant
	
nfa_31:
	db	5,"NAME>",0
	align 8, db 0
	dq	nfa_30
	dq	_name
	dq	0
	
nfa_32: 
	db	1,"!",0
	align 8, db 0
	dq	nfa_31
	dq	_store
	dq	0

nfa_33:
	db	6,"HEADER",0
	align 8, db 0
	dq	nfa_32
header_:
	dq	_header
	dq	0
	

nfa_34:
	db	4,"ret#",0
	align 8, db 0
	dq	nfa_33
	dq	_constant
	dq	ret_
	

nfa_35:
	db	9,"variable#",0
	align 8, db 0
	dq	nfa_34
variableb_:
	dq	_constant
	dq	_variable_code

nfa_36:
	db	8,"VARIABLE",0
	align 8, db 0
	dq	nfa_35
	dq	_addr_interp
	dq	create_
	dq	zero_
	dq	comma_
	dq	ret_

nfa_37:
	db	1,"0",0
	align 8, db 0
	dq	nfa_36
zero_:
	dq	_constant
	dq	0
	
nfa_38:
	db 8,"CONSTANT",0
	align 8, db 0
	dq	nfa_37
	dq	_addr_interp
	dq	header_
	dq	constantb_
	dq	comma_
	dq	comma_
	dq	ret_
	
nfa_39:
	db	10,"VOCABULARY",0
	align 8, db 0
	dq	nfa_38
	dq	_vocabulary_create
	dq	0
	
nfa_40:
	db	6,"TIMER@",0
	align 8, db 0
	dq	nfa_39
timer_:
	dq	_timer
	dq	0

nfa_41:
	db	5,"CELL+",0
	align 8, db 0
	dq	nfa_40
cellp_:
	dq	_cellp
	dq	0

nfa_42:
	db	4,"DUMP",0
	align 8, db 0
	dq	nfa_41
dump_:
	dq	_dump
	dq	0

nfa_43:
	db	6,"(FIND)",0
	align 8, db 0
	dq	nfa_42
	dq	_sfind
	dq	0
	
nfa_44:
	db	5,"CELL-",0
	align 8, db 0
	dq	nfa_43
	dq	_cellm	
	dq	0
	
nfa_45:
	db	7,"rdblock",0
	align 8, db 0
	dq	nfa_44
	dq	_rdblock
	dq	0
	
nfa_46:
	db	5,"ALLOT",0
	align 8, db 0
	dq	nfa_45
	dq	_allot
	dq	0
nfa_last:
nfa_47:
	db	3,"TIB",0
	align 8, db 0
	dq	nfa_46
	dq	_variable_code
	dq	63	;tibsize
tibb:
	times	64	 db	 20h 
	dq	0606060606060606h
_here:

	db	6,0,0
	
	dq	nfa_34


	times 1121  db 0xaa 
