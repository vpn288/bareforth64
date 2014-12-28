
nfa_0:
	db 7, "FORTH64",0 	
	align 8, db 0
	dq  nfa_0.5 ;LFA
	dq _vocabulary ;CFA
 f64_list:
	dq nfa_last ;PFA - oeacaoaeu ia eoa iineaaiaai ii?aaaeaiiiai neiaa
dq	_abort
nfa_0.5:
	db	6,0,0
	align 8, db 0
	dq	0
ret_:
	dq	_ret

nfa_1:
	db	4,"HEX." ,0
	align 8, db 0
	dq	nfa_0 
	dq	_hex_dot
	dq	0
nfa_2:
	db	4,"EMIT",0
	align 8, db 0
	dq	nfa_1
	dq	_emit
	dq	0
nfa_3:
	db	2,"CR",0
	align 8, db 0
	dq	nfa_2
cr_:
	dq	_cr
	dq	0
nfa_4:
	db	4,"TYPE",0
	align 8, db 0
	dq	nfa_3
type_:
	dq	_type
	dq	0
nfa_5:
	db	5,"COUNT",0
	align 8, db 0
	dq	nfa_4
count_:
	dq	_count
	dq	0
nfa_6:
	db	5,"SPACE",0
	align 8, db 0
	dq	nfa_5
	dq	_space
	dq	0
nfa_7:
	db	1,"@",0
	align 8, db 0
	dq	nfa_6
fetch_:
	dq	_fetch
	dq	0	

nfa_8:
	db	7,"CONTEXT",0
	align 8, db 0
	dq	nfa_7
	dq	_variable_code
context_value:	
	dq	f64_list
	dq	0
	dq	-1
	dq	-1
	dq	-1
	dq	-1
	dq	-1
	dq	0
	
	
nfa_9:	
	db	3,">IN",0
	align 8, db 0
	dq	nfa_8
	dq	_variable_code
_in_value:
	dq	0

nfa_10: 
	db	3,"DUP",0
	align 8, db 0
	dq	nfa_9
	dq	_dup
	dq	0

nfa_11: 
	db	3,"pop",0
	align 8, db 0
	dq	nfa_10
pop_:
	dq	_pop
	dq	0

nfa_12:
	db	4,"push",0
	align 8, db 0
	dq	nfa_11
push_:
	dq	_push
	dq	0

nfa_13:
	db	4,"(0x)",0
	align 8, db 0
	dq	nfa_12
_0x_:
	dq	_0x
	dq	0

nfa_14:
	db	4,"HERE",0
	align 8, db 0
	dq	nfa_13
	dq	_constant
here_value:
	dq	_here

nfa_15:
	db	2,"0x",0
	align 8, db 0
	dq	nfa_14
	dq	_addr_interp
	dq	number_
	dq	_0x_
	dq	ret_
	
nfa_16:

	db	12,"parse_number",0
	align 8, db 0
	dq	nfa_15
number_:
	dq	_number
	dq	0

nfa_17:
	db	7,"CURRENT",0
	align 8, db 0
	dq	nfa_16
current_:
	dq	_variable_code
current_value:
	dq	f64_list
	
nfa_18:
	db	6,"CREATE",0
	align 8, db 0
	dq	nfa_17
create_:
	dq	_create
	dq	0
	
nfa_19: 
	db	6,"N>LINK",0
	align 8, db 0
	dq	nfa_18
nlink_:
	dq	_nlink
	dq	0
	
nfa_20:
	db	6,"LATEST",0
	align 8, db 0
	dq	nfa_19
latest_:
	dq	_latest
	dq	0
	
	;dq	_addr_interp
	;dq	current_
	;dq	fetch_
	;dq	fetch_
	;dq	ret_
	
nfa_21:
	db	7,"BADWORD",0
	align 8, db 0
	dq	nfa_20
badword_:
	dq	_vect
	dq	abort_ ;timer_
	
	
nfa_22: 
	db	5,"BLOCK",0
	align 8, db 0
	dq	nfa_21
block_:
	dq	_variable_code
block_value:
	dq	0		;block number
	dq	64		;size of buffer
	dq	tibb	;address of input buffer

nfa_23:
	db	4,"prev",0
	align 8, db 0
	dq	nfa_22
	dq	_addr_interp
	dq	latest_
	dq	nlink_
	dq	fetch_
	dq	count_
	dq	type_
	dq	ret_
	
nfa_24:
	db	1,",",0
	align 8, db 0
	dq	nfa_23
comma_:
	dq	_comma
	dq	0

nfa_25:
	db	1,"'",0
	align 8, db 0
	dq	nfa_24
	dq	_addr_interp
	dq	word_
	dq	find_
	dq	pop_
	dq	ret_
	
nfa_26:
	db	4,"WORD",0
	align 8, db 0
	dq	nfa_25
word_:
	dq	_word
	dq	0

nfa_27:
	db	4,"FIND",0
	align 8, db 0
	dq	nfa_26
find_:
	dq	_find
	dq	0

nfa_28:
	db	7,"EXECUTE",0
	align 8, db 0
	dq	nfa_27
	dq	_execute_code
	dq	0

nfa_29:
	db	10,"interpret#",0
	align 8, db 0
	dq	nfa_28
	dq	_constant
	dq	_addr_interp
	
nfa_30:
	db	9,"constant#",0
	align 8, db 0
	dq	nfa_29
constantb_:
	dq	_constant
	dq	_constant
	
nfa_31:
	db	5,"NAME>",0
	align 8, db 0
	dq	nfa_30
	dq	_name
	dq	0
	
nfa_32: 
	db	1,"!",0
	align 8, db 0
	dq	nfa_31
	dq	_store
	dq	0

nfa_33:
	db	6,"HEADER",0
	align 8, db 0
	dq	nfa_32
header_:
	dq	_header
	dq	0
	

nfa_34:
	db	4,"ret#",0
	align 8, db 0
	dq	nfa_33
	dq	_constant
	dq	ret_
	

nfa_35:
	db	9,"variable#",0
	align 8, db 0
	dq	nfa_34
variableb_:
	dq	_constant
	dq	_variable_code

nfa_36:
	db	8,"VARIABLE",0
	align 8, db 0
	dq	nfa_35
	dq	_addr_interp
	dq	create_
	dq	zero_
	dq	comma_
	dq	ret_

nfa_37:
	db	1,"0",0
	align 8, db 0
	dq	nfa_36
zero_:
	dq	_constant
	dq	0
	
nfa_38:
	db 8,"CONSTANT",0
	align 8, db 0
	dq	nfa_37
	dq	_addr_interp
	dq	header_
	dq	constantb_
	dq	comma_
	dq	comma_ 
	dq	ret_
	
nfa_39:
	db	10,"VOCABULARY",0
	align 8, db 0
	dq	nfa_38
	dq	_vocabulary_create
	dq	0
	
nfa_40:
	db	6,"TIMER@",0
	align 8, db 0
	dq	nfa_39
timer_:
	dq	_timer
	dq	0

nfa_41:
	db	5,"CELL+",0
	align 8, db 0
	dq	nfa_40
cellp_:
	dq	_cellp
	dq	0

nfa_42:
	db	4,"DUMP",0
	align 8, db 0
	dq	nfa_41
dump_:
	dq	_dump
	dq	0

nfa_43:
	db	6,"(FIND)",0
	align 8, db 0
	dq	nfa_42
	dq	_sfind
	dq	0
	
nfa_44:
	db	5,"CELL-",0
	align 8, db 0
	dq	nfa_43
	dq	_cellm	
	dq	0
	
nfa_45:
	db	7,"rdblock",0
	align 8, db 0
	dq	nfa_44
	dq	_rdblock
	dq	0
	
nfa_46:
	db	5,"ALLOT",0
	align 8, db 0
	dq	nfa_45
	dq	_allot
	dq	0

nfa_47:
	db	3,"TIB",0
	align 8, db 0
	dq	nfa_46
	dq	_variable_code
	dq	63	;tibsize
tibb:
	times	64	 db	 20h 
	dq	0606060606060606h
	
nfa_48:
	db	5,"ABORT",0
	align 8, db 0
	dq	nfa_47
abort_:
	dq	_abort
	dq	0
	
nfa_49:
	db	7,"wrblock",0
	align 8, db 0
	dq	nfa_48
	dq	_wrblock
	dq	0
		
nfa_50:
	db	4,"LOAD",0
	align 8, db 0
	dq	nfa_49
	dq	_load
	dq	0
	
nfa_51:
	db	6,"BUFFER",0
	align 8, db 0
	dq	nfa_50
buffer_:
	dq	_variable_code
	times 8192 db	0

nfa_52:
	db	1,"+",0
	align 8, db 0
	dq	nfa_51
	dq	_plus
	dq	0
	
nfa_53:
	db	9,"code_here",0
	align 8, db 0
	dq	nfa_52
	dq	_constant
top_of_code_val:
	dq	code_top

nfa_54:
	db	6,"opcode",0
	align 8, db 0
	dq	nfa_53
	dq	_opcode_code
	dq	0
	
	
nfa_55:
	db	3,"SP@",0
	align 8, db 0
	dq	nfa_54
	dq	_sp@
	dq	0
	
nfa_56:	
	db	4,"RESn",0
	align 8, db 0
	dq	nfa_55
	dq	_resn
	dq	0
	
nfa_57:
	db	3,"LIT",0
	align 8, db 0
	dq	nfa_56
	dq	lit_code
	dq	0
	
nfa_58:
	db	4,"LINK",0
	align 8, db 0
	dq	nfa_57
	dq	_link
	dq	0
	
nfa_last:	
nfa_59:
	db	6,"UNLINK",0
	align 8, db 0
	dq	nfa_58
	dq	_unlink
	dq	0

