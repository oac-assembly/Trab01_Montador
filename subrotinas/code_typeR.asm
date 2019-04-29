	.data
buffer_linha:	.asciiz "add $t3,$t4,$t1"
zero:		.word 0
v0:		.word 2
v1:		.word 3
a0:		.word 4
a1:		.word 5
a2:		.word 6
a3:		.word 7
t0:		.word 8
t1:		.word 9
t3: 		.word 11
t4: 		.word 12
t5: 		.word 13
t6: 		.word 14
t7:		.word 15
s0:		.word 16
s1:		.word 17
s2:		.word 18
s3:		.word 19
s4:		.word 20
s5:		.word 21
s6:		.word 22
s7:		.word 23
t8:		.word 24
t9:		.word 25
opcode:		.word 0	
shamt:		.word 0
func: 		.word 0

	.text

########################################################################################
#
#	Descricao - Rotina para odificar as instrucoes tipo 5
#       Entrada   - Qual a operacao
#                 - Regitradores rs,rt,rd passados por parâmetro em a0,a1,a2
#	Saida     - Resultado da operacao realizada em $a3
#       
########################################################################################
	
	
	
# $a0 = rs, $a1 = rt, $a2 = rd

code_add:			
li		$t0,0
sw		$t0,opcode
sw		$t0,shamt
li		$t0,32
sw		$t0,func
code_sub:
li		$t0,0
sw		$t0,opcode
sw		$t0,shamt
li		$t0,34
sw		$t0,func
code_and:
li		$t0,0
sw		$t0,opcode
sw		$t0,shamt
li		$t0,36
sw		$t0,func
code_or:
li		$t0,0
sw		$t0,opcode
sw		$t0,shamt
li		$t0,37
sw		$t0,func
code_nor:
li		$t0,0
sw		$t0,opcode
sw		$t0,shamt
li		$t0,39
sw		$t0,func
code_addu:
li		$t0,0
sw		$t0,opcode
sw		$t0,shamt
li		$t0,33
sw		$t0,func
code_subu:
li		$t0,0
sw		$t0,opcode
sw		$t0,shamt
li		$t0,35
sw		$t0,func
code_slt:
li		$t0,0
sw		$t0,opcode
sw		$t0,shamt
li		$t0,42
sw		$t0,func
code_srav:
li		$t0,0
sw		$t0,opcode
sw		$t0,shamt
li		$t0,7
sw		$t0,func


#### Para Tipo-R
lw		$a0,t4
lw		$a1,t1
lw		$a2,t3

lw		$t1,opcode
rol		$a3,$t1,26

move		$t1,$a0		# rs
rol		$t1,$t1,21
or		$a3,$a3,$t1

move		$t1,$a1		# rt
rol		$t1,$t1,16
or		$a3,$a3,$t1

move		$t1,$a2		# rd
rol		$t1,$t1,11
or		$a3,$a3,$t1

lw		$t1,shamt
rol		$t1,$t1,6
or		$a3,$a3,$t1

lw		$t1,func
or		$a3,$a3,$t1

