mov rdx,0f0f0f0f0f0f0f0fh
     mov rcx,0606060606060606h
     mov rbp,3030303030303030h
                 mov rbx,rax
     and rax,rdx
     mov rdi,rax ;????? ?????????? ?????
                 shr rbx,4
                 and rbx,rdx
                 mov r9,rbx
     add rax,rcx
                 add rbx,rcx
     shr rax,4
                 shr rbx,4
     and rax,rdx
                 and rbx,rdx ; ?????? ? ??? ??????, ??????? ????????????? ?????? ?????? 9, ????????? ???????. ? ?????? - ????.
     mov rsi,rax
                 mov r8,rbx
     shl rsi,1
                 shl r8,1
     or rax,rsi
                 or rbx,r8
     shl rsi,1
                shl r8,1
     or rax,rsi
                or rbx,r8
     add rax,rbp
                add rbx,rbp ;?????? ???, ??? ???? ???????, ???????????? 11h
     add rax,rdi
                add rbx,r9
     mov [_message],rax
                mov [_message+8],rbx  ; convert bin value to ascii hex string
; [value]
; NASM


value   dq 1234567890abcdefh

hexstr  times 16 db     0

; 1st way
        
        mov     cx,8
        mov     si,value
        mov     di,hexstr
        add     si,cx            ;highest byte of value
m3:        
        std
        lodsb
        mov     bl,al
        and     al,0fh
        call    digit
        
        cld
        stosb
        mov     al,bl
        shr     al,4
        call    digit
        loop    m3
        ret
        
digit:
        cmp     al,09
        jnb     m1
                                ;digit greater than 9
        add     al,41h
        jmp     m2
m1:
        add     al,30h
m2:
        ret
        
        
;-----------------------------------------------
;2-nd way optimisation addition

        mov     cx,8
        mov     si,value
        mov     di,hexstr
        add     si,cx            ;highest byte of value
m3:        
        std
        lodsb
        mov     bl,al
        and     al,0fh
        call    digit
        
        cld
        stosb
        mov     al,bl
        shr     al,4
        call    digit
        loop    m3
        ret
        
digit:
        add     al,30h
        cmp     al,39h
        jnb     m2
                                ;digit greater than 9
        add     al,11h
m2:
        ret
        
;-----------------------------------------------
;3-d way without jnb


	mov     cx,8
        mov     si,value
        mov     di,hexstr
        add     si,cx            ;highest byte of value
m3:        
        std
        lodsb
        mov     bl,al
        and     al,0fh
        call    digit
        
        cld
        stosb
        mov     al,bl
        shr     al,4
        call    digit
        loop    m3
        ret
        
digit:
        mov     ah,30h
        aaa
        aad     17              ;trick aad with nonstandart parameter
        ret
;-----------------------------------------------
;4-d way without jnb


	mov     cx,8
        mov     si,value
        mov     di,hexstr
        add     si,cx            ;highest byte of value
m3:        
        std
        lodsb
        mov     bl,al
        and     al,0fh
        call    digit
        
        cld
        stosb
        mov     al,bl
        shr     al,4
        call    digit
        loop    m3
        ret
        
digit:
     
	MOV BL,0Ah
	xor	ah,ah
       DIV BL
          MOV BH,AL
       SHL AL,4
         ADD AL,BH
         ADD AL,30h

        ret        
        
;-----------------------------------------------
	mov     cx,8
        mov     si,value
        mov     di,hexstr
        mov	bx,hextable
        add     si,cx            ;highest byte of value
m3:        
        std
        lodsb
        mov	ah,al
        and	al,0fh
        xlatb
        cld
        stosb
        mov	al,ah
        shr	al,4
        xlatb
        stosb
        loop	m3
        ret
 hextable	db	'0123456789ABCDEF'
        
;-----------------------------------------------

        mov     rax,[value]
        mov     rbx,rax
      
	mov	rdx,0f0f0f0f0f0f0f0fh
	
	shr	rbx,4
        and     rax,rdx	
        and     rbx,rdx
      
        mov	r9, 0606060606060606h
	mov	r11,0d0d0d0d0d0d0d0dh

	mov	rdx,rax
	add	rdx,r9
	
	mov	r10,0f0f0f0f0f0f0f0f0h
	and	rdx,r10
	shr	rdx,2
	mov	r12,rdx
	shr	r12,1
	or	rdx,r12
	shr	r12,1
	or	rdx,r12
	add	rax,rdx
	

	mov	rdx,rbx
	add	rdx,r9
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
	mov	rcx,4


m1:
	rol	rbx,8
	shrd	[hexstr],rbx,8
	rol	rax,8
	shrd	[hexstr],rax,8	
	loop	m1	
	mov	rcx,4
m3:
	rol	rbx,8
	shrd	[hexstr+8],rbx,8
	rol	rax,8
	shrd	[hexstr+8],rax,8	
	loop	m3
	ret		

  ;-----------------------------------------------
  	mov     rax,[value]
  	mov     rbx,rax
  	
	mov	rdx,0f0f0f0f0f0f0f0fh
	
	shr	rbx,4
        and     rax,rdx	
        and     rbx,rdx
      
        mov	r9, 0606060606060606h
	mov	r11,0d0d0d0d0d0d0d0dh

	mov	rdx,rax
	add	rdx,r9
	
	mov	r10,0f0f0f0f0f0f0f0f0h
	and	rdx,r10
	shr	rdx,2
	mov	r12,rdx
	shr	r12,1
	or	rdx,r12
	shr	r12,1
	or	rdx,r12
	add	rax,rdx

	mov	rdx,rbx
	add	rdx,r9
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
	mov	rcx,4

	bswap	rax
	bswap	rbx
	mov	[hexstr],rax
	mov	[hexstr+8],rbx
	movdqu	xmm0,[hexstr]
	movdqu	xmm1,[hexstr+8]
	punpcklbw	xmm1,xmm0
	movdqu	[hexstr],xmm1
     	ret
     	
     	
;--------------------------
     	
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
	ret
	
efes:	dq	0f0f0f0f0f0f0f0fh
	dq	0f0f0f0f0f0f0f0fh
zeroes:	dq	3030303030303030h
	dq	3030303030303030h
sixes:	dq	0606060606060606h
	dq	0606060606060606h
sevens:	dq	0707070707070707h
	dq	0707070707070707h	
	
