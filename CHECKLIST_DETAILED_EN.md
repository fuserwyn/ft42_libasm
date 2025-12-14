# Libasm - Detailed Checklist with Code Explanations for Defense

This document contains detailed explanations of each requirement with code examples for project defense.

---

## 📋 COMMON INSTRUCTIONS (Chapter II)

### ✅ 1. Functions don't crash unexpectedly

**What to show:**
- All functions are tested in `tests/main.c`
- No segmentation fault, bus error, double free

**How to demonstrate:**
```bash
make test
# All tests should pass without errors
```

**In code:**
- All functions check input parameters (e.g., NULL checks)
- Proper stack management (balanced push/pop)
- Correct memory handling

---

### ✅ 2. Makefile contains rules: $(NAME), all, clean, fclean, re

**What to show during defense:**

**1. $(NAME) = libasm.a**
```makefile
NAME        := libasm.a
```
- Library is named exactly `libasm.a`

**2. all rule:**
```makefile
all: $(NAME)

$(NAME): $(OBJ_DIR) $(OBJS)
	@rm -f $@
	$(AR) $(ARFLAGS) $@ $(OBJS)
```
- Builds mandatory functions
- Creates archive `libasm.a`

**3. clean rule:**
```makefile
clean:
	rm -rf $(OBJ_DIR)
```
- Removes `build/` directory with object files

**4. fclean rule:**
```makefile
fclean: clean
	rm -f $(NAME) $(TEST_BIN)
```
- Removes everything: object files, library, test binary

**5. re rule:**
```makefile
re: fclean all
```
- Rebuilds project from scratch

**How to demonstrate:**
```bash
make fclean  # Show clean state
make all     # Build mandatory functions
ls -la libasm.a  # Show created library
make clean   # Show removal of object files
```

---

### ✅ 3. bonus rule in Makefile

**What to show:**
```makefile
bonus: $(OBJ_DIR) $(OBJS) $(BONUS_OBJS)
	@rm -f $(NAME)
	$(AR) $(ARFLAGS) $(NAME) $(OBJS) $(BONUS_OBJS)
```
- Includes all mandatory and bonus object files
- Adds them to one library `libasm.a`

**How to demonstrate:**
```bash
make bonus
nm libasm.a | grep -E "(atoi|list)"  # Show bonus symbols
```

---

### ✅ 4. 64-bit assembly

**What to show:**
```makefile
ifeq ($(UNAME_S),Linux)
    NASMFLAGS   := -f elf64 -Wall -Werror
else
    NASMFLAGS   := -f macho64 -Wall -Werror -w-reloc-rel-dword
endif
```
- `-f elf64` for Linux - 64-bit ELF format
- `-f macho64` for macOS - 64-bit Mach-O format
- Both formats are 64-bit x86-64 architecture

**How to explain:**
- "We use 64-bit x86-64 architecture"
- "Object file format depends on platform: elf64 for Linux, macho64 for macOS"

---

### ✅ 5. Intel syntax (not AT&T)

**What to show in code:**

**Correct (Intel syntax):**
```assembly
mov     rax, rdi        ; dst, src
mov     [rdi], dl       ; [memory], register
cmp     byte [rdi + rax], 0
```

**Incorrect (AT&T syntax):**
```assembly
mov     %rdi, %rax      ; src, dst - NOT USED
mov     %dl, (%rdi)     ; register, (memory) - NOT USED
cmpb    $0, (%rdi,%rax) ; NOT USED
```

**How to explain:**
- "We use Intel syntax: destination first, then source"
- "In Intel syntax, square brackets mean pointer dereferencing"
- Show example: `mov rax, rdi` - copies rdi to rax

---

### ✅ 6. Compilation via nasm

**What to show:**
```makefile
NASM        := nasm
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $(INCLUDES) -o $@ $<
```
- Uses `nasm` compiler
- Compilation command: `nasm -f elf64/macho64 -Wall -Werror ...`

**How to demonstrate:**
```bash
nasm --version  # Show nasm version
make clean && make  # Show compilation process
```

---

### ✅ 7. Flag -no-pie not used

**Check:**
```bash
grep -i "no-pie" Makefile
# Should be empty - flag is absent
```

**How to explain:**
- "We don't use `-no-pie` flag, as it's forbidden by the assignment"
- Show that CFLAGS doesn't contain this flag

---

## 🔧 MANDATORY PART (Chapter III)

### ✅ 1. Library is named libasm.a

**Check:**
```bash
make bonus
ls -la libasm.a
file libasm.a
```
- File `libasm.a` must exist
- This is a static library (ar archive)

---

### ✅ 2. main function for testing

**File:** `tests/main.c`

**What to show:**
- File exists and contains `main()` function
- Tests all mandatory functions
- Compiles together with the library

**How to demonstrate:**
```bash
make test
# Shows work of all functions
```

---

### ✅ 3. ft_strlen (man 3 strlen)

**File:** `src/ft_strlen.s`

**Line-by-line code breakdown:**

```assembly
section .text           ; Code section
%ifidn __OUTPUT_FORMAT__,elf64
global ft_strlen        ; Export function for Linux (no underscore)
ft_strlen:
%else
global _ft_strlen       ; Export function for macOS (with underscore)
_ft_strlen:
%endif
    xor     rax, rax    ; Zero counter (rax = 0) - faster than mov rax, 0
.loop:
    cmp     byte [rdi + rax], 0  ; Compare byte at address rdi+rax with zero
    je      .done       ; If equal (end of string), jump to .done
    inc     rax         ; Increment counter
    jmp     .loop       ; Jump to start of loop
.done:
    ret                 ; Return (length already in rax)
```

**What to explain:**
1. **Calling convention:** `rdi` - first argument (pointer to string), `rax` - return value
2. **Optimization:** `xor rax, rax` is shorter and faster than `mov rax, 0`
3. **Memory access:** `byte [rdi + rax]` - access byte at address (rdi + rax)
4. **Conditional compilation:** Different function names for Linux/macOS

**How to demonstrate:**
```c
printf("ft_strlen(\"Hello\") = %zu\n", ft_strlen("Hello"));  // 5
printf("ft_strlen(\"\") = %zu\n", ft_strlen(""));            // 0
```

---

### ✅ 4. ft_strcpy (man 3 strcpy)

**File:** `src/ft_strcpy.s`

**Line-by-line code breakdown:**

```assembly
section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_strcpy
ft_strcpy:
%else
global _ft_strcpy
_ft_strcpy:
%endif
    mov     rax, rdi    ; Save pointer to dst for return
.copy:
    mov     dl, [rsi]   ; Load byte from src into dl
    mov     [rdi], dl   ; Copy byte to dst
    inc     rsi         ; Move to next byte in src
    inc     rdi         ; Move to next byte in dst
    test    dl, dl      ; Check if byte equals zero (test performs AND)
    jne     .copy       ; If not zero, continue copying
    ret                 ; Return pointer to dst (in rax)
```

**What to explain:**
1. **Arguments:** `rdi` = dst (where to copy), `rsi` = src (from where to copy)
2. **Return:** Save `rdi` in `rax` at start to return pointer to dst
3. **Optimization:** `test dl, dl` is faster than `cmp dl, 0` (doesn't save result)
4. **Terminating null:** Copied automatically, as check happens after copy

**How to demonstrate:**
```c
char dst[100];
ft_strcpy(dst, "Hello");
printf("Copied: %s\n", dst);  // "Hello"
```

---

### ✅ 5. ft_strcmp (man 3 strcmp)

**File:** `src/ft_strcmp.s`

**Line-by-line code breakdown:**

```assembly
section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_strcmp
ft_strcmp:
%else
global _ft_strcmp
_ft_strcmp:
%endif
.loop:
    mov     al, [rdi]   ; Load byte from s1 into al
    mov     dl, [rsi]   ; Load byte from s2 into dl
    cmp     al, dl      ; Compare bytes
    jne     .diff       ; If not equal, jump to .diff
    test    al, al      ; Check if end of string (al == 0)
    je      .equal      ; If end of string, strings are equal
    inc     rdi         ; Move to next character in s1
    inc     rsi         ; Move to next character in s2
    jmp     .loop       ; Continue comparison
.diff:
    movzx   eax, al     ; Zero-extend al to eax
    movzx   edx, dl     ; Zero-extend dl to edx
    sub     eax, edx    ; Calculate difference: s1[i] - s2[i]
    ret                 ; Return difference
.equal:
    xor     eax, eax    ; Zero eax (strings are equal)
    ret                 ; Return 0
```

**What to explain:**
1. **Logic:** Compare bytes one by one until first difference or end of string
2. **Return:** Difference between characters (not just -1/0/1), like standard strcmp
3. **movzx:** Zero-extends byte to 32 bits (needed for correct subtraction)
4. **test al, al:** Check for end of string (null byte)

**How to demonstrate:**
```c
printf("ft_strcmp(\"abc\", \"abc\") = %d\n", ft_strcmp("abc", "abc"));  // 0
printf("ft_strcmp(\"abc\", \"abd\") = %d\n", ft_strcmp("abc", "abd"));  // < 0
printf("ft_strcmp(\"abd\", \"abc\") = %d\n", ft_strcmp("abd", "abc"));  // > 0
```

---

### ✅ 6. ft_write (man 2 write)

**File:** `src/ft_write.s`

**Code breakdown for Linux:**

```assembly
section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_write
extern __errno_location
ft_write:
    mov     rax, 1      ; System call number for write (Linux)
    syscall             ; Invoke system call
    cmp     rax, 0      ; Check return value
    jl      .error      ; If less than 0, error occurred
    ret                 ; Return number of bytes written
.error:
    neg     rax         ; Make error positive (rax was negative)
    mov     rdx, rax    ; Save error code in rdx
    call    __errno_location  ; Get pointer to errno
    mov     [rax], edx  ; Set errno
    mov     rax, -1     ; Return -1
    ret
```

**Code breakdown for macOS:**

```assembly
%else
global _ft_write
extern ___error
_ft_write:
    mov     rax, 0x2000004  ; System call number for write (macOS with offset)
    syscall                 ; Invoke system call
    jnc     .done          ; If no carry (CF=0), success
    sub     rsp, 16        ; Align stack to 16 bytes
    mov     [rsp], rax     ; Save error code
    call    ___error       ; Get pointer to errno
    mov     rcx, [rsp]     ; Restore error code
    add     rsp, 16        ; Restore stack
    mov     [rax], ecx     ; Set errno
    mov     rax, -1        ; Return -1
    ret
.done:
    ret
%endif
```

**What to explain:**
1. **System call:** Number goes in `rax`, arguments in `rdi`, `rsi`, `rdx`
2. **Platform differences:**
   - Linux: direct number `1`, error determined by negative return
   - macOS: number with offset `0x2000004`, error determined by carry flag (CF)
3. **errno handling:**
   - Linux: `__errno_location()` returns pointer to errno
   - macOS: `___error()` returns pointer to errno
4. **Stack alignment:** On macOS, stack must be aligned before function call

**How to demonstrate:**
```c
ssize_t ret = ft_write(1, "Hello\n", 6);  // Write to stdout
printf("ft_write returned: %zd\n", ret);  // 6
```

---

### ✅ 7. ft_read (man 2 read)

**File:** `src/ft_read.s`

**Logic similar to ft_write, but:**
- Linux: system call number `0` (SYS_read)
- macOS: system call number `0x2000003` (SYS_read)

**What to explain:**
1. **Reading:** Same arguments: `rdi` = fd, `rsi` = buf, `rdx` = count
2. **Return:** Number of bytes read (may be less than count)
3. **Errors:** Handled same way as ft_write

**How to demonstrate:**
```c
char buf[10] = {0};
ssize_t ret = ft_read(0, buf, 10);  // Read from stdin
printf("Read %zd bytes\n", ret);
```

---

### ✅ 8. ft_strdup (man 3 strdup)

**File:** `src/ft_strdup.s`

**Code breakdown:**

```assembly
section .text
%ifidn __OUTPUT_FORMAT__,elf64
global ft_strdup
extern malloc
extern ft_strlen
extern ft_strcpy
ft_strdup:
    push    rdi         ; Save original pointer on stack (rdi will be modified)
    call    ft_strlen   ; Call ft_strlen - result in rax (length)
    inc     rax         ; Increment by 1 for null byte
    mov     rdi, rax    ; Pass size to rdi for malloc
    call    malloc      ; Allocate memory - pointer in rax
    test    rax, rax    ; Check if malloc returned NULL
    je      .alloc_fail ; If NULL, jump to error handling
    mov     rsi, [rsp]  ; Restore original pointer from stack to rsi
    mov     rdi, rax    ; Pass pointer to allocated memory to rdi
    call    ft_strcpy   ; Copy string - rax already contains pointer to new memory
    add     rsp, 8      ; Free stack space
    ret                 ; Return pointer to new string
.alloc_fail:
    add     rsp, 8      ; Free stack space
    ret                 ; Return NULL (rax already contains NULL)
%endif
```

**What to explain:**
1. **Saving argument:** `push rdi` - save original string, as `ft_strlen` modifies `rdi`
2. **Memory allocation:** `malloc(strlen(s) + 1)` - +1 for null byte
3. **Error check:** `test rax, rax` - check that malloc didn't return NULL
4. **Restoring argument:** `mov rsi, [rsp]` - restore original pointer for copying
5. **Stack balancing:** Important to free stack (`add rsp, 8`) even on error

**How to demonstrate:**
```c
char *dup = ft_strdup("Hello");
printf("ft_strdup(\"Hello\") = \"%s\"\n", dup);  // "Hello"
free(dup);  // Don't forget to free memory
```

---

## 🎁 BONUS PART (Chapter IV)

### ✅ 1. t_list structure

**File:** `include/libasm.h`

```c
typedef struct s_list
{
    void            *data;
    struct s_list   *next;
}   t_list;
```

**What to explain:**
- Structure matches assignment
- `data` - pointer to data (8 bytes on 64-bit)
- `next` - pointer to next element (8 bytes on 64-bit)
- Structure size: 16 bytes

---

### ✅ 2. ft_atoi_base

**File:** `src/bonus/ft_atoi_base_bonus.s`

**Main logic:**

```assembly
; 1. Check input parameters (NULL, base >= 2)
; 2. Validate base (duplicates, invalid characters)
; 3. Skip whitespace
; 4. Handle sign (+ or -)
; 5. Convert string to number in specified base
```

**What to explain:**
1. **Base validation:** Check for empty, duplicate characters, presence of +/-
2. **Whitespace skipping:** Skip whitespace at start of string
3. **Sign:** Handle + and - before number
4. **Conversion:** Find each character in base and calculate number using formula: `result = result * base_len + digit_index`

**How to demonstrate:**
```c
printf("ft_atoi_base(\"1010\", \"01\") = %d\n", ft_atoi_base("1010", "01"));  // 10 (binary)
printf("ft_atoi_base(\"FF\", \"0123456789ABCDEF\") = %d\n", ft_atoi_base("FF", "0123456789ABCDEF"));  // 255 (hex)
```

---

### ✅ 3. ft_list_push_front

**File:** `src/bonus/ft_list_push_front_bonus.s`

**Code breakdown:**

```assembly
ft_list_push_front:
    push    r12         ; Save r12 (callee-saved register)
    push    r13         ; Save r13
    mov     r12, rdi    ; Save begin_list (double pointer)
    mov     r13, rsi    ; Save data
    
    ; NULL check
    test    r12, r12
    je      .done
    
    ; Memory allocation
    mov     rdi, 16     ; Size of t_list = 16 bytes
    call    malloc      ; Allocate memory for new node
    test    rax, rax    ; Check for NULL
    je      .done       ; If NULL, exit
    
    ; Initialize new node
    mov     [rax], r13      ; new->data = data (at offset 0)
    mov     rcx, [r12]      ; Load current head of list
    mov     [rax + 8], rcx  ; new->next = *begin_list (at offset 8)
    
    ; Update list head
    mov     [r12], rax      ; *begin_list = new
    
.done:
    pop     r13         ; Restore registers
    pop     r12
    ret
```

**What to explain:**
1. **Double pointer:** `**begin_list` needed to modify pointer to start of list
2. **Memory allocation:** `malloc(16)` - size of t_list structure
3. **Memory structure:** `[rax]` = data (offset 0), `[rax + 8]` = next (offset 8)
4. **Register preservation:** `r12-r15` must be preserved (callee-saved)

**How to demonstrate:**
```c
t_list *list = NULL;
ft_list_push_front(&list, "first");
ft_list_push_front(&list, "second");
// List: "second" -> "first" -> NULL
```

---

### ✅ 4. ft_list_size

**File:** `src/bonus/ft_list_size_bonus.s`

**Code breakdown:**

```assembly
ft_list_size:
    xor     rax, rax    ; count = 0
    test    rdi, rdi    ; Check if list is NULL
    je      .done       ; If NULL, return 0
    
.loop:
    test    rdi, rdi    ; Check current node
    je      .done       ; If NULL, exit loop
    inc     rax         ; Increment counter
    mov     rdi, [rdi + 8]  ; Move to next node: current = current->next
    jmp     .loop       ; Continue loop
    
.done:
    ret                 ; Return size in rax
```

**What to explain:**
1. **Simple algorithm:** Iterate through list, counting elements
2. **Offset:** `[rdi + 8]` - access to `next` field of structure
3. **Complexity:** O(n) - linear time complexity

**How to demonstrate:**
```c
t_list *list = NULL;
ft_list_push_front(&list, "third");
ft_list_push_front(&list, "second");
ft_list_push_front(&list, "first");
printf("Size: %d\n", ft_list_size(list));  // 3
```

---

### ✅ 5. ft_list_sort

**File:** `src/bonus/ft_list_sort_bonus.s`

**Algorithm:** Bubble sort

**Key points:**

```assembly
ft_list_sort:
    mov     r13, rsi    ; Save comparison function pointer in r13 (callee-saved)
    
.outer_loop:            ; Outer loop
    mov     r8, rdi     ; current = *begin_list
    mov     r9, 0       ; swapped = 0 (swap flag)
    
.inner_loop:            ; Inner loop
    mov     r10, [r8 + 8]   ; next = current->next
    
    ; Save registers before calling cmp
    push    rdi
    push    r8
    push    r13
    mov     rdi, [r8]       ; rdi = current->data
    mov     rsi, [r10]      ; rsi = next->data
    call    r13             ; Call cmp(current->data, next->data)
    pop     r13             ; Restore registers
    pop     r8
    pop     rdi
    
    test    eax, eax    ; Check comparison result
    jle     .no_swap    ; If <= 0, don't swap
    
    ; Swap data (not nodes!)
    mov     r11, [r8]       ; temp = current->data
    mov     r12, [r10]      ; temp2 = next->data
    mov     [r8], r12       ; current->data = next->data
    mov     [r10], r11      ; next->data = temp
    mov     r9, 1           ; swapped = 1
    
.no_swap:
    mov     r8, [r8 + 8]    ; current = current->next
    jmp     .inner_loop
    
.check_swap:
    test    r9, r9          ; If swapped == 0, list is sorted
    je      .done
    jmp     .outer_loop     ; Otherwise do another pass
```

**What to explain:**
1. **Saving function pointer:** `r13` - callee-saved register, perfect for storing function pointer
2. **Sorting data, not nodes:** Only swap `data`, node structure remains unchanged
3. **Save/restore registers:** Before calling `cmp`, save all used registers
4. **Optimization:** `swapped` flag allows early exit if list is already sorted

**How to demonstrate:**
```c
t_list *list = NULL;
ft_list_push_front(&list, "zebra");
ft_list_push_front(&list, "apple");
ft_list_push_front(&list, "banana");
ft_list_sort(&list, cmp_str);
// After sort: "apple" -> "banana" -> "zebra"
```

---

### ✅ 6. ft_list_remove_if

**File:** `src/bonus/ft_list_remove_if_bonus.s`

**Algorithm:**
1. Remove elements from start of list
2. Remove elements from middle/end of list

**Key points:**

```assembly
ft_list_remove_if:
    ; Save arguments in callee-saved registers
    mov     r12, rdi    ; begin_list
    mov     r13, rsi    ; data_ref
    mov     r14, rdx    ; cmp function
    mov     r15, rcx    ; free_fct function
    
    ; Removal from start
.remove_head_loop:
    mov     rbx, [r12]      ; current = *begin_list
    ; ... call cmp ...
    ; If matches, remove:
    mov     rcx, [rbx + 8]  ; next = current->next
    mov     [r12], rcx      ; *begin_list = next
    ; Free data and node
    call    r15             ; free_fct(current->data)
    call    free            ; free(current node)
    
    ; Removal from middle/end
.remove_middle:
    mov     rbx, [r12]      ; prev = *begin_list
.middle_loop:
    mov     rcx, [rbx + 8]  ; current = prev->next
    ; ... call cmp ...
    ; If matches, remove:
    mov     rdx, [rcx + 8]  ; next = current->next
    mov     [rbx + 8], rdx  ; prev->next = next
    ; Free data and node
    call    r15             ; free_fct(current->data)
    call    free            ; free(current node)
```

**What to explain:**
1. **Two stages:** First remove from start (changes `*begin_list`), then from middle
2. **Pointer updates:** Important to correctly link `prev->next` to `next` before removal
3. **Memory freeing:** First `free_fct(data)`, then `free(node)`
4. **Register preservation:** All 4 arguments saved in `r12-r15`

**How to demonstrate:**
```c
t_list *list = NULL;
ft_list_push_front(&list, "keep3");
ft_list_push_front(&list, "remove");
ft_list_push_front(&list, "keep2");
ft_list_push_front(&list, "remove");
ft_list_push_front(&list, "keep1");
ft_list_remove_if(&list, "remove", cmp_str, free_str);
// After removal: "keep1" -> "keep2" -> "keep3" -> NULL
```

---

## 📊 x86-64 CALLING CONVENTION

### What to explain:

1. **Argument passing:**
   - First 6 arguments passed in registers: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`
   - Remaining arguments passed via stack

2. **Return value:**
   - Integers and pointers returned in `rax`
   - Large structures returned via pointer

3. **Callee-saved registers:**
   - `rbx`, `rbp`, `r12`, `r13`, `r14`, `r15` must be preserved by function
   - If used, do `push` at start, `pop` at end

4. **Caller-saved registers:**
   - Other registers may be modified by function
   - Calling function must save them if needed

5. **Stack alignment:**
   - Stack must be aligned to 16 bytes before function calls

**Examples:**
```assembly
; Function receives arguments:
; rdi = first argument
; rsi = second argument
; rdx = third argument

; If need to use r12:
push    r12         ; Save at start
; ... use r12 ...
pop     r12         ; Restore at end
```

---

## 🎯 FINAL RECOMMENDATIONS FOR DEFENSE

### Demonstration order:

1. **Show project structure:**
   ```bash
   ls -R
   tree  # if installed
   ```

2. **Show Makefile:**
   ```bash
   cat Makefile
   ```

3. **Clean build:**
   ```bash
   make fclean
   make bonus
   ls -la libasm.a
   ```

4. **Run tests:**
   ```bash
   make test
   ```

5. **Show function code:**
   - Open `.s` file
   - Explain line by line
   - Show register usage

6. **Explain calling convention:**
   - Which registers for arguments
   - How return value works
   - Register preservation

7. **Show error handling:**
   - Especially for `ft_write` and `ft_read`
   - Differences between Linux and macOS

### Typical questions and answers:

**Q: Why use `xor rax, rax` instead of `mov rax, 0`?**
A: This is an optimization - command is shorter (2 bytes vs 7 bytes) and executes faster.

**Q: Why save `rdi` in `ft_strdup`?**
A: Because `ft_strlen` uses `rdi` as argument and may modify it. Need to save original value for later use in `ft_strcpy`.

**Q: What's the difference between Linux and macOS?**
A: Main differences:
- Object file format: elf64 vs macho64
- System call numbers: direct vs with offset 0x2000000
- Function names: without underscore vs with underscore
- Error handling: check negative value vs carry flag

**Q: Why does `ft_list_sort` sort data, not nodes?**
A: It's more efficient - don't need to change links between nodes, just swap data pointers. Faster and simpler to implement.

---

**Good luck with your defense! 🚀**

