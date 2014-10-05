  mov	rax,[hexstr]
	bswap	rax
	mov	rbx,[hexstr+8]
	bswap	rbx
	mov	[rsi+8],rax
	mov	[rsi],rbx
	
	movdqu	xmm0,[rsi]
	
	movdqu	xmm2,[efes]
	movdqu	xmm3,[sixes]
	movdqu	xmm4,[zeroes]
	movdqu	xmm7,[bytemask]
	psubb	xmm0,xmm4	; ????? ????
	paddb	xmm0,xmm3	; ???? ?????
	movdqa	xmm5,xmm0	;
	pand	xmm0,xmm2	
	psubb	xmm0,xmm3	;????? ?????
	psrlq	xmm5,4
	pand	xmm5,xmm2	;???????? ?????? ????????
	paddb	xmm0,xmm5
	psllq	xmm5,3
	por	xmm0,xmm5
	movdqa	xmm6,xmm0
	
	pxor	xmm8,xmm8
	
	pand	xmm0,xmm7
	psrlq	xmm6,8
	pand	xmm6,xmm7
	
	packsswb	xmm0,xmm8
	packsswb	xmm6,xmm8
	psllq	xmm6,4
	por		xmm0,xmm6

	movdqu	[value],xmm0
	
  ret
	
value     dq  0
	
hexstr    db '1234567890ABCDEF'

efes:	    dq	0f0f0f0f0f0f0f0fh
	        dq	0f0f0f0f0f0f0f0fh
zeroes:	  dq	3030303030303030h
	        dq	3030303030303030h
sixes:	  dq	0606060606060606h
	        dq	0606060606060606h
bytemask  dq	0ff00ff00ff00ffh
			    dq	0ff00ff00ff00ffh	      
