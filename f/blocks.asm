db	'   0x AABBCCEE      HEX.   >IN @ HEX.  '
db	' VOCABULARY ASSEMBLER ASSEMBLER CURRENT ! '
;db	" HEADER RESn  interpret# , ' code_here CELL+ @ +   ' code_here CELL+ ! ret# ,  "
db	'             0x 90 0x 1 opcode nop '
db	'             0x CC 0x 1 opcode int3 '
db	'             0x C3 0x 1 opcode ret '
db	'       0x B8 0x 48 0x 2 opcode mov_rax,# ' 
db	'       0x BB 0x 49 0x 2 opcode mov_r11,# '
db	'		0x D0 0x FF 0x 2 opcode call_rax '
db	' 0x 00 0x 8B 0x 48 0x 3 opcode mov_rax,[rax] '
db	' 0x C3 0x 89 0x 48 0x 3 opcode mov_rbx,rax '
db	' 0x D8 0x 29 0x 48 0x 3 opcode sub_rax,rbx '
db	' 0x D3 0x FF 0x 41 0x 3 opcode call_r11 '
; db	' 0x 13 0x FF 0x 41 0x 3 opcode call_[r11] '

db	' FORTH64 CURRENT ! '
db	' ASSEMBLER CONTEXT CELL+ ! '
db	" HEADER -   code_here DUP HEX.  ,  mov_r11,#   ' pop @  code_here !   0x 8 RESn " 
db	"  call_r11  mov_rbx,rax  "
db	"  call_r11 sub_rax,rbx  mov_r11,#  ' push @  code_here  ! 0x 8 RESn  call_r11  ret "
dq	6
align 8192, db	' '
db	" VOCABULARY cc cc CURRENT ! cc FORTH64 LINK cc CONTEXT ! "
db 	" VARIABLE kk  0x ACED kk ! "
db	"  HEADER jj  interpret# ,  ' LIT ,  0x FACE12  ,  ' HEX. ,  ret# ,  "
db	" FORTH64 CURRENT ! "
db	"  " 
dq	6
align 8192, db	' '
times 1121  db 0xaa 
