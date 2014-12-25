
 sti
 tracefind equ 0
 %define neworg		200000h
 %include "f/fstart.asm"
 %include "f/atoitoa.asm"
 %include "f/io.asm"
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


	
_filen: db	"forth.blk", 0
fid:	dq	0
msgf:	db	"forth>",0 


	

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
;mov		r14,[rax]
;call	_break
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
	;call	_pop
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
	;mov		rax,[block_value+8]
	;mov		[block_value+8] ; [nkey],rax
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
	mov	rbx,rdi
	; clear 32 bytes
	xor	rax,rax
	mov	rcx,4
	rep	stosq
	
	mov	rdi,rbx
	mov	rcx,[block_value+8] ; [nkey]
;mov	r14,0x1
;mov	r13,[rsi]
;call	_break
	cmp	rcx,rdx
	jl	_word2	;jl

	inc	rdi
	
_skip_delimeters:
	
	sub	qword [block_value+8],1 ; [nkey],1
	jb	_word2
	lodsb
	inc	qword [_in_value]
	cmp	al,20h
	jbe	_skip_delimeters
			
	;call	_skip_delimeters

_word3:
	
	stosb
	inc	rdx	
	sub	qword [block_value+8],1 ; [nkey],1	
	jb	_word4
	lodsb
	inc	qword [_in_value]	
	cmp	al,20h
	jnbe	_word3
	

_word4:
	
	; string to validate
	mov	[rbx],dl
;or	r14,0x7800
	ret

_word2:
	
	; empty string
	;mov	rsi,msg7
	;call	os_output
	mov	qword [rbx],6 ;dl
	mov	qword [_in_value],0
;mov		r13,[rbx]
;mov		r14,0x67
;call	_break
	
	;mov	rax,[_in_value]
	
	ret
;------------------

	


;msg2	db	' String prepared to find:',0
msg7	db	' empty string ',0
;msg8	db	' push symbol ',0
;msg5	db	' skips ',0
;msg6	db	' source string ',0
;-------------------------------
;search string from here in wordlist
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
;----------------------------	
_find_task_frame:
	call	_pop	;address of context frame
	push	rax
ftf1:
	pop		rax
	add		rax,8 ;
	mov		rsi,[rax-8]
	test	rsi,rsi
	je		ftf		; last slot - zero
	inc		rsi
	je		ftf1
	dec		rsi	
	push	rax
mov	byte [0xb8158],"Q"
	call	_sfind2
	call	_pop ; flag. on stack rest xt
	
	test	rax,rax
	je		ftf1		;nothing found in this context

;	call	_push		;somefind found 
	pop		rax	
	ret
ftf:
	;
	;mov		rax,badword_ ;cr_;_ret
	;call	_push
	;pop		rax
;	xor		rax,rax
;	call	_push
;	call	_break
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
	mov	rsi,[rsi]
;push	rsi
;mov		rsi,rdi
;call	os_output
;pop		rsi
_find2:
	movzx	rbx,byte [rsi]
	inc	bl
	and	bl,078h
	mov	rdi,[here_value]
	
;push	rsi
;mov		r12,[rdi]
;mov		r11,[rsi]
;rol		r14,1
;call	_break
;pop		rsi
	cmpsq
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
	mov	rax,badword_ ;cr_;ret_
;call	_break
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

_number:
	;mov		rax,[block_value+8]
	;mov		[block_value+8],rax ; [nkey],rax
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
	mov	rcx,[block_value+8] ; [nkey]
	cmp	rcx,rdx ; rdx=0
;mov	r13,[rsi]
;call	_break
	jl	number2 

	inc	rdi
_skip_delimeters2:
	
	sub	qword [block_value+8],1 ; [nkey],1
	je	number2
	lodsb
	inc	qword [_in_value]
	cmp	al,20h
	jbe	_skip_delimeters2
			
	;call	_skip_delimeters
	mov		rdi,[here_value]
	add		rdi,15
	
number3:
	; move to here +15
	stosb
	inc	rdx
	sub	qword [block_value+8],1 ; [nkey],1	
	jb	number4
	lodsb
	inc	qword [_in_value]	
	cmp	al,20h
	jne	number3

number4:
	;normalize number
	; rdx - count of digits
	sub		rdi,16
;mov	r14,[rdi+8]
;call	_break
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
	call	_push
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
	; set zero word 
	mov	qword [rsi],6
	add	rsi,8
	xor	rax,rax
	mov	[rsi],rax
	
	add	rsi,8
	mov	qword [rsi],_ret
	add	rsi,8
	mov	[here_value],rsi
		
	;mov		rax,rsi
	;call	_push
	;call	_hex_dot
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

;--------------------------------

_allot:
	call	_pop
	add		[here_value],rax
	ret
;--------------------------------
_vect:
	mov	rax,[rax+8]
	call	[rax]
	ret
;--------------------------------
_abort:
	mov	rsi,msgbad
	call	os_output
	mov	rsi,[here_value]
	inc	rsi
	call	os_output
	mov	rsi,msgabort
	call	os_output
	ret
msgbad		db	"  Badword: ",0	
msgabort	db	" Abort!",0
;--------------------------------
_load:
	push 	qword [block_value]
	push	qword [block_value+8]
	push	qword [block_value+16]
	push	qword [_in_value]
	
	mov		rax, buffer_+8
	mov		[block_value+16],rax
	call	_push
	call	_rdblock
	
	xor		rbx,rbx
	mov		[_in_value],rbx
	mov		qword [block_value+8],8192
	
	call	_interpret
	
	pop		qword [_in_value]	
	pop		qword [block_value+16]
	pop		qword [block_value+8]
	pop 	qword [block_value]
	ret

;--------------------------------
_plus:
	call	_pop
	add		[r10 + r8],rax	
	ret
;--------------------------------

_opcode_code:
call _create
mov rax,[here_value]
mov dword [rax-8],op_compile_code
call _pop
mov cl,al
mov rbx,[here_value]
mov [rbx],al
inc rbx
and rcx,0ffh
add [here_value],rcx
inc qword [here_value]
oc1:
call _pop
mov [rbx],al
inc rbx
loop oc1
ret

op_compile_code:
movzx rcx,byte [rax+8]
inc rax
mov rdx,[top_of_code_val]
add [top_of_code_val],rcx
occ1:
mov bl,[rax+8]
mov [rdx],bl
inc rax
inc rdx
dec cl
jne occ1
ret
;--------------------------------
_sp@:
	mov		rax,r10
	call	_push
	ret
;--------------------------------
_resn:
	call	_pop
	add		[top_of_code_val],rax
	ret
;--------------------------------
lit_code:
	mov rax,[rsp+8]
	mov rax,[eax+8]
	call _push
	add qword [rsp+8],8
	ret
;--------------------------------
_link:
; aa bb
		call	_pop 	;base vocabulary
		mov		rbx,rax
		call	_pop	;linking vocabulary
		mov		rbx,[rbx]
		add		rax,16
		mov		[rax],rbx
		ret
;--------------------------------
_unlink:
		call	_pop
		mov		qword [rax+16],0
		ret
;--------------------------------	
code_top:
mov	rax,0xAAAAAAAAAAAAAAAA
mov	r11,0xBBBBBBBBBBBBBBBB
mov	rax,[rax]
call	rax
call	r11
call	[r11]

mov	rbx,rax
sub	rax,rbx

align 32, db 0cch



nkey	dq	0


align 8192
vocabulary:
section	seconf start=neworg

_here:

	db	6,0,0
	
	dq	nfa_34

align	8192,  db 0xbc
times	7680 db 0xcd

	%include "f/blocks.asm"
