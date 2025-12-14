# Libasm - Defense Guide

## 📋 Table of Contents
1. [General Information](#general-information)
2. [Preparation for Defense](#preparation-for-defense)
3. [Mandatory Functions](#mandatory-functions)
4. [Bonus Functions](#bonus-functions)
5. [Typical Defense Questions](#typical-defense-questions)
6. [Demonstration](#demonstration)
7. [Common Mistakes](#common-mistakes)
8. [Useful Commands](#useful-commands)

---

## General Information

**Libasm** is a project where you implement standard C library functions in x86-64 assembly language (NASM).

### Project Structure
```
ft42_libasm/
├── include/
│   └── libasm.h          # Header file with function prototypes
├── src/
│   ├── ft_strlen.s       # Mandatory functions
│   ├── ft_strcpy.s
│   ├── ft_strcmp.s
│   ├── ft_write.s
│   ├── ft_read.s
│   ├── ft_strdup.s
│   └── bonus/            # Bonus functions
│       ├── ft_atoi_base_bonus.s
│       ├── ft_list_push_front_bonus.s
│       ├── ft_list_size_bonus.s
│       ├── ft_list_sort_bonus.s
│       └── ft_list_remove_if_bonus.s
├── tests/
│   └── main.c            # Test file
├── Makefile
└── README.md
```

### Build Commands
```bash
make          # Build mandatory functions
make bonus    # Build all functions (mandatory + bonus)
make test     # Build and run tests
make clean    # Remove object files
make fclean   # Remove all built files
make re       # Rebuild project
```

### Platform Compatibility

This project supports both **macOS** and **Linux (Ubuntu)** platforms:
- **macOS**: Uses `macho64` format, system calls with offset `0x2000000`, function names with underscore prefix
- **Linux**: Uses `elf64` format, direct system call numbers, function names without underscore prefix
- The Makefile automatically detects the platform and uses appropriate compilation flags
- All source files use conditional compilation (`%ifidn __OUTPUT_FORMAT__,elf64`) to support both platforms

---

## Preparation for Defense

### ✅ Pre-Defense Checklist

1. **Clean Build Test**
   ```bash
   make fclean
   make bonus
   ```
   - Ensure the project compiles without errors or warnings
   - Verify `libasm.a` is created successfully
   - Check that all object files are in `build/` directory

2. **Run Tests**
   ```bash
   make test
   ```
   - All tests should pass successfully
   - Test both mandatory and bonus functions
   - Verify edge cases (NULL, empty strings, etc.)

3. **Cross-Platform Test (if possible)**
   ```bash
   # Test on macOS
   make fclean && make bonus && make test
   
   # Test on Linux (Ubuntu)
   make fclean && make bonus && make test
   ```

4. **Norm Check**
   - Ensure all files comply with 42 norm
   - Check formatting and comments
   - Verify no `.o` files are in repository (check `.gitignore`)

5. **Code Review**
   - Understand every line of assembly code
   - Know the purpose of each register
   - Understand x86-64 calling convention
   - Be ready to explain algorithm choices

6. **Prepare Demonstration**
   - Prepare simple examples for each function
   - Be ready to trace through the code line by line
   - Prepare answers for common questions (see below)

---

## Mandatory Functions

### 1. `ft_strlen`

**Prototype:** `size_t ft_strlen(const char *str);`

**What it does:** Calculates the length of a string (number of characters until `\0`).

**Key Points for Defense:**
- Uses `rdi` register for the argument (first argument in x86-64)
- Uses `rax` for return value
- Uses `xor rax, rax` to zero (faster than `mov rax, 0`)
- Checks each byte with `cmp byte [rdi + rax], 0`
- Returns length in `rax`

**Possible Questions:**
- Why use `xor rax, rax` instead of `mov rax, 0`?
- What happens if `NULL` is passed? (not handled - this is normal for strlen)
- Why use `byte` in `cmp byte [rdi + rax], 0`?

**Answers:**
- `xor rax, rax` is an optimization: shorter and faster instruction
- Standard `strlen` also doesn't handle `NULL` (undefined behavior)
- `byte` specifies operand size (1 byte) since we're working with characters

---

### 2. `ft_strcpy`

**Prototype:** `char *ft_strcpy(char *dst, const char *src);`

**What it does:** Copies string from `src` to `dst`, including the terminating `\0`.

**Key Points:**
- Saves pointer to `dst` in `rax` for return
- Uses `rdi` for `dst`, `rsi` for `src`
- Copies byte by byte
- Uses `test dl, dl` to check for `\0` (faster than `cmp`)
- Copies the terminating `\0`

**Possible Questions:**
- Why does the function return a pointer to `dst`?
- What happens with overlapping buffers? (undefined behavior, like standard `strcpy`)
- Why use `test dl, dl` instead of `cmp dl, 0`?

**Answers:**
- Returning pointer allows using the function in expressions: `ft_strcpy(dst, src) + 5`
- Overlapping buffers are not handled (like in standard library)
- `test` is faster as it performs bitwise AND without writing result

---

### 3. `ft_strcmp`

**Prototype:** `int ft_strcmp(const char *s1, const char *s2);`

**What it does:** Compares two strings lexicographically.

**Key Points:**
- Returns negative number if `s1 < s2`
- Returns 0 if `s1 == s2`
- Returns positive number if `s1 > s2`
- Compares byte by byte
- Returns difference between characters at first difference

**Possible Questions:**
- How is the return value calculated?
- What happens if one string is shorter than the other?
- Why return character difference instead of just -1/0/1?

**Answers:**
- Returns `(unsigned char)s1[i] - (unsigned char)s2[i]` at first difference
- If one string is shorter, comparison reaches `\0` and returns difference
- Standard `strcmp` also returns difference, not fixed values

---

### 4. `ft_write`

**Prototype:** `ssize_t ft_write(int fd, const void *buf, size_t count);`

**What it does:** Writes `count` bytes from buffer `buf` to file descriptor `fd`.

**Key Points:**
- Uses `write` system call (number 0x2000004 on macOS, 1 on Linux)
- `rdi` = fd, `rsi` = buf, `rdx` = count
- Returns number of bytes written or -1 on error
- Sets `errno` on error

**Possible Questions:**
- What system call number is used?
- What is a file descriptor?
- How are errors handled?

**Answers:**
- On macOS: `0x2000004` (SYS_write), on Linux: `1`
- File descriptor is a number identifying an open file (0=stdin, 1=stdout, 2=stderr)
- On error, `rax` contains negative value, and `errno` is set

**Important:** 
- On macOS: system calls have offset `0x2000000` (write = `0x2000004`, read = `0x2000003`)
- On Linux: direct system call numbers (write = `1`, read = `0`)
- Error handling: macOS uses `___error()`, Linux uses `__errno_location()`
- The code uses conditional compilation to support both platforms

---

### 5. `ft_read`

**Prototype:** `ssize_t ft_read(int fd, void *buf, size_t count);`

**What it does:** Reads up to `count` bytes from file descriptor `fd` into buffer `buf`.

**Key Points:**
- Uses `read` system call
- On macOS: `0x2000003`, on Linux: `0`
- Returns number of bytes read (may be less than `count`)
- Returns 0 on end of file
- Returns -1 on error

**Possible Questions:**
- Why might fewer bytes be read than requested?
- What happens when reading from stdin?
- How is end of file handled?

**Answers:**
- System call may return fewer bytes due to buffering or available data
- When reading from stdin (fd=0), function waits for user input
- End of file is determined by return of 0 bytes

---

### 6. `ft_strdup`

**Prototype:** `char *ft_strdup(const char *s);`

**What it does:** Allocates memory and copies a string.

**Key Points:**
- Calls `malloc` to allocate memory
- Uses `ft_strlen` to determine size
- Uses `ft_strcpy` to copy
- Returns `NULL` on allocation error
- Allocates `strlen(s) + 1` bytes (for `\0`)

**Key Points:**
- Saves `rdi` on stack before calling `ft_strlen`
- Restores original string from stack for `ft_strcpy`
- Properly handles case when `malloc` returns `NULL`

**Possible Questions:**
- Why save `rdi` on stack?
- What happens if `malloc` returns `NULL`?
- Why allocate `strlen(s) + 1` bytes?

**Answers:**
- `rdi` is modified when calling `ft_strlen`, so original value must be saved
- On `NULL`, function returns `NULL` (like standard `strdup`)
- `+1` is needed for terminating null byte `\0`

---

## Bonus Functions

### 1. `ft_atoi_base`

**Prototype:** `int ft_atoi_base(char *str, char *base);`

**What it does:** Converts a string to a number in the specified base.

**Key Points:**
- Handles `+` and `-` signs
- Skips whitespace at the beginning
- Supports any base (2-16 and more)
- Validates base (not empty, no duplicates, no `+`/`-`)
- Returns 0 on error

**Possible Questions:**
- How is the base determined?
- What happens on overflow?
- How are invalid characters handled?

**Answers:**
- Base is determined by the length of `base` string
- Overflow is not explicitly handled (like standard `atoi`)
- Invalid characters cause parsing to stop

---

### 2. `ft_list_push_front`

**Prototype:** `void ft_list_push_front(t_list **begin_list, void *data);`

**What it does:** Adds a new element to the beginning of the list.

**Key Points:**
- Allocates memory for new element via `malloc`
- Sets `data` and `next`
- Updates `*begin_list` to new element
- Handles empty list case

**Possible Questions:**
- What is a double pointer `**begin_list`?
- How is memory allocation handled?
- What happens if `malloc` returns `NULL`?

**Answers:**
- Double pointer is needed to modify the pointer to the beginning of the list
- On `malloc` error, element is not added (error handling can be added)
- Need to check `malloc` result

---

### 3. `ft_list_size`

**Prototype:** `int ft_list_size(t_list *begin_list);`

**What it does:** Counts the number of elements in the list.

**Key Points:**
- Iterates through the list, counting elements
- Returns 0 for `NULL`
- Uses simple loop

**Possible Questions:**
- What is the algorithm complexity?
- What happens with a circular list?

**Answers:**
- O(n) - linear complexity
- Circular list will cause infinite loop (not handled)

---

### 4. `ft_list_sort`

**Prototype:** `void ft_list_sort(t_list **begin_list, int (*cmp)());`

**What it does:** Sorts the list using a comparison function.

**Key Points:**
- Uses bubble sort algorithm
- Sorts data (data field), not nodes
- Uses comparison function `cmp`
- Saves function pointer in a register (e.g., `r13`)

**Key Implementation Points:**
- Saves `cmp` pointer in a safe register (`r13`)
- Properly saves/restores registers when calling `cmp`
- Uses `swapped` flag for optimization

**Possible Questions:**
- Why use bubble sort?
- How does the comparison function work?
- Why save the function pointer?

**Answers:**
- Bubble sort is simple to implement in assembly
- `cmp` returns >0 if first element is greater, <0 if less, 0 if equal
- Function pointer must be saved because registers change on call

---

### 5. `ft_list_remove_if`

**Prototype:** `void ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(), void (*free_fct)(void *));`

**What it does:** Removes elements from the list if they match `data_ref` according to `cmp` function.

**Key Points:**
- Iterates through the list
- Uses `cmp` for comparison
- Calls `free_fct` to free data
- Frees node memory via `free`
- Properly updates pointers

**Possible Questions:**
- How is removal of the first element handled?
- What happens if `free_fct` is `NULL`?
- How are pointers updated on removal?

**Answers:**
- Removing first element requires updating `*begin_list`
- If `free_fct == NULL`, data is not freed
- Need to save pointer to next element before removal

---

## Typical Defense Questions

### General Assembly Questions

1. **What is x86-64 calling convention?**
   - First 6 integer arguments passed in registers: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`
   - Return value in `rax`
   - Registers `rbx`, `rbp`, `r12-r15` must be preserved by called function
   - Stack must be aligned to 16 bytes before function calls

2. **Which registers are used for what?**
   - `rax` - return value, also used for calculations
   - `rdi` - first argument
   - `rsi` - second argument
   - `rdx` - third argument
   - `rcx`, `r8`, `r9` - next arguments
   - `rsp` - stack pointer
   - `rbp` - base pointer (usually preserved)

3. **What are system calls?**
   - Way for program to interact with OS kernel
   - System call number placed in `rax`
   - Arguments passed in `rdi`, `rsi`, `rdx`, `r10`, `r8`, `r9`
   - Called via `syscall` (Linux) or `syscall` with macro (macOS)

4. **Difference between macOS and Linux?**
   - **Object file format**: macOS uses `macho64`, Linux uses `elf64`
   - **System calls**: macOS uses offset `0x2000000` (write = `0x2000004`), Linux uses direct numbers (write = `1`)
   - **Function names**: macOS uses underscore prefix (`_ft_strlen`), Linux without (`ft_strlen`)
   - **Error handling**: macOS uses `___error()`, Linux uses `__errno_location()`
   - **Error detection**: macOS uses carry flag (`jnc`), Linux checks for negative return value
   - **Makefile**: Automatically detects platform and uses appropriate flags

### Function-Specific Questions

1. **Why doesn't `ft_strlen` check for `NULL`?**
   - Standard `strlen` also doesn't check `NULL` (undefined behavior)
   - Check adds overhead
   - Matches standard library behavior

2. **How does `ft_strdup` work?**
   - Calls `ft_strlen` to determine size
   - Allocates memory via `malloc(strlen(s) + 1)`
   - Copies string via `ft_strcpy`
   - Returns pointer or `NULL` on error

3. **Why do `ft_write` and `ft_read` return `ssize_t`?**
   - `ssize_t` is signed type, can be -1 on error
   - `size_t` is unsigned, cannot be negative
   - Matches standard library

---

## Demonstration

### Preparation

1. **Build the project:**
   ```bash
   make fclean
   make bonus
   make test
   ```

2. **Prepare simple examples:**
   ```c
   // Example for ft_strlen
   printf("ft_strlen(\"Hello\") = %zu\n", ft_strlen("Hello"));
   
   // Example for ft_strcpy
   char dst[100];
   ft_strcpy(dst, "Hello");
   printf("Copied: %s\n", dst);
   
   // Example for ft_strcmp
   printf("ft_strcmp(\"abc\", \"abd\") = %d\n", ft_strcmp("abc", "abd"));
   ```

3. **List demonstration:**
   ```c
   t_list *list = NULL;
   ft_list_push_front(&list, "third");
   ft_list_push_front(&list, "second");
   ft_list_push_front(&list, "first");
   printf("Size: %d\n", ft_list_size(list));
   ```

### What to Show During Defense

1. ✅ Project compiles without errors
2. ✅ All tests pass
3. ✅ Functions work correctly
4. ✅ Edge case handling (empty strings, NULL, etc.)
5. ✅ Understanding of code and algorithms

---

## Common Mistakes

### 1. Incorrect Register Usage
- ❌ Using registers that must be preserved (`rbx`, `rbp`, `r12-r15`) without saving
- ✅ Save these registers on stack if using them

### 2. Incorrect Stack Usage
- ❌ Unbalanced stack (push without pop)
- ✅ Always balance the stack

### 3. Incorrect System Calls
- ❌ Using wrong system call number
- ✅ Check numbers for your OS (macOS vs Linux)

### 4. Incorrect Pointer Handling
- ❌ Losing function pointer on call
- ✅ Save function pointers in safe registers

### 5. Incorrect Memory Management
- ❌ Memory leaks in `ft_strdup` and list functions
- ✅ Always free allocated memory in tests

---

## Useful Commands

### Debugging

```bash
# Disassemble object file
objdump -d build/ft_strlen.o

# View symbols
nm libasm.a

# Check architecture
file libasm.a
file tests/test_libasm

# Run under debugger
lldb tests/test_libasm
# or
gdb tests/test_libasm
```

### Testing

```bash
# Run tests
make test

# Compile test file manually (macOS)
cc -arch x86_64 -Wall -Wextra -Werror -I include tests/main.c libasm.a -o test_manual

# Compile test file manually (Linux)
cc -Wall -Wextra -Werror -I include tests/main.c libasm.a -o test_manual

# Run manual test
./test_manual
```

### Platform-Specific Commands

```bash
# Check current platform
uname -s

# View archive contents
ar -t libasm.a

# Check archive index (Linux)
ranlib libasm.a
# or
ar s libasm.a

# View symbols in archive
nm libasm.a

# Disassemble object file
objdump -d build/ft_strlen.o  # Linux
otool -tV build/ft_strlen.o   # macOS
```

### Code Checking

```bash
# Check norm (if norminette is installed)
norminette src/

# Search for issues in code
grep -r "TODO\|FIXME\|BUG" src/
```

---

## Defense Day Protocol

### Step-by-Step Defense Process

1. **Initial Setup (2-3 minutes)**
   ```bash
   # Show clean state
   ls -la
   make fclean
   
   # Build the project
   make bonus
   
   # Verify compilation
   ls -la libasm.a
   ```

2. **Run Tests (2-3 minutes)**
   ```bash
   make test
   # Show all tests passing
   ```

3. **Code Walkthrough (15-20 minutes)**
   - Start with mandatory functions
   - Explain each function line by line
   - Show register usage and calling convention
   - Explain system calls for `ft_write` and `ft_read`

4. **Bonus Functions (if implemented) (10-15 minutes)**
   - Explain list operations
   - Show memory management
   - Demonstrate function pointers

5. **Questions & Answers (10-15 minutes)**
   - Answer questions about your implementation
   - Discuss optimization possibilities
   - Explain platform differences (macOS vs Linux)

### Tips for Successful Defense

1. **Study the code thoroughly**
   - You must understand every line of assembly
   - Know why each instruction is used
   - Understand register usage and stack management

2. **Practice your explanations**
   - Explain the code out loud to yourself
   - Practice tracing through execution step by step
   - Prepare for "what happens if..." questions

3. **Be ready for common questions**
   - "Why did you use `xor rax, rax` instead of `mov rax, 0`?"
   - "How does error handling work in `ft_write`?"
   - "What's the difference between macOS and Linux implementation?"
   - "Can this be optimized?"

4. **Demonstrate confidently**
   - Show that all tests pass
   - Walk through code execution mentally
   - Explain edge cases handling

5. **Be honest and clear**
   - If you don't know something, admit it
   - Show that you understand the fundamentals
   - Explain your thought process

---

## Common Defense Scenarios

### Scenario 1: "Show me how ft_strlen works"

**What to do:**
1. Open `src/ft_strlen.s`
2. Walk through each instruction:
   - `xor rax, rax` - initialize counter to 0
   - `.loop:` - start of loop
   - `cmp byte [rdi + rax], 0` - compare current byte with null terminator
   - `je .done` - if equal, exit loop
   - `inc rax` - increment counter
   - `jmp .loop` - continue loop
   - `.done: ret` - return length in rax

### Scenario 2: "Explain the system call in ft_write"

**What to do:**
1. Explain system call mechanism:
   - System call number in `rax`
   - Arguments in `rdi`, `rsi`, `rdx`
   - Call `syscall` instruction
2. Show platform differences:
   - macOS: `0x2000004` (with offset)
   - Linux: `1` (direct)
3. Explain error handling:
   - Check return value (negative = error)
   - Set errno via platform-specific function

### Scenario 3: "How does ft_strdup work?"

**What to do:**
1. Show the algorithm:
   - Save `rdi` on stack (it will be modified)
   - Call `ft_strlen` to get length
   - Allocate `length + 1` bytes with `malloc`
   - Check if `malloc` returned NULL
   - Restore original string pointer from stack
   - Call `ft_strcpy` to copy string
   - Return pointer or NULL

## Additional Resources

- [NASM Documentation](https://www.nasm.us/docs.php)
- [x86-64 Calling Convention](https://en.wikipedia.org/wiki/X86_calling_conventions)
- [System Call Numbers - macOS](https://github.com/apple/darwin-xnu/blob/main/bsd/kern/syscalls.master)
- [System Call Numbers - Linux](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md)
- [x86-64 Assembly Guide](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html)
- [Linux System Call Table](https://syscalls.kernelgrok.com/)

---

