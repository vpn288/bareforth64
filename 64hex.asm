; convert value to ascii hex string
; [value]
;

        vmovq   xmm0,[value]
        vmovq   xmm1,xmm0
        andps   xmm0,[mask] ;pand?
        paddb   xmm0,[adds]
        
        and     rax,0f0f0f0f0f0f0f0f
        and     rbx,f0f0f0f0f0f0f0f0
        
