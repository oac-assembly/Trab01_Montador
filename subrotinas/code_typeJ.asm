	.data
buffer_linha:	.asciiz "j $a1"

opcode:		.word 0
imm:		.word 4194344 #teste
	.text

########################################################################################
#
#	Descricao - Rotina para codificar as instrucoes tipo J
#       Entrada   - Qual a operacao
#                 - Regitradores imm  passados por par�metro em a0
#	Saida     - Resultado da operacao realizada em $a3
#       
########################################################################################

	
# $a0 = imm

code_j:			
li		$t0,2	#opcode do j
sw		$t0,opcode
#lw		$a2, imm #imm de teste
j 		typeJ
	
code_jal:
li		$t0,3	#opcode do jal
sw		$t0,opcode
j 		typeJ	

#### Para Tipo-R
typeJ: 

typeI:
lw		$t1,opcode
rol		$t1,$t1,26
or		$a3,$a3,$t1
move		$t1,$a2		# immm
or		$a3,$a3,$t1
