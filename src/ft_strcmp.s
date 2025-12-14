section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_strcmp
ft_strcmp:
%else
global _ft_strcmp
_ft_strcmp:
%endif
.loop:
    mov     al, [rdi]
    mov     dl, [rsi]
    cmp     al, dl
    jne     .diff
    test    al, al
    je      .equal
    inc     rdi
    inc     rsi
    jmp     .loop
.diff:
    movzx   eax, al
    movzx   edx, dl
    sub     eax, edx
    ret
.equal:
    xor     eax, eax
    ret
