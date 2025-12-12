section .text
global _ft_list_push_front
extern _malloc

_ft_list_push_front:
    push    r12
    push    r13
    
    mov     r12, rdi        ; begin_list
    mov     r13, rsi        ; data
    
    ; Check if begin_list is NULL
    test    r12, r12
    je      .done
    
    ; Allocate new node
    mov     rdi, 16         ; sizeof(t_list) = 16 (8 bytes for data + 8 for next)
    call    _malloc
    test    rax, rax
    je      .done
    
    ; Set data
    mov     [rax], r13      ; new->data = data
    
    ; Set next to current head
    mov     rcx, [r12]      ; *begin_list
    mov     [rax + 8], rcx  ; new->next = *begin_list
    
    ; Update head
    mov     [r12], rax      ; *begin_list = new
    
.done:
    pop     r13
    pop     r12
    ret

