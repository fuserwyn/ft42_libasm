section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_strlen
ft_strlen:
%else
global _ft_strlen
_ft_strlen:
%endif
    xor     rax, rax
.loop:
    cmp     byte [rdi + rax], 0
    je      .done
    inc     rax
    jmp     .loop
.done:
    ret
