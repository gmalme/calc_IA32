section .text

extern precision; # Dados externos

global _exp

_exp:
    cmp byte [precision], 0
    je exp16
    jmp exp32

exp16:
    enter 0,0 ; # Soma dois inteiros 16 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str

    mov cx,[ebp+8]
    mov ax,[ebp+10]
    dec cx

for16:
    mul word [ebp+10]
    loop for16
    mov [ebp+8],ax

    leave
    ret

exp32:
    enter 0,0 ; # oma dois inteiros 32 bits | ([ebp+8]) = ptr para armazenar a str, ([ebp+12]) = ptr para armazenar a str

    mov ecx,[ebp+8]
    mov eax,[ebp+12]
    dec ecx

for32:
    mul dword [ebp+12]
    loop for32
    mov [ebp+8],eax

    leave
    ret
