section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_list_size
ft_list_size:
%else
global _ft_list_size
_ft_list_size:
%endif
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

