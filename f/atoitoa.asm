_hex_dot:
        call	_pop
        mov	[value],rax
        movdqu xmm0, [value] ;
        pxor xmm1,xmm1
        punpcklbw xmm0,xmm1 ; interleave bytes of value with nulls 
        movdqa xmm1,xmm0 ; copy
        pand xmm1,[fes] ; mask tetrades
        psllq xmm0,4 ; 
        pand xmm0,[fes] ;
        por xmm0,xmm1 ; assembly tetrades
        movdqa xmm1,xmm0 
        paddb xmm1,[sixes] ;
        psrlq xmm1,4
        pand xmm1,[fes]
        pxor xmm9,xmm9
        psubb xmm9,xmm1
        pand xmm9,[sevens]
        paddb xmm0,xmm9
        paddb xmm0,[zeroes]
        movdqu [hexstr],xmm0
        mov	rax,[hexstr]
        mov	r15,[hexstr+8]
        bswap	rax
        bswap	r15
        mov	[hexstr],r15
        mov	[hexstr+8],rax
        mov	byte [hexstr+17],0
        call	_space
        mov	rsi,hexstr
        mov	rcx,16
        call os_output
        call	_space
        ret
;--------------------
_0x:
	call	_pop
	mov		rbx,[rax]
	bswap	rbx
	
	mov		rcx,[rax+8]
	bswap	rcx
	mov	[rax+8],rbx
	mov	[rax],rcx
	movdqu		xmm0,[rax]
	movdqu		xmm2,[fes]
	movdqu		xmm3,[sixes]
	movdqu		xmm4,[zeroes]
	movdqu		xmm7,[bytemask]
	psubb		xmm0,xmm4	; ????? ????
	paddb		xmm0,xmm3	; ???? ?????
	movdqa		xmm5,xmm0	;
	pand		xmm0,xmm2	
	psubb		xmm0,xmm3	;????? ?????
	psrlq		xmm5,4
	pand		xmm5,xmm2	;???????? ?????? ????????
	paddb		xmm0,xmm5
	psllq		xmm5,3
	por			xmm0,xmm5
	movdqa		xmm6,xmm0
	
	pxor		xmm8,xmm8
	
	pand		xmm0,xmm7
	psrlq		xmm6,8
	pand		xmm6,xmm7
	
	packsswb	xmm0,xmm8
	packsswb	xmm6,xmm8
	psllq		xmm6,4
	por			xmm0,xmm6

	movdqu	 [ value],xmm0
	mov		rax,  [ value]
	call	_push
	ret

bytemask	dq	0ff00ff00ff00ffh
		dq	0ff00ff00ff00ffh

	
	
;--------------------
