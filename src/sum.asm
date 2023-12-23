section .text

extern precision; # Dados externos


global _sum

_sum:
    ; logica de precisão
    enter 2,0 ; # Mostra uma string | ([ebp+8]) = ptr para armazenar a str, ([ebp+10]) = ptr para armazenar a str

    mov eax,[ebp+10]
    add [ebp+8],eax

    leave
    ret 
