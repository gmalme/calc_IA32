section .data
    msg_start db 'Bem-vindo! Digite seu nome: ',0
    msg_hello db 'Olá, ',0
    msg_hello2 db ', bem-vindo ao programa de CALC IA-32',10,0
    msg_16or32 db 'Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32): ',0
    msg_menu db 10,10,'Menu:',10,'1-SOMA',10,'2-SUBSTRACAO',10,'3-MULTIPLICACAO',10,'4-DIBIDIR',10,'5-EXPONENCIAR',10,'6-MOD OPERATION',10,'7-SAIR',10,0
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
global _start
global precision, input_str, msg_overflow, msg_input, msg_output ; # PUBLIC DATA

extern _readstr, _printstr, _exit, read16, print16, read32, print32 ; # sub, mul, div, exp, mod ; # Funcoes I/O
extern _sum ; # Funcoes Operacoes

%macro print 1
        push %1
        call _printstr
%endmacro
%macro read 1
        push %1
        call _readstr
%endmacro

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

    leave
    call _exit

menu16:
    cmp byte [precision], 1
    je menu32
    enter 0,0 ; # Mostra uma string | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str
    print msg_input
    push input_str
    call read16
    mov [ebp+10],ax

    print msg_input
    push input_str
    call read16
    mov [ebp+8],ax
    ;push ax

    leave
    ret
menu32:
    enter 0,0 ; # Mostra uma string | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str
    print msg_input
    push input_str
    call read32
    mov [ebp+12],eax

    print msg_input
    push input_str
    call read32
    mov [ebp+8],eax

    leave
    ret



print_result:
    enter 0,0
    print   msg_output

    cmp byte [precision], 1
    je print_result32

    push word [ebp+8]
    push input_str
    call print16

    jmp print_end

print_result32:
    push dword [ebp+8]
    push input_str
    call print32

print_end:
    leave
    ret

Op_sum:
    call    menu16  
	call	_sum
    call    print_result
	jmp		menu