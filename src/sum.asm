section .text

extern precision; # Dados externos

global _sum

_sum:
    cmp byte [precision], 0
    je sum16
    jmp sum32

sum16:
    enter 0,0 ; # Soma dois inteiros 16 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str

    mov eax,[ebp+10]
    add [ebp+8],eax

    leave
    ret

sum32:
    enter 0,0 ; # Soma dois inteiros 32 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+12]) = ptr para armazenar a str

    mov eax,[ebp+12]
    add [ebp+8],eax

    leave
    ret
