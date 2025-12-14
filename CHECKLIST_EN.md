# Libasm - Assignment Compliance Checklist

This document contains a complete checklist for verifying project compliance with assignment requirements.

---

## 📋 Common Instructions (Chapter II)

### Mandatory Requirements

- [x] **Functions don't crash unexpectedly** (segmentation fault, bus error, double free, etc.)
  - All functions are tested and work correctly
  - Error handling is implemented for syscalls

- [x] **Makefile contains rules**: `$(NAME)`, `all`, `clean`, `fclean`, `re`
  - `$(NAME)` = `libasm.a`
  - `all`: builds mandatory functions
  - `clean`: removes object files
  - `fclean`: removes all built files
  - `re`: rebuilds the project
  - Makefile recompiles only changed files

- [x] **bonus rule in Makefile**
  - Implemented `bonus` rule that includes bonus functions
  - Bonuses in separate `*_bonus.s` files

- [x] **Test program main**
  - Implemented in `tests/main.c`
  - Tests all functions (mandatory + bonus)

- [x] **64-bit assembly**
  - Uses `elf64` format (Linux) / `macho64` format (macOS)
  - 64-bit x86-64 architecture

- [x] **Separate .s files (not inline ASM)**
  - All functions in separate `.s` files
  - No inline assembly used

- [x] **Compilation via nasm**
  - Uses `nasm` compiler
  - Command: `nasm -f elf64/macho64 ...`

- [x] **Intel syntax (not AT&T)**
  - Uses Intel syntax: `mov dst, src`
  - Not using AT&T: `mov %src, %dst`

- [x] **Forbidden flag `-no-pie` not used**
  - Verified: flag is absent from Makefile

---

## 🔧 Mandatory Part (Chapter III)

### Library Requirements

- [x] **Library is named `libasm.a`**
  - Library name: `libasm.a`
  - Created via `ar rcs libasm.a ...`

- [x] **main function for testing**
  - File: `tests/main.c`
  - Compiles together with the library
  - Demonstrates functionality of all functions

### Mandatory Functions

- [x] **ft_strlen** (man 3 strlen)
  - File: `src/ft_strlen.s`
  - Implemented correctly
  - Returns `size_t` (string length)

- [x] **ft_strcpy** (man 3 strcpy)
  - File: `src/ft_strcpy.s`
  - Implemented correctly
  - Copies string including `\0`
  - Returns pointer to `dst`

- [x] **ft_strcmp** (man 3 strcmp)
  - File: `src/ft_strcmp.s`
  - Implemented correctly
  - Returns difference between strings

- [x] **ft_write** (man 2 write)
  - File: `src/ft_write.s`
  - Implemented correctly
  - Uses `write` system call
  - Handles errors and sets `errno`

- [x] **ft_read** (man 2 read)
  - File: `src/ft_read.s`
  - Implemented correctly
  - Uses `read` system call
  - Handles errors and sets `errno`

- [x] **ft_strdup** (man 3 strdup)
  - File: `src/ft_strdup.s`
  - Implemented correctly
  - Calls `malloc` for memory allocation
  - Uses `ft_strlen` and `ft_strcpy`

### Syscall Error Handling

- [x] **Error checking in syscalls**
  - `ft_write`: checks for errors after `syscall`
  - `ft_read`: checks for errors after `syscall`

- [x] **Setting errno variable**
  - Linux: uses `__errno_location()`
  - macOS: uses `___error()`
  - `errno` is set correctly on errors

---

## 🎁 Bonus Part (Chapter IV)

### t_list Structure

- [x] **Structure matches assignment**
  ```c
  typedef struct s_list
  {
      void            *data;
      struct s_list   *next;
  }   t_list;
  ```
  - Defined in `include/libasm.h`

### Bonus Functions

- [x] **ft_atoi_base** (Annex V.1)
  - File: `src/bonus/ft_atoi_base_bonus.s`
  - Converts string to integer with specified base
  - Validates base (empty, duplicates, invalid characters)
  - Handles `+` and `-` signs
  - Skips whitespace

- [x] **ft_list_push_front** (Annex V.2)
  - File: `src/bonus/ft_list_push_front_bonus.s`
  - Adds element to the beginning of the list
  - Allocates memory via `malloc`
  - Updates pointer to the beginning of the list

- [x] **ft_list_size** (Annex V.3)
  - File: `src/bonus/ft_list_size_bonus.s`
  - Returns number of elements in the list
  - Returns 0 for `NULL`

- [x] **ft_list_sort** (Annex V.4)
  - File: `src/bonus/ft_list_sort_bonus.s`
  - Sorts list in ascending order
  - Uses comparison function `cmp`
  - Saves function pointer in a safe register

- [x] **ft_list_remove_if** (Annex V.5)
  - File: `src/bonus/ft_list_remove_if_bonus.s`
  - Removes elements matching `data_ref`
  - Uses `cmp` for comparison
  - Frees data via `free_fct`
  - Frees nodes via `free`
  - Correctly updates pointers

### Bonus Files

- [x] **All bonuses in `*_bonus.s` files**
  - `ft_atoi_base_bonus.s`
  - `ft_list_push_front_bonus.s`
  - `ft_list_size_bonus.s`
  - `ft_list_sort_bonus.s`
  - `ft_list_remove_if_bonus.s`

---

## 📝 x86-64 Calling Convention Verification

- [x] **Arguments passed in registers**
  - First argument: `rdi`
  - Second argument: `rsi`
  - Third argument: `rdx`
  - Fourth argument: `rcx`
  - Fifth argument: `r8`
  - Sixth argument: `r9`

- [x] **Return value in `rax`**
  - All functions return result in `rax`

- [x] **Register preservation**
  - Registers `rbx`, `rbp`, `r12-r15` are preserved when used
  - Uses `push`/`pop` for preservation

- [x] **Stack alignment**
  - Stack is aligned to 16 bytes before function calls

---

## 🔍 System Calls Verification

### ft_write

- [x] **Correct system call number**
  - Linux: `1` (SYS_write)
  - macOS: `0x2000004` (SYS_write with offset)

- [x] **Correct arguments**
  - `rdi`: file descriptor
  - `rsi`: buffer pointer
  - `rdx`: count

- [x] **Error handling**
  - Checks return value
  - Sets `errno` on error

### ft_read

- [x] **Correct system call number**
  - Linux: `0` (SYS_read)
  - macOS: `0x2000003` (SYS_read with offset)

- [x] **Correct arguments**
  - `rdi`: file descriptor
  - `rsi`: buffer pointer
  - `rdx`: count

- [x] **Error handling**
  - Checks return value
  - Sets `errno` on error

---

## ✅ Final Verification

### Compilation and Build

- [x] **Clean build**
  ```bash
  make fclean
  make bonus
  ```
  - Build completes without errors or warnings

- [x] **Testing**
  ```bash
  make test
  ```
  - All tests pass successfully

- [x] **Project structure check**
  - All files in place
  - Correct file names
  - Correct directory structure

### File Structure

```
ft42_libasm/
├── include/
│   └── libasm.h          ✅
├── src/
│   ├── ft_strlen.s       ✅
│   ├── ft_strcpy.s       ✅
│   ├── ft_strcmp.s       ✅
│   ├── ft_write.s        ✅
│   ├── ft_read.s         ✅
│   ├── ft_strdup.s       ✅
│   └── bonus/
│       ├── ft_atoi_base_bonus.s        ✅
│       ├── ft_list_push_front_bonus.s  ✅
│       ├── ft_list_size_bonus.s        ✅
│       ├── ft_list_sort_bonus.s        ✅
│       └── ft_list_remove_if_bonus.s   ✅
├── tests/
│   └── main.c            ✅
├── Makefile              ✅
└── libasm.a              ✅ (after build)
```

---

## 📊 Final Assessment

### Mandatory Part
- ✅ All requirements met
- ✅ All functions work correctly
- ✅ Error handling implemented
- ✅ Makefile meets requirements

### Bonus Part
- ✅ All 5 bonus functions implemented
- ✅ Files correctly named `*_bonus.s`
- ✅ `t_list` structure matches assignment
- ✅ All functions tested

### Additional Improvements
- ✅ Cross-platform support (macOS/Linux)
- ✅ Complete testing of all functions
- ✅ Detailed documentation (README)

---

## 🎯 Status: **READY FOR DEFENSE**

All assignment requirements are met. The project is ready for submission and defense.

---

*Last updated: based on subject v5.4*

