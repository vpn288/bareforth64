; convert value to ascii hex string
; [value]
;

        
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
