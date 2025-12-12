section .text
global _ft_list_size

_ft_list_size:
    xor     rax, rax        ; count = 0
    test    rdi, rdi        ; check if begin_list is NULL
    je      .done
    
.loop:
    test    rdi, rdi        ; check if current node is NULL
    je      .done
    inc     rax             ; count++
    mov     rdi, [rdi + 8]  ; current = current->next
    jmp     .loop
    
.done:
    ret

