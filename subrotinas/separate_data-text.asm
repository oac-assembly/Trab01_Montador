	.data
buffer:  		.space  15000	# Buffer onde serão armazenados os caracteres do arquivo
data_buffer:		.space	15000	# Buffer onde estão armazenados os caracteres pertencentes a seção .data
text_label:		.ascii	".text"
openfileErrorWarning:	.asciiz "Erro - O arquivo n�o foi aberto corretamente!"
 
	.text
#########################################################################################
#
#	Descrição - Rotina que a partir de um arquivo .asm armazenado em buffer separa .data e .text em dois buffers diferente.
#		    Após sua execução o registrador $s0 aponta para onde começa o .text e oque existe em .data fica na memória em
#                   data_buffer.
#       Entrada   - Endereço do buffer do arquivo lido
#                 - Endereço do buffer onde serão colocados os caracteres de .data
#                 - Endereço de onde fica a string de comparação .text
#	Saída     - String com \0 concatenado, Registrador: $v0
#       
########################################################################################

### Lendo caractere por caractere e colocando em data_buffer até encontrar um ponto
separate_data_text:
la 	$s0,buffer		# Coloca o endereço de ínicio de buffer no registrador temporário $t1
la	$t2,data_buffer		# Coloca o endereço de início de data_buffer no registrador temporário $t2
addi	$s1,$s1,46		# Coloca o valor 46 (valor ascii para ".") no registrador $s1
compare_char:
lb	$t3,0($s0)		# Coloca o byte/caractere armazenado no endereço $t1 no registrador $t3
beq	$t3,$s1,found_dot	# Se o byte/caractere armazenado no endereço $t3 for igual a 46 (valor ascii para ".") pule para found_text
### Coloca o byte/caractere de buffer em data_buffer
store_byte_data:	
sb	$t3,0($t2)		# Caso o caractere não seja "." coloca o mesmo no buffer que contém os caracteres de .data
addi	$s0,$s0,1		# Caso o caractere não for "." incrementa o endereço do buffer para pegar o próximo caractere
addi	$t2,$t2,1		# Incrementa o endereço que aponta para data_buffer
j	compare_char
### Subrotina que determina se o ponto achado está associado com .text
found_dot:
la	$a2,text_label		# Guarda o endereço de início de onde está armazenada a string: "text"
la	$a1,text_label		# Coloca o endereço de início de onde está armazenada a string: "text"
addi	$a1,$a1,4		# Coloca o endereço após o último caractere de "text", ou seja 5 (tamanho de .text) + 1
add	$t1,$zero,$s0		# Coloca o endereço do caractere de buffer apontado por $s0 em $t1 afim de preservar o endereço
compare_chars:
addi	$t1,$t1,1		# Incrementa $t1 para pegar o próximo caractere depois do ponto "." encontrado
addi	$a2,$a2,1
lb	$t8,0($t1)		# Coloca o caractere em $t1 em $t8
lb	$t9,0($a2)		# Coloca um determinado caractere de "text" em $t9
bne	$t8,$t9,store_byte_data # Se o caracter que pertencere a uma label com . não for igual a algum caractere de .text vá para store_byte-data
slt	$t6,$a2,$a1		# Coloca 1 em $t6 enquanto o endereço apontado por $t9 não passar do final de "text"
addi	$t7,$zero,1		# Coloca 1 no registrador $t7
bne 	$t6,$t7,proxima_sub	# Se $t9 tiver passado do tamanho máximo de "text" significa que chegamos em um .text, se isso acontecer $t6 é zero
beq	$t8,$t9,compare_chars	# Se $t9 não tiver passado do tamanho máximo de "text" e os caracteres comparados foram iguais vá para compare_chars para continuar comparando
