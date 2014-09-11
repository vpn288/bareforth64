; convert value to ascii hex string
; rax - value
;

        mov     rbx,rax
        and     rax,0f0f0f0f0f0f0f0f
        and     rbx,f0f0f0f0f0f0f0f0
        
