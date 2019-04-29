	.data
buffer:  		.space  15000	# Buffer onde serão armazenados os caracteres do arquivo
text_buffer		.space  15000 	# Buffer onde serão armazenados os caracteres pertencentes a seção .text
data_buffer:		.space	15000	# Buffer onde estão armazenados os caracteres pertencentes a seção .data
text_buffer:		.space	1000	# Buffer onde estão armazenados os caracteres pertencentes a seção .data
text_label:		.ascii	".text"
openfileErrorWarning:	.asciiz "Erro - O arquivo n�o foi aberto corretamente!"
 
	.text
################################################################################################################################
#
#	Descrição - Rotina que a partir de um arquivo .asm armazenado em buffer separa .data e .text em dois buffers diferente.
#		    
#       Entrada   - Endereço do buffer do arquivo lido 
#                 - Endereço do buffer onde serão colocados os caracteres de .data
#		  - Endereço do buffer onde serão colocados os caracteres de .text
#                 - Endereço de onde fica a string de comparação ".text"
#	Saída     - Parte .data armazenada em data_buffer, parte .text armazenada em text_buffer, modificar 
#       
################################################################################################################################

### Lendo caractere por caractere e colocando em data_buffer até encontrar um ponto
separate_data_text:
la 	$s6,buffer		# Coloca o endereço de ínicio de buffer no registrador $s6
la	$t2,data_buffer		# Coloca o endereço de início de data_buffer no registrador temporário $t2
addi	$s1,$s1,46		# Coloca o valor 46 (valor ascii para ".") no registrador $s1
compare_char:
lb	$t3,0($s6)		# Coloca o byte/caractere armazenado no endereço $t1 no registrador $t3
beq	$t3,$s1,found_dot	# Se o byte/caractere armazenado no endereço $t3 for igual a 46 (valor ascii para ".") pule para found_text
### Coloca o byte/caractere de buffer em data_buffer
store_byte_data:	
sb	$t3,0($t2)		# Caso o caractere não seja "." coloca o mesmo no buffer que contém os caracteres de .data
addi	$s6,$s6,1		# Caso o caractere não for "." incrementa o endereço do buffer para pegar o próximo caractere
addi	$t2,$t2,1		# Incrementa o endereço que aponta para data_buffer
j	compare_char
### Subrotina que determina se o ponto achado está associado com .text
found_dot:
la	$a2,text_label		# Guarda o endereço de início de onde está armazenada a string: "text"
la	$a1,text_label		# Coloca o endereço de início de onde está armazenada a string: "text"
addi	$a1,$a1,4		# Coloca o endereço após o último caractere de "text", ou seja 5 (tamanho de .text) + 1
add	$t1,$zero,$s6		# Coloca o endereço do caractere de buffer apontado por $s0 em $t1 afim de preservar o endereço
compare_chars:
addi	$t1,$t1,1		# Incrementa $t1 para pegar o próximo caractere depois do ponto "." encontrado
addi	$a2,$a2,1
lb	$t8,0($t1)		# Coloca o caractere em $t1 em $t8
lb	$t9,0($a2)		# Coloca um determinado caractere de "text" em $t9
bne	$t8,$t9,store_byte_data # Se o caracter que pertencere a uma label com . não for igual a algum caractere de .text vá para store_byte-data
slt	$t6,$a2,$a1		# Coloca 1 em $t6 enquanto o endereço apontado por $t9 não passar do final de "text"
addi	$t7,$zero,1		# Coloca 1 no registrador $t7
bne 	$t6,$t7,store_text    	# Se $t9 tiver passado do tamanho máximo de "text" significa que chegamos em um .text, se isso acontecer $t6 é zero
beq	$t8,$t9,compare_chars	# Se $t9 não tiver passado do tamanho máximo de "text" e os caracteres comparados foram iguais vá para compare_chars para continuar comparando
### Subrotina de colocar todos os caracteres de um arquivo em um buffer
store_text:
la	$t0,text_buffer		# Coloca o endereço de text_buffer em $t0
la	$t1,buffer		# Coloca o endereço de buffer em $t1
addi	$t2,$t1,1000		# Soma o endereço de buffer com a quantidade de elementos que ele possui, 15000
add	$t3,$zero,$s6		# Coloca o endereço em $s0 (aponta pra o . de .text) no registrador $t3
move_char_buffer:
lb	$t4,0($t3)		# Coloca o byte/caractere em $t3 no registrador $t4
sb	$t4,0($t0)		# Coloca o byte/caractere em $t3 no endereço de text_buffer 0($t0)
addi	$t0,$t0,1		# Incrementa o endereço de text_buffer
addi	$t3,$t3,1		# Incrementa o ponteiro para o próxima caractere de buffer
beq	$t2,$t3,proxima_label	# Caso $t2 (endereço fim do arquivo) e $t3 (ponteiro para caractere a partir do . de .text) forem iguais o arquivo chegou ao fim
bne	$t2,$t3,move_char_buffer # Caso $t2 e $t3 não forem iguais volte para o loop
