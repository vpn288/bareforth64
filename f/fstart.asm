
       
; move vocabulary up        
        mov	rsi,vocabulary
        mov	rdi,neworg
        mov	rcx,8192
        rep	movsq
        
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
        mov	rax,nfa_0
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
        call	os_output
        call	_cr
        call	_expect
;mov rax,rcx
;call _push
;call _hex_dot
        call	_interpret
;call _0x
        jmp	_f_system
        ret
;---------------------
msgf:	db	"forth>",0 
