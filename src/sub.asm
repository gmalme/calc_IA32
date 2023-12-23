section .text

extern precision; # Dados externos

global _sub

_sub:
    cmp byte [precision], 0
    je sub16
    jmp sub32

sub16:
    enter 0,0 ; # Soma dois inteiros 16 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str

    mov eax,[ebp+10]
    sub eax,[ebp+8]
    mov [ebp+8],eax

    leave
    ret

sub32:
    enter 0,0 ; # oma dois inteiros 32 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+12]) = ptr para armazenar a str

    mov eax,[ebp+12]
    sub eax,[ebp+8]
    mov [ebp+8],eax

    leave
    ret
