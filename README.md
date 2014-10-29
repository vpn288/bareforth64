bareforth64
===========

Forth like system for baremetalos

R7 - SP
R8 - base for data stack
R9 - mask for data stack

CONTEXT - переменная в восемь ячеек.
CONTEXT@ кладет на стек все ячейки.
Слово (FIND) снимает со стека значение

dq	f64_list
dq	-1
dq	-1
dq	-1
dq	-1
dq	-1
dq	-1
dq	0

если оно -1, скипаем, снимаем следующее
если 0 - заканчивем поиск
