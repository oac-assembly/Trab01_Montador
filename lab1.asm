	.data
filename:		.asciiz "/home/daniel/Mars_OAC/Trab01/Trab01_Montador/exemplos/exemplo.asm"
buffer:  		.space 	15000		# Local da memória onde serão armazenados os caracteres do arquivo lido
data_buffer:		.space	15000		# Mais informações em subrotinas/separate_data-text.asm
text_label:		.ascii	".text"		# Mais informações em subrotinas/separate_data-text.asm
openfileErrorWarning:	.asciiz "Erro - O arquivo n�o foi aberto corretamente!"
 
	.text
### Abrindo o arquivo indicado por "filename"
openfile:
li	$v0,13			# Syscall - c�digo em v0 para abrir arquivo
la	$a0,filename		# Nome do arquivo
li	$a1,0 			# Abrir para ler (0: leitura, 1: escrita)
li 	$a2,0			# Modo � ignorado
syscall				# Abre o arquivo
beq	$v0,-1,openfileError	# Erro 
move	$s0,$v0			# Salva a descri��o do arquivo
j	readfile

### Indicando se houve erro para abrir o arquivo
openfileError:
li  	$v0,4          			# Syscall - C�digo em v0 para printar string
la	$a0,openfileErrorWarning   	# Buffer
syscall            			# Print string
li 	$v0, 10				# Syscall - Código em v0 para sair do programa
syscall 

### Lendo 1 caracatere do arquivo aberto e guardando em "buffer"
readfile:
li	$v0,14		# Syscall - c�digo em v0 para ler arquivo
move	$a0,$s0		# Descri��o do arquivo que dever� ser lido
la	$a1,buffer	# Buffer de leitura
li	$a2,15000	# N�mero m�ximo de caracteres a serem lidos
syscall			# L� o arquivo

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
bne 	$t6,$t7,print		# Se $t9 tiver passado do tamanho máximo de "text" significa que chegamos em um .text, se isso acontecer $t6 é zero
beq	$t8,$t9,compare_chars	# Se $t9 não tiver passado do tamanho máximo de "text" e os caracteres comparados foram iguais vá para compare_chars para continuar comparando

### Printando o que esta guardado em "buffer"
print:
li  $v0, 4          	# Syscall - C�digo em v0 para printar string
la  $a0, data_buffer    # Buffer a ser printado
syscall            	# Print string

### Fechando o arquivo
closefile:
li	$v0,16		# Syscall - c�digo em v0 para fechar arquivo
move	$a0,$s0		# Descri��o do arquivo que dever� ser fechado
syscall			# Fecha o arquivo






