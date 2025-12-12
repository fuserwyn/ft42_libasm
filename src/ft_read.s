section .text
global _ft_read
extern ___error

_ft_read:
    mov     rax, 0x2000003
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
