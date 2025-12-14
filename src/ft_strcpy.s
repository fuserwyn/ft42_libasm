section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_strcpy
ft_strcpy:
%else
global _ft_strcpy
_ft_strcpy:
%endif
    mov     rax, rdi
.copy:
    mov     dl, [rsi]
    mov     [rdi], dl
    inc     rsi
    inc     rdi
    test    dl, dl
    jne     .copy
    ret
