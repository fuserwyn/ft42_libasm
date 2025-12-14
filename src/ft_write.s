section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_write
extern __errno_location
ft_write:
%else
global _ft_write
extern ___error
_ft_write:
%endif
%ifidn __OUTPUT_FORMAT__,elf64
    mov     rax, 1
%else
    mov     rax, 0x2000004
%endif
    syscall
%ifidn __OUTPUT_FORMAT__,elf64
    cmp     rax, 0
    jl      .error
    ret
.error:
    neg     rax
    mov     rdx, rax
    call    __errno_location
    mov     [rax], edx
    mov     rax, -1
    ret
%else
    jnc     .done
    sub     rsp, 16
    mov     [rsp], rax
    call    ___error
    mov     rcx, [rsp]
    add     rsp, 16
    mov     [rax], ecx
    mov     rax, -1
    ret
.done:
    ret
%endif
