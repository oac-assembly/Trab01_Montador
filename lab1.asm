	.data
filename:		.asciiz "C:\\oac_lab1\\arquivo.asm"
buffer:  		.space 128
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
j	openfile

### Lendo 1 caracatere do arquivo aberto e guardando em "buffer"
readfile:
li	$v0,14		# Syscall - c�digo em v0 para ler arquivo
move	$a0,$s0		# Descri��o do arquivo que dever� ser lido
la	$a1,buffer	# Buffer de leitura
li	$a2,1		# N�mero m�ximo de caracteres a serem lidos
syscall			# L� o arquivo

### Printando o que esta guardado em "buffer"
print:
li  $v0, 4          	# Syscall - C�digo em v0 para printar string
la  $a0, buffer    	# Buffer
syscall            	# Print string

### Fechando o arquivo
closefile:
li	$v0,16		# Syscall - c�digo em v0 para fechar arquivo
move	$a0,$s0		# Descri��o do arquivo que dever� ser fechado
syscall			# Fecha o arquivo






