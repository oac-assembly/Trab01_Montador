	.data
mifdata:		.asciiz "C:\\oac_lab1\\mifdata.mif"
miftext:		.asciiz "C:\\oac_lab1\\miftext.mif"
cabecalho_mifdata:	.ascii	"DEPTH = 16384;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n" 
cabecalho_miftext:	.ascii	"DEPTH = 4096;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n"
endmif:			.asciiz	"END;"
colon_space:		.ascii	" : "
jumpline:		.ascii	";\n"
hexa_ascii:		.space	8
openfileErrorWarning:	.asciiz "Erro - O arquivo nao foi aberto corretamente!"

	.text
#########################################################################################
#
#	Descricao - Rotina para escrever os arquivos .mif
#       Entrada   - Enderecos dos arquivos
#                 - Cabecalhos dos arquivos
#		  - Valor do conteudo a ser escrito
#	Saida     - Arquivo .mif
#       
########################################################################################

# Passar para $a3 para o endereco do arquivo mifdata ou miftext
#la	$a3,mifdata
# la	$a3,miftext
jal	openfile_mif
# Passar para $a3 para o endereco do cabecalho de mifdata ou miftext
#la	$a3,cabecalho_mifdata
# la	$a3,cabecalho_miftext
jal	write_mifcabecalho
jal 	write_mifaddress
# Passar para $a3 para o valor de conteudo ser escrito
# li	$a3,'value
jal	write_mifcontent
jal	write_endmif
j	end

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
addi	$t2,$t2,7		# Para escrever de trás para frente
li	$t3,0xf			# Mascara para fazer a opração and e selecionar os 4 bits a serem convertidos no valor correspondente hexadecimal
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
addi	$t2,$t2,-1		# Decrementa o endereço de "address" (pois estamos escrevendo de trás para frente)
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

### Indicando se houve erro para abrir o arquivo
openfileError:
li  	$v0,4          			# Syscall - Cï¿½digo em v0 para printar string
la	$a0,openfileErrorWarning   	# Buffer
syscall            			# Print string
j	openfile_mif

end: