; ################################# I/O #################################
section .text
; Macros utilizadas para facilitar a compreensao do codigo 
; (mesmo nao estando na especificacao do trabalho optamos por utilizar para facilitar o processo de desenvolvimento)
%macro  print 1
        push %1
        call _printstr
%endmacro

%macro  read 1
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
_gets:                      ; # Mostra uma string | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str
            cmp byte [precision], 1
            je gets32
            enter 0,0 
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

gets32:     enter 0,0 ; # Mostra uma string | ([ebp+8]) = ptr para armazenar a str, ([ebp+12]) = ptr para armazenar a str
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

_puts:                  ; # Mostra uma string | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str
            enter 0,0
            print   msg_output

            cmp byte [precision], 1
            je puts32

            push word [ebp+8]
            push input_str
            call printw

            jmp puts_end

puts32:             ; # Mostra uma string | ([ebp+8]) = ptr para armazenar a str, ([ebp+12]) = ptr para armazenar a str
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

readw:      enter 0,0       ; # Mostra um int de 16bits | ([ebp+8]) = aponta para onde o numero será salvo
            push ebx
            push ecx
            push edx
            
            mov eax, 3
            mov ebx, 0
            mov ecx, [ebp+8]
            mov edx, 100
            int 80h
            
            mov esi, eax ; coloca a quantidade de bytes lidos em esi
            dec esi
            sub ax, ax
            mov bx, 10

            
            cmp byte [ecx], '-' ; verifica se primeiro caractere eh um '-'
            jne readw_for
            inc ecx
            dec esi

readw_for:  mul bx          ; # converte caracteres p/ valor numérico de 16 bits 
            movzx dx, byte [ecx]
            sub dx, 0x30
            add ax, dx
            inc ecx
            dec esi
            jnz readw_for

            mov ecx, [ebp+8] 
            cmp byte [ecx], '-' ; se for - inverte o sinal
            jne readw_end
            neg ax

readw_end:  pop edx
            pop ecx
            pop ebx
            
            mov esp, ebp
            pop ebp
            ret 4

printw:     enter 0,0         ; # printa uma word | ([ebp+12]) = ptr que aponta para onde a string esta
            push eax
            push ebx
            push ecx
            push edx

            push word 0 ; empilha 0
            
            mov ax, [ebp+12]
            mov cx, 10
            cmp ax, 0
            jge printw_cv_loop
            
            neg ax ; inverte o numero se ele for negativo

printw_cv_loop:               ; # loop que converte o inteiro para caracteres
            cwd
            idiv cx
            add dx, 0x30
            push dx ; coloca o caractere na pilha
            cmp ax, 0
            jne printw_cv_loop

            cmp word [ebp+12], 0 ; coloca ponteiro da string auxiliar em ebx
            jge printw_gz
            push word '-'
printw_gz: mov ebx, [ebp+8]

printw_sb_loop:  ; # desempilha os caracteres
            pop ax
            mov [ebx], al
            inc ebx
            cmp ax, 0
            jne printw_sb_loop

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

readdw:     enter 0,0       ; # Le uma word | ([ebp+8]) = ptr que aponta para onde a string esta
            push ebx
            push ecx
            push edx
            
            mov eax, 3
            mov ebx, 0
            mov ecx, [ebp+8]
            mov edx, 100
            int 80h
            
            mov esi, eax
            dec esi
            sub eax, eax
            mov ebx, 10

            cmp byte [ecx], '-' ; verifica se primeiro caractere eh um '-'
            jne readdw_lp
            inc ecx
            dec esi

readdw_lp:  mul ebx ; multiplica eax por 10
            movzx edx, byte [ecx]
            sub edx, 0x30
            add eax, edx
            
            inc ecx
            dec esi
            jnz readdw_lp

            mov ecx, [ebp+8] ; se for - inverte o resultado
            cmp byte [ecx], '-'
            jne readdw_end
            neg eax

readdw_end: pop edx
            pop ecx
            pop ebx
            
            mov esp, ebp
            pop ebp
            ret 4

printdw:    enter 0,0       ; # printa uma double word | ([ebp+12]) = ptr que aponta para onde a string esta
            push eax
            push ebx
            push ecx
            push edx

            push 0 ; empilha 0, que representa o final da string
            
            mov eax, [ebp+12]
            mov ecx, 10
            cmp eax, 0
            jge printdw_cv_loop
            neg eax  ;inverte o numero se ele for negativo

printdw_cv_loop:             ; converte o inteiro para caracteres e adiciona na pilha
            cdq
            idiv ecx
            add edx, 0x30
            push edx ; coloca o caractere na pilha

            cmp eax, 0
            jne printdw_cv_loop

            cmp dword [ebp+12], 0 ; adiciona o caractere '-' na pilha se o numero for negativo
            jge printdw_gz
            push '-'

printdw_gz: mov ebx, [ebp+8]

printdw_sb_loop: ; loop que constroe a string, desempilhando os caracteres
            pop eax
            mov [ebx], al
            inc ebx
            cmp eax, 0
            jne printdw_sb_loop

            push dword [ebp+8]
            call _printstr

            pop edx
            pop ecx
            pop ebx
            pop eax
            mov esp, ebp
            pop ebp
            ret 8


