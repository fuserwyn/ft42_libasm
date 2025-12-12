section .text
global _ft_strdup
extern _malloc
extern _ft_strlen
extern _ft_strcpy

_ft_strdup:
    push    rdi
    call    _ft_strlen
    inc     rax
    mov     rdi, rax
    call    _malloc
    test    rax, rax
    je      .alloc_fail
    mov     rsi, [rsp]
    mov     rdi, rax
    call    _ft_strcpy
    add     rsp, 8
    ret
.alloc_fail:
    add     rsp, 8
    ret
