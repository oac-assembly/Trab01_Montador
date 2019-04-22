	.data
buffer: 	.space 128
end:		.byte  00
	.text
#########################################################################################
#
#	Descrição - Rotina que pega o input de um usuário (caminho absoluto para um arquivo .asm) e concatena \0 no fim.
#       Entrada   - buffer com tamanho máximo de bytes de entrada
#                 - valor associado ao caractere \0
#	Saída     - String com \0 concatenado, Registrador: $v0
#       
########################################################################################


# Subrotina que lê o caminho absoluto do arquivo .asm
read_filepath:
li	$v0, 8			# Código para leitura de string no registrador $v0
la	$a0, buffer 	        # Carrega o tamanho buffer para o registrador $a0
li	$a1, 600		# Carrega o número máximo de caracteres (600) a serem lidos no registrador $a1
syscall				# Faz a chamada de sistema para pedir input do usuário
move	$v0, $a0		# Coloca a string lida no registrador $v0 de saída
j	concatenate_filepathe_end

# Subrotina que verifica onde se encontra o primeiro byte vazio do buffer para inserir o \0
concatenate_filepathe_end:
move	$a0, $v0		# Coloca o endereço da saída de read_filepath, caminho absoluto do arquivo em $a0
move 	$t0, $a0		# Coloca o endereço da saída de read_filepath em um registrador temporário $t0

# Loop que fará iteração pelo bloco de memória associado ao buffer até encontrar o primeiro byte igual a zero
check_loop:
lb	$t1, 0($t0)		# Carrega o primeiro byte de $t0 (buffer) em $t1
beq	$t1, $zero, end_address # Verifica se $t1 for zero, se verdadeiro vá para end_address, se falso próxima inst
addi	$t0, $t0, 1		# Incrementa o endereço associado a $t0 (buffer), aponta para o próximo byte do buffer
b	check_loop		# Branch para o laço check_loop

# Subrotina de encerramento, coloca \0 no endereço onde o primeiro byte nulo do buffer se encontra
end_address:			
lb	$t2, end		# Coloca o valor do byte em end no registrador $t2
sb	$t2, 0($t0)		# Salva o byte em $t2 (\0) no endereço guardado em $t0 (endereço onde o primeiro byte do buffer se encontra)
move	$v0, buffer         	# Deixa o endereço de início do buffer (onde a string se encontra) no registrador $v0 de retorno




