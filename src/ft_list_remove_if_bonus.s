section .text
global _ft_list_remove_if
extern _free

_ft_list_remove_if:
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbx
    
    mov     r12, rdi        ; begin_list
    mov     r13, rsi        ; data_ref
    mov     r14, rdx        ; cmp function
    mov     r15, rcx        ; free_fct function
    
    ; Check if begin_list is NULL
    test    r12, r12
    je      .done
    
    ; Remove from beginning while needed
.remove_head_loop:
    mov     rbx, [r12]      ; current = *begin_list
    test    rbx, rbx
    je      .done
    
    ; Call cmp(current->data, data_ref)
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbx
    mov     rdi, [rbx]      ; current->data
    mov     rsi, r13        ; data_ref
    call    r14             ; cmp(current->data, data_ref)
    pop     rbx
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    
    ; If cmp != 0, stop removing from head
    test    eax, eax
    jne     .remove_middle
    
    ; Remove head node
    mov     rbx, [r12]      ; current = *begin_list
    mov     rcx, [rbx + 8]  ; next = current->next
    mov     [r12], rcx      ; *begin_list = next
    
    ; Free data
    push    r12
    push    r13
    push    r14
    push    r15
    mov     rdi, [rbx]      ; current->data
    call    r15             ; free_fct(current->data)
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    
    ; Free node
    push    r12
    push    r13
    push    r14
    push    r15
    mov     rdi, rbx        ; current node
    call    _free
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    
    jmp     .remove_head_loop
    
    ; Remove from middle/end
.remove_middle:
    mov     rbx, [r12]      ; prev = *begin_list
    test    rbx, rbx
    je      .done
    
.middle_loop:
    mov     rcx, [rbx + 8]  ; current = prev->next
    test    rcx, rcx
    je      .done
    
    ; Call cmp(current->data, data_ref)
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbx
    push    rcx
    mov     rdi, [rcx]      ; current->data
    mov     rsi, r13        ; data_ref
    call    r14             ; cmp(current->data, data_ref)
    pop     rcx
    pop     rbx
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    
    ; If cmp != 0, move to next
    test    eax, eax
    jne     .next_node
    
    ; Remove current node
    mov     rdx, [rcx + 8]  ; next = current->next
    mov     [rbx + 8], rdx  ; prev->next = next
    
    ; Free data
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbx
    mov     rdi, [rcx]      ; current->data
    call    r15             ; free_fct(current->data)
    pop     rbx
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    
    ; Free node
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbx
    mov     rdi, rcx        ; current node
    call    _free
    pop     rbx
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    
    ; Don't advance prev, check next node
    jmp     .middle_loop
    
.next_node:
    mov     rbx, rcx        ; prev = current
    jmp     .middle_loop
    
.done:
    pop     rbx
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    ret

