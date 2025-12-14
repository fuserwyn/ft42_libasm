section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_atoi_base
extern ft_strlen
ft_atoi_base:
%else
global _ft_atoi_base
extern _ft_strlen
_ft_atoi_base:
%endif
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbx
    
    mov     r12, rdi        ; str
    mov     r13, rsi        ; base
    
    ; Check if str is NULL
    test    r12, r12
    je      .invalid
    
    ; Check if base is NULL
    test    r13, r13
    je      .invalid
    
    ; Get base length
    mov     rdi, r13
%ifidn __OUTPUT_FORMAT__,elf64
    call    ft_strlen
%else
    call    _ft_strlen
%endif
    mov     r14, rax        ; base_len
    
    ; Check base validity: must be >= 2
    cmp     r14, 2
    jl      .invalid
    
    ; Check for duplicate characters and invalid chars in base
    xor     r15, r15        ; i = 0
.check_base_loop:
    cmp     r15, r14
    jge     .base_valid
    
    mov     al, [r13 + r15]
    
    ; Check for invalid characters: +, -, whitespace
    cmp     al, '+'
    je      .invalid
    cmp     al, '-'
    je      .invalid
    cmp     al, ' '
    jle     .invalid
    cmp     al, 127
    jge     .invalid
    
    ; Check for duplicates
    mov     rbx, r15
    inc     rbx             ; j = i + 1
.check_dup_loop:
    cmp     rbx, r14
    jge     .next_base_char
    cmp     al, [r13 + rbx]
    je      .invalid
    inc     rbx
    jmp     .check_dup_loop
    
.next_base_char:
    inc     r15
    jmp     .check_base_loop
    
.base_valid:
    ; Skip whitespace
.skip_whitespace:
    mov     al, [r12]
    cmp     al, ' '
    je      .skip_space
    cmp     al, 9
    je      .skip_space
    cmp     al, 10
    je      .skip_space
    cmp     al, 11
    je      .skip_space
    cmp     al, 12
    je      .skip_space
    cmp     al, 13
    je      .skip_space
    jmp     .check_sign
.skip_space:
    inc     r12
    jmp     .skip_whitespace
    
    ; Check sign
.check_sign:
    xor     r15, r15        ; sign = 0 (positive)
    mov     al, [r12]
    cmp     al, '-'
    je      .negative
    cmp     al, '+'
    je      .positive
    jmp     .convert
.negative:
    mov     r15, 1          ; sign = 1 (negative)
.positive:
    inc     r12
    
    ; Convert string to number
.convert:
    xor     rbx, rbx        ; result = 0
    
.convert_loop:
    movzx   rax, byte [r12]
    test    rax, rax
    je      .done_convert
    
    ; Find character in base
    xor     rdi, rdi        ; j = 0
.find_in_base:
    cmp     rdi, r14
    jge     .done_convert   ; character not in base
    cmp     al, [r13 + rdi]
    je      .found
    inc     rdi
    jmp     .find_in_base
    
.found:
    ; result = result * base_len + j
    mov     rax, rbx        ; rax = result
    mul     r14             ; rdx:rax = result * base_len
    add     rax, rdi        ; rax = result * base_len + j
    mov     rbx, rax        ; result = rax
    inc     r12
    jmp     .convert_loop
    
.done_convert:
    ; Apply sign
    mov     rax, rbx        ; rax = result
    test    r15, r15
    je      .positive_result
    neg     rax
.positive_result:
    jmp     .done
    
.invalid:
    xor     rax, rax
    
.done:
    pop     rbx
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    ret

