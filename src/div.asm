section .text

extern precision; # Dados externos

global _div

_div:
    cmp byte [precision], 0
    je div16
    jmp div32

div16:
    enter 0,0 ; # Divide dois inteiros 16 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str

    mov ax,[ebp+10]
    div word [ebp+8]
    mov [ebp+8],ax

    leave
    ret

div32:
    enter 0,0 ; # Divide dois inteiros 32 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+12]) = ptr para armazenar a str

    mov eax,[ebp+12]
    div dword [ebp+8]
    mov [ebp+8],eax

    leave
    ret
