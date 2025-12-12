section .text
global _ft_strcpy

_ft_strcpy:
    mov     rax, rdi
.copy:
    mov     dl, [rsi]
    mov     [rdi], dl
    inc     rsi
    inc     rdi
    test    dl, dl
    jne     .copy
    ret
