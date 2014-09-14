; convert bin value to ascii hex string
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
        aam     17              ;trick aam with nonstandart parameter
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

        
     
