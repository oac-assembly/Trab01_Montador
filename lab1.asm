	.data
filename:		.asciiz "arquivo.asm"
buffer:  		.space 	15000		# Local da memória onde serão armazenados os caracteres do arquivo lido
data_buffer:		.space	15000		# Mais informações em subrotinas/separate_data-text.asm
line_buffer:		.space	100		# Buffer onde será armazenada a linha encontrada no arquivo lido
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
la $a0,data_buffer		# Coloca o endereço de ínicio de data_buffer no registrador temporário $s1 para utilizar como parametro para subrotina read_lina
#### Subrotina para encontrar a linha
find_line:
addi	$sp,$sp,-4 		# Criando pilha para adcionar o valor de $so		
sw	$a0,0($sp)		# Adicionando o valor de $s0 na pilha 

#la 	$s0,$s1		        # Coloca o endereço de ínicio de buffer no registrador temporário $t1
la	$t2,line_buffer		# Coloca o endereço de início de line_buffer no registrador temporário $t2
addi	$s2,$s2,10		# Coloca o valor 10 (valor ascii para "\n") no registrador $s1
compare_to_find_line:
lb	$t3,0($a0)		       # Coloca o byte/caractere armazenado no endereço $t1 no registrador $t3
bne	$t3,$s2,save_line_on_buffer    # Se o byte/caractere armazenado no endereço $t3 for diferente a 10 (valor ascii para "\n") pule para save_line_on_buffer
li  	$v0, 4          	# Syscall - C�digo em v0 para printar string
la  	$a1, line_buffer	# Buffer linha a ser printada
syscall            	# Print linha
# jal xxxx Colocar aqui a subrotina de processar os labels, usar jr para retornar e exercutar a proxima linha abaixo
# j xxxx subrotina para limpar o line_buffer (ainda tem que ser implementada)
#addi	$s0,$s0,1	# Incrementa o endereço do buffer para pegar o próximo caractere e montar a linha, linha comentada em quanto a subrotina acima nao for implementada
# bne $x,$x, compare_to_find_line:  # Implementar aqui uma forma de saber o final do buffer para sair do loop 
lw	$a0,0($sp)
addi 	$sp, $sp, 4
j closefile # Fechando o arquivo por enquanto que nao tem a subrotina de processar labels, apagar essa linha após implementacao 

### Coloca o byte/caractere de buffer em line_buffer
save_line_on_buffer:
sb	$t3,0($t2)		# Caso o caractere não seja "\n" coloca o mesmo no line_buffer
addi	$a0,$a0,1		# Caso o caractere não for "\n" incrementa o endereço do buffer para pegar o próximo caractere
addi	$t2,$t2,1		# Incrementa o endereço que aponta para line_buffer
j	compare_to_find_line

### Fechando o arquivo
closefile:
li	$v0,16		# Syscall - c�digo em v0 para fechar arquivo
move	$a1,$a0		# Descri��o do arquivo que dever� ser fechado
syscall			# Fecha o arquivo

############### Codificando .data e escrevendo no arquivo .mif

la	$a3,mifdata	# Argumento da rotina = Endere�o do caminho do arquivo mif de .data
jal	openfile_mif

la	$a3,cabecalho_mifdata	# Argumento da rotina = Endere�o do caminho do arquivo mif de .data
jal	write_mifcabecalho

### Loop ate acabar com a codificacao de .data
jal 	write_mifaddress
	## [TO DO] Codificao de uma linha de .data botando o resultado em $a3
		## ATEN�AO: caso utilize o registrador $s0, preservar o valor antigo com pilha!!
jal	write_mifcontent
### Fim do loop

jal	write_endmif

############### Codificando .text e escrevendo no arquivo .mif

la	$a3,miftext	# Argumento da rotina = Endere�o do caminho do arquivo mif de .text
jal	openfile_mif

la	$a3,cabecalho_miftext	# Argumento da rotina = Endere�o do caminho do arquivo mif de .text
jal	write_mifcabecalho

### Loop ate acabar com a codificacao de .data
jal 	write_mifaddress
	## [TO DO] Codificao de uma linha de .text botando o resultado em $a3
		## ATEN�AO: caso utilize o registrador $s0, preservar o valor antigo com pilha!!
jal	write_mifcontent
### Fim do loop

jal	write_endmif

### Rotinas utilizadas para abrir e escrever os arquivos .mif de saida

openfile_mif:
li	$v0,13			# Syscall - codigo em v0 para abrir arquivo
la	$a0,0($a3)		# Endereco do arquivo
li	$a1,1			# Abrir para escrever (0: leitura, 1: escrita)
li 	$a2,0			# Modo eh ignorado
syscall				# Abre o arquivo
beq	$v0,-1,openfileError	# Erro 
move	$s0,$v0			# Salva a descricao do arquivo
jr	$ra

write_mifcabecalho:
li	$v0,15			# Syscall - codigo em v0 para escrever no arquivo
move	$a0,$s0			# Descricao do arquivo que sera escrito
la	$a1,0($a3)		# Endereco do buffer de escrita
li	$a2,80			# Numeros de caracteres a serem escritos
syscall	
li 	$a3,0			# Setando o endereco de inicio como zero
jr	$ra

write_mifaddress:
addi	$sp,$sp,-8		# Para empilhar $ra e $a3
sw	$ra,4($sp)		# Empilha $ra
sw	$a3,0($sp)		# Empilha $a3
jal	to_hexadecimal 	
lw	$a3,0($sp)		# Desempilha $a3
lw	$ra,4($sp)		# Desempilha $ra
addi 	$sp, $sp, 8		# Limpa a pilha
addi	$a3,$a3,4		# Incrementa o valor do endereco
li	$v0,15			# Syscall - codigo em v0 para escrever no arquivo
move	$a0,$s0			# Descricao do arquivo que sera escrito
la	$a1,hexa_ascii		# Buffer de escrita
li	$a2,8			# Numeros de caracteres a serem escritos
syscall
write_colon_space:
li	$v0,15			# Syscall - codigo em v0 para escrever no arquivo
move	$a0,$s0			# Descricao do arquivo que sera escrito
la	$a1,colon_space		# Buffer de escrita
li	$a2,3			# Numeros de caracteres a serem escritos
syscall
addi	$sp,$sp,-8		# Para empilhar o valor de $a3 (Endereco) e $ra
sw	$a3,4($sp)		# Empilha a3
jr	$ra			# Retorna para onde foi chamado

write_mifcontent:
sw	$ra,0($sp)		# Empilha $ra
jal	to_hexadecimal
lw	$ra,0($sp)		# Desempilha $ra
lw	$a3,4($sp)		# Desempilha $a3	
addi 	$sp, $sp, 8 		# Limpa a pilha
li	$v0,15			# Syscall - codigo em v0 para escrever no arquivo
move	$a0,$s0			# Descricao do arquivo que sera escrito
la	$a1,hexa_ascii		# Buffer de escrita
li	$a2,8			# Numeros de caracteres a serem escritos
syscall
write_jumpline:
li	$v0,15			# Syscall - codigo em v0 para escrever no arquivo
move	$a0,$s0			# Descricao do arquivo que sera escrito
la	$a1,jumpline		# Buffer de escrita
li	$a2,2			# Numeros de caracteres a serem escritos
syscall
jr	$ra			# Retorna para onde foi chamado

to_hexadecimal:
li	$t1,8			# Contador: [00000000] > hexadecimal de 32 bits
la	$t2,hexa_ascii		# Onde vai ser guardado o caractere a ser escrito
addi	$t2,$t2,7		# Para escrever de tr�s para frente
li	$t3,0xf			# Mascara para fazer a opra��o and e selecionar os 4 bits a serem convertidos no valor correspondente hexadecimal
loop_to_hexadecimal:
beqz 	$t1,endloop		# Se o contador for zero, finaliza o loop
and 	$t4,$a3,$t3		# And com mascara "1111" para selecionar 4 bits
ror 	$a3,$a3,4		# Rotaciona a mascara para selecionar os proximos 4 bits
ble	$t4,9,soma_48		# Se o numero selecionado for maior que 9, soma 48, para converter para ascii
addi 	$t4,$t4,55		# Se o numero selecionado for maior que 9, soma 55, para converter para ascii
j	store_hex		
soma_48:
addi 	$t4,$t4,48
store_hex:			
sb	$t4,0($t2)		# Guarda o valor convertido em "address"
addi	$t2,$t2,-1		# Decrementa o endere�o de "address" (pois estamos escrevendo de tr�s para frente)
addi	$t1,$t1,-1		# Decrementa o contador
j	loop_to_hexadecimal	# Volta para o loop
endloop:
jr	$ra

write_endmif:
li	$v0,15			# Syscall - codigo em v0 para escrever no arquivo
move	$a0,$s0			# Descricao do arquivo que sera escrito
la	$a1,endmif		# Buffer de escrita
li	$a2,5			# Numeros de caracteres a serem escritos
syscall
closefile_mifdata:
li	$v0,16		# Syscall - codigo em v0 para fechar arquivo
move	$a0,$s0		# Descricao do arquivo que devera ser fechado
syscall			# Fecha o arquivo
jr	$ra
