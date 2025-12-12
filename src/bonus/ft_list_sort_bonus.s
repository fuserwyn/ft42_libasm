section .text
global _ft_list_sort

; ft_list_sort(t_list **begin_list, int (*cmp)())
; rdi = begin_list (pointer to pointer)
; rsi = cmp function pointer
_ft_list_sort:
    test    rdi, rdi        ; check if begin_list is NULL
    je      .done
    test    rsi, rsi        ; check if cmp is NULL
    je      .done
    mov     r13, rsi        ; save cmp function pointer in r13
    mov     rdi, [rdi]      ; rdi = *begin_list
    test    rdi, rdi        ; check if list is empty
    je      .done
    
    ; Simple bubble sort implementation
    ; Outer loop
.outer_loop:
    mov     r8, rdi         ; r8 = current node
    mov     r9, 0           ; swapped = 0
    
.inner_loop:
    mov     r10, [r8 + 8]   ; r10 = current->next
    test    r10, r10        ; check if next is NULL
    je      .check_swap
    
    ; Save registers (ABI: rbx, rbp, r12-r15 must be preserved)
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r13
    
    ; Call cmp(current->data, next->data)
    mov     rdi, [r8]       ; rdi = current->data
    mov     rsi, [r10]      ; rsi = next->data
    call    r13             ; call cmp(current->data, next->data)
    
    ; Restore registers
    pop     r13
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    
    ; If cmp > 0, swap nodes
    test    eax, eax
    jle     .no_swap
    
    ; Swap data pointers
    mov     r11, [r8]       ; temp = current->data
    mov     r12, [r10]      ; temp2 = next->data
    mov     [r8], r12       ; current->data = next->data
    mov     [r10], r11      ; next->data = temp
    mov     r9, 1           ; swapped = 1
    
.no_swap:
    mov     r8, [r8 + 8]    ; current = current->next
    jmp     .inner_loop
    
.check_swap:
    test    r9, r9          ; if swapped == 0, we're done
    je      .done
    jmp     .outer_loop     ; else, do another pass
    
.done:
    ret

