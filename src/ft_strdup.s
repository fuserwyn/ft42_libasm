section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_strdup
extern malloc
extern ft_strlen
extern ft_strcpy
ft_strdup:
    push    rdi
    call    ft_strlen
    inc     rax
    mov     rdi, rax
    call    malloc
    test    rax, rax
    je      .alloc_fail
    mov     rsi, [rsp]
    mov     rdi, rax
    call    ft_strcpy
    add     rsp, 8
    ret
.alloc_fail:
    add     rsp, 8
    ret
%else
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
%endif
