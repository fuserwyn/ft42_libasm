section .text
global _ft_write
extern ___error

_ft_write:
    mov     rax, 0x2000004
    syscall
    jnc     done
    sub     rsp, 16
    mov     [rsp], rax
    call    ___error
    mov     rcx, [rsp]
    add     rsp, 16
    mov     [rax], ecx
    mov     rax, -1
    ret
done:
    ret
