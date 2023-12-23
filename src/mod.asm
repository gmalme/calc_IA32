section .text

extern precision; # Dados externos

global _mod

_mod:
    cmp byte [precision], 0
    je mod16
    jmp mod32

mod16:
    enter 0,0 ; # Op. mod entre dois inteiros 16 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str

    mov ax,[ebp+10]
    idiv word [ebp+8]
    mov [ebp+8],dx

    leave
    ret

mod32:
    enter 0,0 ; # Op. mod entre dois inteiros 32 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+12]) = ptr para armazenar a str

    mov eax,[ebp+12]
    idiv dword [ebp+8]
    mov [ebp+8],edx

    leave
    ret
