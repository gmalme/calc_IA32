section .text

extern precision; # Dados externos

global _mul

_mul:
    cmp byte [precision], 0
    je mul16
    jmp mul32

mul16:
    enter 0,0 ; # Soma dois inteiros 16 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str

    mov ax,[ebp+10]
    mul word [ebp+8]
    mov [ebp+8],ax

    leave
    ret

mul32:
    enter 0,0 ; # oma dois inteiros 32 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+12]) = ptr para armazenar a str

    mov eax,[ebp+12]
    mul dword [ebp+8]
    mov [ebp+8],eax

    leave
    ret
