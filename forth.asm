

[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "bmdev.asm"

  start:	
	mov	r8,[data_stack_base]
	xor	r7, r7
	mov	r9,[data_stack_mask]
	mov	rsi,nfa_0+1
	call	b_output
	ret	
	
	
  _pop:
        mov eax , [ r7 + r8 ]
        sub r7 , 8
	and r7 , r9
	ret
	    
  _push:
        add r7 , 8
        and r7 , r9
        mov [ r7 + r8 ] , eax
        ret
;-----------------------

data_stack_base	dq	0x300000
data_stack_mask	dq	0x0fffff

  nfa_0:
	db 7, "FORTH64" ; ñëîâàðü äëÿ ñëîâ ðåàëüíîãî, âèðòóàëüíîãî 86
	db 0 ; òåðìèíèðóþùå-âûðàâíèâàþùèå íóëè
	align 8
	dq 0 ;LFA
	dq 0 ;CFA8
 f86_list:
	dq nfa_a ;PFA - óêàçàòåëü íà ëôà ïîñëåäíåãî îïðåäåëåííîãî ñëîâà
	dq 0 ; ññûëêà íà ïðåäûäóùèé ñïèñîê. áåçáàçîâûé ñïèñîê
nfa_1:
db 4, "EMIT"
db 0
dd nfa_0
dd emit_code
dd 0
nfa_2:
db 4, "TYPE"
db 0
dd nfa_1
type_:
dd type_code
dd 0
nfa_3:
db 4, "ret_"
db 0
dd nfa_2
ret_c:
dd constant_code
dd ret_
nfa_4:
db 6, "RBLOCK"
db 0
dd nfa_3
rblock_:
dd rblock_code
dd 0
nfa_5:
db 3, "IN>"
db 0
dd nfa_4
dd variable_code
value_in dd 0
in_old dd 0
nfa_6:
db 7, "CURRENT"
db 0
dd nfa_5
current_:
dd variable_code
current_var:
dd f86_list
nfa_7:
db 8, "lit_code"
db 0
dd nfa_6
dd constant_code
dd lit_ ;code
lit_:
dd lit_code
nfa_8:
db 2h,"0x"
db 0
dd nfa_7
dd _0x_code
dd 0
nfa_9:
db 5,"COUNT"
db 0
dd nfa_8
count_:
dd count_code
dd 0
nfa_10:
db 3,"DUP"
db 0
dd nfa_9
dup_:
dd dup_code
dd 0
nfa_11:
db 5,"SPACE"
db 0
dd nfa_10
space_:
dd blanc_code
dd 0
nfa_12:
db 1,"@"
db 0
dd nfa_11
_@_:
dd _@_code
dd 0
nfa_13:
db 1,"!"
db 0
dd nfa_12
_!_:
dd _!_code
dd 0
nfa_14:
db 7,"EXECUTE"
db 0
dd nfa_13
dd execute_code
dd 0
nfa_15:
db 4,"FIND"
db 0
dd nfa_14
find_:
dd find_code
dd 0
nfa_16:
db 4,"WORD"
db 0
dd nfa_15
word_:
dd addr_interp ; word_code
dd blk_
dd _@_
dd ?br_
dd w1
dd here_
dd _@_
dd tib_
dd enclose_ ; symbol to from
dd ret_
w1:
dd blk_
dd _@_
dd block_
dd here_
dd _@_
dd buffer_1_
dd _@_
dd enclose_
dd ret_
nfa_17:
db 4,"HERE"
db 0
dd nfa_16
here_:
dd variable_code
here_var:
dd here
nfa_18:
db 7,"CONTEXT"
db 0
dd nfa_17
dd variable_code
context_var:
dd f86_list
nfa_19:
db 6,"CREATE"
db 0
dd nfa_18
dd create_code
dd 0
nfa_20:
db 2,"BL"
db 0
dd nfa_19
bl_ dd constant_code
dd " "
nfa_21:
db 1,","
db 0
dd nfa_20
comma_:
dd comma_code
dd 0
nfa_22:
db 11,"buffer_size"
db 0
dd nfa_21
dd constant_code
dd 1000h
nfa_23:
db 5,"QUOTE"
db 0
dd nfa_22
dd constant_code
dd 22h
nfa_24:
db 7,"ENCLOSE" ; symbol to_adress from-address
db 0
dd nfa_23
enclose_:
dd enclose_code
dd 0
nfa_25:
db 2,".("
db 0
dd nfa_24
dd addr_interp
dd close_bracket
dd word_
dd count_
dd type_
dd ret_
nfa_26:
db 5,"STATE"
db 0
dd nfa_25
state_:
dd variable_code
state_var:
dd 0
nfa_27:
db 1,":"
db 0
dd nfa_26
dd colon_code
dd 0
nfa_28:
db 6,"FALSE!"
db 0
dd nfa_27
false_!_:
dd false_!_code
dd 0
nfa_29:
db 5,"TRUE!"
db 0
dd nfa_28
true_!_:
dd true_!_code
dd 0
nfa_30:
db 1,")"
db 0
dd nfa_29
close_bracket:
dd constant_code
dd ")"
nfa_31:
db 2,"3F"
db 0
dd nfa_30
latest_:
dd constant_code
dd 03fh
nfa_32:
db 4,"EXIT"
db 0
dd nfa_31
ret_:
dd ret_code
dd 0
nfa_33:
db 81h,"["
db 0
dd nfa_32
dd addr_interp
dd state_
dd false_!_
dd ret_
nfa_34:
db 7,"sg_data"
db 0
dd nfa_33
dd constant_code
dd sg_data
nfa_35:
db 6,"addr_i"
db 0
dd nfa_34
ai: dd label_compile_code
dd addr_interp
nfa_36:
db 81h,";"
db 0
dd nfa_35
dd addr_interp
dd ret_c
dd comma_
dd state_
dd false_!_
dd ret_
nfa_37:
db 5,"QUERY"
db 0
dd nfa_36
dd query_code
dd 0
nfa_38:
db 3,"TIB"
db 0
dd nfa_37
tib_:
dd constant_code
tib_var:
dd 0
nfa_39:
db 6,"EXPECT"
db 0
dd nfa_38
dd expect_code
dd 0
nfa_40:
db 4,"SPAN"
db 0
dd nfa_39
dd variable_code
span_var:
dd 0
nfa_41:
db 3,"BLK"
db 0
dd nfa_40
blk_:
dd variable_code
blk_var:
dd 0
nfa_42:
db 3,"tlb"
db 0
dd nfa_41
tlb:
dd variable_code
tlb_var:
dd 0
nfa_43:
db 82h,0dh,0ah
db 0
dd nfa_42
dd ret1
dd 0
nfa_44:
db 1,"]"
db 0
dd nfa_43
dd addr_interp
dd state_
dd true_!_
dd ret_
nfa_45:
db 5,">BODY"
db 0
dd nfa_44
to_body_:
dd to_body_code
dd 0
nfa_46:
db 4,"bin,"
db 0
dd nfa_45
dd bin_compile_code
dd 0
nfa_47:
db 8,"BUFFER_1"
db 0
dd nfa_46
buffer_1_:
dd variable_code
buffer_1:
dd 1000h
block1:
dd 0
dd 0
nfa_48:
db 8,"BUFFER_2"
db 0
dd nfa_47
dd variable_code
dd 2000h
dd 0
dd 0
nfa_49:
db 7,"buf_adr"
db 0
dd nfa_48
dd addr_interp
dd _@_
dd ret_
nfa_50:
db 9,"buf_block"
db 0
dd nfa_49
buf_block:
dd addr_interp
dd plus_cell_
dd plus_cell_
dd ret_
nfa_51:
db 9,"buf_state"
db 0
dd nfa_50
dd addr_interp
dd plus_cell_
dd ret_
nfa_52:
db 5,"+CELL"
db 0
dd nfa_51
plus_cell_:
dd plus_cell_code
dd 0
nfa_53:
db 5,"BLOCK"
db 0
dd nfa_52
block_:
dd addr_interp
dd dup_
dd buffer_1_
dd buf_block
dd _@_
dd _eq_ ;if equeal - true
dd ?br_ ; if true - branch
dd b1
dd dup_
dd dup_
dd buffer_1_
dd _@_
dd rblock_
dd buffer_1_
dd buf_block
dd _!_
b1:
dd drop_
dd ret_
nfa_54:
db 4,"LOAD"
db 0
dd nfa_53
dd load_code
dd 0
nfa_55:
db 6,"N>LINK"
db 0
dd nfa_54
dd nlink_code
dd 0
nfa_56:
db 7,"?BRANCH"
db 0
dd nfa_55
?br_:
dd ?br_code
dd 0
nfa_57:
db 6,"BRANCH"
db 0
dd nfa_56
br_:
dd br_code
dd 0
nfa_58:
db 6,"WBLOCK"
db 0
dd nfa_57
wrblock_:
dd wrblock_code
dd 0
nfa_59:
db 1,"="
db 0
dd nfa_58
_eq_:
dd _eq_code
dd 0
nfa_60:
db 4,"DROP"
db 0
dd nfa_59
drop_:
dd pop_code
dd 0
nfa_61:
db 4,"var_"
db 0
dd nfa_60
dd label_compile_code
dd variable_code
nfa_62:
db 8,"CONSTANT"
db 0
dd nfa_61
dd constant_create_code
dd 0
nfa_63:
db 1h,"1"
db 0
dd nfa_62
dd constant_code
dd 1
nfa_64:
db 5,"to_cf"
db 0
dd nfa_63
dd to_cf_code
dd 0
nfa_65:
db 8,"br_label"
db 0
dd nfa_64
br_label:
dd constant_code
dd br_
nfa_66:
db 9,"?br_label"
db 0
dd nfa_65
?br_label:
dd constant_code
dd ?br_
nfa_67:
db 9,"constant_"
db 0
dd nfa_66
constant_:
dd constant_code
dd constant_code
nfa_68:
db 3,"OR!"
db 0
dd nfa_67
dd or_!_code
dd 0
nfa_69:
db 2,"80"
db 0
dd nfa_68
dd constant_code
dd 80h
nfa_70:
db 1,"0"
db 0
dd nfa_69
dd constant_code
dd 0
nfa_71:
db 8,"off_data"
db 0
dd nfa_70
dd constant_code
dd off_data
nfa_72:
db 2,"<>"
db 0
dd nfa_71
dd not_eq_code
dd 0
nfa_73:
db 16,"how_many_sectors"
db 0
dd nfa_72
dd constant_code
dd how_many_sectors
nfa_74:
db 14,"dot_quote_code"
db 0
dd nfa_73
dd constant_code
dd dq_
dq_: dd dot_quote_code
nfa_75:
db 8,"code_top"
db 0
dd nfa_74
dd variable_code ;constant_code
top_of_code_val:
dd top_of_code
nfa_76:
db 8,"pop_code"
db 0
dd nfa_75
dd label_compile_code
dd pop_code
nfa_77:
db 6,"opcode"
db 0
dd nfa_76
dd opcode_code
dd 0
nfa_78:
db 9,"push_code"
db 0
dd nfa_77
dd label_compile_code
dd push_code
nfa_79:
db 1," "
db 0
dd nfa_78
dd 0
dd 0
nfa_80:
db 5,"label"
db 0
dd nfa_79
dd label_code
dd 0
nfa_a:
db 4,"Booo"
db 0
dd nfa_80
dd 0
dd 0
here:
last_lfa:
