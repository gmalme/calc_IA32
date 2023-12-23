; ################################# I/O #################################
section .text

%macro print 1
        push %1
        call _printstr
%endmacro
%macro read 1
        push %1
        call _readstr
%endmacro

; ################################# Public Functions #################################
global _exit, _readstr, _printstr, _gets, _puts
extern precision, msg_input, msg_output, input_str

_readstr:   enter 0,0      ; # Le uma string e salva em um endereco | ([ebp+8]) = ptr que aponta para onde salvar a string
            pusha

            mov eax, 3
            mov ebx, 0
            mov ecx, [ebp+8]
            mov edx, 100
            int 80h

            ; coloca 0 no final da string
            mov byte [ecx + eax - 1], 0

            popa
            mov esp, ebp
            pop ebp
            ret 4
        
_printstr:  enter 0,0      ; # Mostra uma string | ([ebp+8]) = ptr que aponta para onde a string esta
            pusha

            push dword [ebp+8] ; string len
            call strlen

            mov edx, eax ; printa na tela
            mov eax, 4
            mov ebx, 1
            mov ecx, [ebp+8]
            int 80h

            popa
            mov esp, ebp
            pop ebp
            ret 4
_gets:
    cmp byte [precision], 1
    je gets32
    enter 0,0 ; # Mostra uma string | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str
    print msg_input
    push input_str
    call readw
    mov [ebp+10],ax

    print msg_input
    push input_str
    call readw
    mov [ebp+8],ax
    ;push ax

    leave
    ret
gets32:
    enter 0,0 ; # Mostra uma string | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str
    print msg_input
    push input_str
    call readdw
    mov [ebp+12],eax

    print msg_input
    push input_str
    call readdw
    mov [ebp+8],eax

    leave
    ret

_puts:
    enter 0,0
    print   msg_output

    cmp byte [precision], 1
    je puts32

    push word [ebp+8]
    push input_str
    call printw

    jmp puts_end

puts32:
    push dword [ebp+8]
    push input_str
    call printdw

puts_end:
    leave
    ret

_exit:      mov eax, 1
            mov ebx, 0
            int 80h

; ################################# Private Functions #################################

strlen:     enter 0,0      ; # calcula o tamanho de uma str | ([ebp+8]) = ptr que aponta para onde a string esta | EAX = tamanho
            push ebx

            sub eax, eax
            mov ebx, [ebp+8]

strlen_lp:  inc eax
            inc ebx
            cmp byte [ebx], 0
            jne strlen_lp
            
            pop ebx
            mov esp, ebp
            pop ebp
            ret 4

readw:     enter 0,0       ; # Mostra um int de 16bits | ([ebp+8]) = aponta para onde o numero será salvo
            push ebx
            push ecx
            push edx
            
            mov eax, 3
            mov ebx, 0
            mov ecx, [ebp+8]
            mov edx, 100
            int 80h
            
            ; coloca a quantidade de bytes lidos em esi
            mov esi, eax
            dec esi
            ; zera ax
            sub ax, ax
            ; coloca 10 em ebx
            mov bx, 10
            ; verifica se primeiro caractere eh um '-'
            cmp byte [ecx], '-'
            jne readw_for
            ; se for um '-', pula ele
            inc ecx
            dec esi
readw_for:  ; multiplica ax por 10
            mul bx
            
            ; coloca o ascii do caractere em dx
            movzx dx, byte [ecx]
            ; transforma dx em inteiro
            sub dx, 0x30
            ; soma dx a ax
            add ax, dx
            
            inc ecx
            dec esi
            ; se esi = 0, acaba o loop
            jnz readw_for

            ; se tiver - no comeco, inverte o resultado
            mov ecx, [ebp+8]
            cmp byte [ecx], '-'
            jne readw_end
            neg ax
readw_end: pop edx
            pop ecx
            pop ebx
            
            mov esp, ebp
            pop ebp
            ret 4

printw:    enter 0,0
            ; guarda os valores dos registradores utilizados na pilha
            push eax
            push ebx
            push ecx
            push edx

            ; empilha 0, que representa o final da string
            ; o desempilhamento eh do ultimo pro primeiro, por isso empilhamos o 0 primeiro
            push word 0
            
            mov ax, [ebp+12]
            mov cx, 10
            cmp ax, 0
            jge printw_cv_loop
            
            ; inverte o numero se ele for negativo (necessario para o resto nao ser negativo)
            neg ax
            ; loop que converte o inteiro para caracteres (adiciona cada caractere a pilha)
printw_cv_loop:
            ; extende o sinal de eax para edx
            cwd
            ; divide edx:eax por 10
            idiv cx
            ; converte o resto em caractere ascii
            add dx, 0x30
            ; coloca o caractere na pilha
            push dx
            ; se o quociente for 0, sai do loop
            cmp ax, 0
            jne printw_cv_loop

            cmp word [ebp+12], 0
            jge printw_gz
            ; adiciona o caractere '-' na pilha se o numero for negativo
            push word '-'
            ; coloca ponteiro da string auxiliar em ebx
printw_gz: mov ebx, [ebp+8]
            ; loop que constroe a string, desempilhando os caracteres
printw_sb_loop:
            ; desempilha o caractere
            pop ax
            ; coloca o caractere na posicao da string
            mov [ebx], al
            ; incrementa a posicao
            inc ebx
            ; se chegar no final da string, sair do loop
            cmp ax, 0
            jne printw_sb_loop

            ; chama printstr com o resultado
            push dword [ebp+8]
            call _printstr

            ; resgata os valores dos registradores utilizados da pilha
            pop edx
            pop ecx
            pop ebx
            pop eax
            mov esp, ebp
            pop ebp
            ret 6
readdw:     enter 0,0
            push ebx
            push ecx
            push edx
            
            mov eax, 3
            mov ebx, 0
            mov ecx, [ebp+8]
            mov edx, 100
            int 80h
            
            ; coloca a quantidade de bytes lidos em esi
            mov esi, eax
            dec esi
            ; zera eax
            sub eax, eax
            ; coloca 10 em ebx
            mov ebx, 10
            ; verifica se primeiro caractere eh um '-'
            cmp byte [ecx], '-'
            jne readdw_lp
            ; se for um '-', pula ele
            inc ecx
            dec esi
readdw_lp:  ; multiplica eax por 10
            mul ebx
            
            ; coloca o ascii do caractere em edx
            movzx edx, byte [ecx]
            ; transforma edx em inteiro
            sub edx, 0x30
            ; soma edx a eax
            add eax, edx
            
            inc ecx
            dec esi
            ; se esi = 0, acaba o loop
            jnz readdw_lp

            ; se tiver - no comeco, inverte o resultado
            mov ecx, [ebp+8]
            cmp byte [ecx], '-'
            jne readdw_end
            neg eax
readdw_end: pop edx
            pop ecx
            pop ebx
            
            mov esp, ebp
            pop ebp
            ret 4

printdw:    enter 0,0
            ; guarda os valores dos registradores utilizados na pilha
            push eax
            push ebx
            push ecx
            push edx

            ; empilha 0, que representa o final da string
            ; o desempilhamento eh do ultimo pro primeiro, por isso empilhamos o 0 primeiro
            push 0
            
            mov eax, [ebp+12]
            mov ecx, 10
            cmp eax, 0
            jge printdw_cv_loop
            
            ; inverte o numero se ele for negativo (necessario para o resto nao ser negativo)
            neg eax
            ; loop que converte o inteiro para caracteres (adiciona cada caractere a pilha)
printdw_cv_loop:
            ; extende o sinal de eax para edx
            cdq
            ; divide edx:eax por 10
            idiv ecx
            ; converte o resto em caractere ascii
            add edx, 0x30
            ; coloca o caractere na pilha
            push edx
            ; se o quociente for 0, sai do loop
            cmp eax, 0
            jne printdw_cv_loop

            cmp dword [ebp+12], 0
            jge printdw_gz
            ; adiciona o caractere '-' na pilha se o numero for negativo
            push '-'
            ; coloca ponteiro da string auxiliar em ebx
printdw_gz: mov ebx, [ebp+8]
            ; loop que constroe a string, desempilhando os caracteres
printdw_sb_loop:
            ; desempilha o caractere
            pop eax
            ; coloca o caractere na posicao da string
            mov [ebx], al
            ; incrementa a posicao
            inc ebx
            ; se chegar no final da string, sair do loop
            cmp eax, 0
            jne printdw_sb_loop

            ; chama printstr com o resultado
            push dword [ebp+8]
            call _printstr

            ; resgata os valores dos registradores utilizados da pilha
            pop edx
            pop ecx
            pop ebx
            pop eax
            mov esp, ebp
            pop ebp
            ret 8

