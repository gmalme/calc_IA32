section .data
    msg_start db 'Bem-vindo! Digite seu nome: ',0
    msg_hello db 'Olá, ',0
    msg_hello2 db ', bem-vindo ao programa de CALC IA-32',10,0
    msg_16or32 db 'Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32): ',0
    msg_menu db 10,10,'Menu:',10,'1-SOMA',10,'2-SUBSTRACAO',10,'3-MULTIPLICACAO',10,'4-DIVIDIR',10,'5-EXPONENCIAR',10,'6-MOD OPERATION',10,'7-SAIR',10,0
    msg_input db 'Insira um numero: ',0
    msg_output db 'Resultado: ',0
    msg_overflow db 10,'OCORREU OVERFLOW',10,0
    ln db 10,0

section .bss
    username resb 100
    precision resb 1
    input_op resb 1
    input_str resb 100 

section .text ; ################################# MAIN #################################

%macro print 1
        push %1
        call _printstr
%endmacro
%macro read 1
        push %1
        call _readstr
%endmacro

global _start
global precision, input_str, msg_input, msg_output ; # PUBLIC DATA
extern _exit, _printstr, _readstr, _puts, _gets ; # Funcoes I/O
extern _sum, _sub, _mul, _div, _exp, _mod ; # Funcoes Operacoes

_start:
    print msg_start     ; # pergunta o username
    read username
    print msg_hello     ; # msg hello e pergunta a precisão
    print username
    print msg_hello2
    print msg_16or32
    read precision
    sub byte [precision], 0x30 

    enter 8,0
menu:
    print msg_menu      ; # msg menu e le entrada
    read input_op
    sub byte [input_op], 0x30   ; # transforma de ASCII p/ inteiro

    cmp byte [input_op], 1
    je Op_sum
    cmp byte [input_op], 2
    je Op_sub
    cmp byte [input_op], 3
    je Op_mul
    cmp byte [input_op], 4
    je Op_div
    cmp byte [input_op], 5
    je Op_exp
    cmp byte [input_op], 6
    je Op_mod

    leave
    call _exit

Op_sum:
    call    _gets
	call	_sum
    jc      Of_exit
    call    _puts
	jmp		menu
Op_sub:
    call    _gets
	call	_sub
    jc      Of_exit
    call    _puts
	jmp		menu
Op_mul:
    call    _gets
	call	_mul
    jc      Of_exit
    call    _puts
	jmp		menu
Op_div:
    call    _gets
	call	_div
    jc      Of_exit
    call    _puts
	jmp		menu
Op_exp:
    call    _gets
	call	_exp
    jc      Of_exit
    call    _puts
	jmp		menu
Op_mod:
    call    _gets
	call	_mod
    jc      Of_exit
    call    _puts
	jmp		menu

Of_exit:
    print msg_overflow
    jmp menu