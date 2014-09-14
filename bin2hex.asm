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
        
        
        mov     rax,[value]
        mov     rbx,rax
        
        and     rax,0f0f0f0f0f0f0f0fh
        and     rbx,f0f0f0f0f0f0f0f0h
        
        shr     rbx,4
        imul    rax,1f1f1f1f1f1f1f1fh
        imul    rbx,1f1f1f1f1f1f1f1fh
        shr     rax,4
        shr     rbx,4
        add     rax,3030303030303030h
        add     rbx,3030303030303030h
