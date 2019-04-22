	.data
filename:		.asciiz "C:\\oac_lab1\\arquivo.asm"
buffer:  		.space 128
openfileErrorWarning:	.asciiz "Erro - O arquivo não foi aberto corretamente!"
 
	.text
### Abrindo o arquivo indicado por "filename"
openfile:
li	$v0,13			# Syscall - código em v0 para abrir arquivo
la	$a0,filename		# Nome do arquivo
li	$a1,0 			# Abrir para ler (0: leitura, 1: escrita)
li 	$a2,0			# Modo é ignorado
syscall				# Abre o arquivo
beq	$v0,-1,openfileError	# Erro 
move	$s0,$v0			# Salva a descrição do arquivo
j	readfile

### Indicando se houve erro para abrir o arquivo
openfileError:
li  	$v0,4          			# Syscall - Código em v0 para printar string
la	$a0,openfileErrorWarning   	# Buffer
syscall            			# Print string
j	openfile

### Lendo 1 caracatere do arquivo aberto e guardando em "buffer"
readfile:
li	$v0,14		# Syscall - código em v0 para ler arquivo
move	$a0,$s0		# Descrição do arquivo que deverá ser lido
la	$a1,buffer	# Buffer de leitura
li	$a2,1		# Número máximo de caracteres a serem lidos
syscall			# Lê o arquivo

### Printando o que esta guardado em "buffer"
print:
li  $v0, 4          	# Syscall - Código em v0 para printar string
la  $a0, buffer    	# Buffer
syscall            	# Print string

### Fechando o arquivo
closefile:
li	$v0,16		# Syscall - código em v0 para fechar arquivo
move	$a0,$s0		# Descrição do arquivo que deverá ser fechado
syscall			# Fecha o arquivo






