	.data
filepath:		.asciiz "/home/daniel/Mars_OAC/Trab01/Trab01_Montador/exemplos/exemplo.asm"
filename:		.asciiz "/home/daniel/Mars_OAC/Trab01/Trab01_Montador/exemplos/label-file"
buffer:  		.space 	100		# Local da memória onde serão armazenados os caracteres do arquivo lido
data_buffer:		.space	15000		# Mais informações em subrotinas/separate_data-text.asm
text_buffer:		.space	1000		# Mais informações em subrotinas/separate_data-text.asm
line_buffer:		.space	100		# Buffer onde será armazenada a linha encontrada no arquivo lido
text_label:		.ascii	".text"		# Mais informações em subrotinas/separate_data-text.asm
label_text:		.space	100
openfileErrorWarning:	.asciiz "Erro - O arquivo n�o foi aberto corretamente!"
 
	.text	
###################################################################################################################################
#
#		Descrição - Subrotina que recebe em $a0 o endereço de um buffer que contem os dados de .text e escreve em um arquivo 
#			    o seguinte: nome_da_label:endereço_da_label
#
#		Entrada   - $a0 contém endereço de text_buffer
#
#		Saída     - É criado um arquivo com: nome_da_label:endereço_da_label
#
###################################################################################################################################

### Abrindo o arquivo indicado por "filename"
#openfile:
#li	$v0,13			# Syscall - c�digo em v0 para abrir arquivo
#la	$a0,filepath		# Nome do arquivo
#li	$a1,0 			# Abrir para ler (0: leitura, 1: escrita)
#li 	$a2,0			# Modo � ignorado
#syscall				# Abre o arquivo
#move	$s0,$v0			# Salva a descri��o do arquivo
#j	readfile

### Lendo 15000 caracateres do arquivo aberto e guardando em "buffer"
#readfile:
#li	$v0,14		# Syscall - c�digo em v0 para ler arquivo
#move	$a0,$s0		# Descri��o do arquivo que dever� ser lido
#la	$a1,buffer	# Buffer de leitura
#li	$a2,50		# N�mero m�ximo de caracteres a serem lidos
#syscall			# L� o arquivo

#la	$a0,buffer

### Subrotina que encontra as labels em .text
find_labels_text:
addi	$t0,$zero,10		# Coloca o valor 10 em $t0, representa \n em ascii
add	$t2,$zero,$a0		# Coloca o endereço $a0 (começo de text_buffer) em $t2
add	$t8,$a0,$zero		# Coloca o endereço $a0 (começo de text_buffer) em $t8
addi	$t7,$t8,1000		# Coloca o endereço do fim do text_buffer em $t7 ($t8 (começo de text_buffer) + (1000 - número de bytes no buffer))
la	$t9,label_text		# Coloca o endereço de label_text em $a1
### Subrotina que encontra uma nova_linha em .text
find_new_line:
lb	$t1,0($t8)		# Coloca o primeiro elemento do argumento $a0 (endereço de text_buffer) em $t1
beq	$t0,$t1,found_newline 	# Se $t0 (\n) for igual a $t1 (elemento de text_buffer) vá para found_newline
beq	$t7,$t8, FIM		# Se $t8 (endereço que aponta para um caractere do text_buffer) e $t7 (endereço máximo de text_buffer) forem iguais o buffer acabou
addi	$t8,$t8,1		# Incrementa o endereço em $a0
j	find_new_line		
### Subrotina que a partir de uma linha determina se existe ':' nela
found_newline:
add	$t4,$t2,$zero			# Coloca o endereço de $t2 (aponta para o primeiro caractere da linha) em $t4
find_doubledot:			
lb	$t5,0($t2)			# Coloca o byte no endereço de $t2 em $t5
beq	$t5,58,found_doubledot		# Compara se $t5 é igual a 58 (código ascii para ':'), se for igual vá para found_doubledot
addi	$t2,$t2,1			# Incrementa $t2 para pegar o próximo caractere da linha
beq	$t2,$t8,reinstate_variables	# Se $t2 (caractere da linha) for igual a $t8 (\n da linha) vá para no_doubledot
j 	find_doubledot
### Subrotina que a partir de um ':' identificado escreeve o conteúdo da linha no buffer label_text
found_doubledot:		
lb	$t6,0($t4)			# Coloca o elemento de $t4 (elemento da linha) em $t6
sb	$t6,0($t9)			# Salva o elemento de $t4 em $t9 (endereço de label_text)
addi	$t4,$t4,1			# Incrementa $t4 para pegar o próximo caractere
addi	$t9,$t9,1			# Incremente $t9 para colocar o próxima caractere na próxima posição do buffer
beq	$t2,$t4,write_buffertofile	# Se $t2 (endereço onde se encontra o ':') for igual a $t4 (endereço onde se encontra um caracter da linha) vá escrever o buffer no arquivo
j	found_doubledot


### Subrotina que escreve o conteúdo de label_text em um arquivo
write_buffertofile:
### Abrindo o arquivo em filepath
li	$v0,13			# Colocando código da chamada de sistema de abertura em $v0
la	$a0,filename		# Colocando o caminho do arquivo em $a0
li	$a1,9			# Colocando o modo de operação em $a1 (9 - write or append)
li	$a2,0			# Ignora o mode
syscall				# Realiza a chamada de sistema
move	$t5,$v0			# Salva o descritor do arquivo

### Escrever no arquivo aberto
li	$v0,15			# Colocando código para chamada de sistema de escrita em $v0
move	$a0,$t5			# Colocando o descritor do arquivo em $a0
la	$a1,label_text		# Colocando o endereço do buffer do qual será pego os dados para escrever
li	$a2,100			# Colocando o tamanho do buffer
syscall				# Realiza a chamada de sistema

### Fechar o arquivo aberto
li 	$v0,16			# Colocando o código para chamada de sistema de fechamento em $v0
move	$a0,$t5			# Colocando o descritor do arquivo em $a0
syscall				# Realiza a chamada de sistema
j	zerar_buffer

### Subrotina que zera o buffer
zerar_buffer:
la	$t3,label_text		# Coloca endereço do buffer label_text em $t3
addi	$t4,$t3,100		# Coloca o endereço máximo de label_text (label_text + 100) em $t4
loop_zeros:
sb	$zero,0($t3)			# Coloca 0 no endereço $t3 (endereço do buffer label_text)
addi	$t3,$t3,1			# Incrementa o valor de $t3 (endereço do buffer label_text)
beq	$t3,$t4,reinstate_variables	# Se $t3 (endereço que aponta para label_text) e $t4 (endereço que aponta para o fim de label_text) forem iguais o buffer foi zerado completamente
j 	loop_zeros

### Subrotina que redefine as variáveis do programa
reinstate_variables:
addi	$t8,$t8,1		# Incrementa o endereço em $t8 (endereço do \n da linha atual), $t8+1 aponta para o primeiro elemento da próxima linha
add	$t2,$t8,$zero
la	$t9,label_text		# Coloca o endereço de início de label_text em $t9
j	find_new_line

FIM:
add	$a0,$a0,$zero
