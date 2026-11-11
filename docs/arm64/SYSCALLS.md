# ARM64 System Calls - Complete Guide

## 📖 Overview

This guide covers **raw system calls** on ARM64 (AArch64) Linux architecture. While similar in concept to x86-64 system calls, ARM64 has important differences in instruction usage, register allocation, and system call numbers.

---

## 🎯 Key Differences from x86-64

| Feature | x86-64 | ARM64 |
|---------|--------|-------|
| System Call Instruction | `syscall` | `svc #0` |
| System Call Number Register | `rax` | `w8` (32-bit) or `x8` (64-bit) |
| Argument Registers | `rdi`, `rsi`, `rdx`, `r10`, `r8`, `r9` | `x0`-`x5` |
| Return Value Register | `rax` | `x0` (and `x1` for 128-bit) |
| System Call Numbers | x86-64 specific | ARM64 specific (different!) |
| Error Indication | Negative `rax` | Negative `x0` |

---

## 🔧 ARM64 System Call Mechanism

### The `svc` Instruction

On ARM64, system calls use the `svc` (Supervisor Call) instruction:

```nasm
mov w8, #syscall_number  ; Load system call number
svc #0                   ; Invoke system call
```

The `#0` is the immediate value for the `svc` instruction and is always 0 for Linux system calls.

### Register Usage

| Register | Purpose | Description |
|----------|---------|-------------|
| `w8` or `x8` | System Call Number | 32-bit or 64-bit system call number |
| `x0` | Argument 1 / Return Value | First argument and primary return value |
| `x1` | Argument 2 | Second argument |
| `x2` | Argument 3 | Third argument |
| `x3` | Argument 4 | Fourth argument |
| `x4` | Argument 5 | Fifth argument |
| `x5` | Argument 6 | Sixth argument |
| `x0` | Return Value | Primary return value |
| `x1` | Return Value 2 | Secondary return value for 128-bit results |

### System Call Numbers

ARM64 system call numbers are **different** from x86-64! See `src/arm64/syscalls/syscall_numbers_arm64.asm` for a comprehensive list.

Common ARM64 system calls:
- `0` - `sys_io_setup`
- `1` - `sys_io_destroy`
- `2` - `sys_io_submit`
- `3` - `sys_io_cancel`
- `4` - `sys_io_getevents`
- `56` - `sys_open` (Note: This varies by kernel version!)
- `57` - `sys_close`
- `62` - `sys_lseek`
- `63` - `sys_read`
- `64` - `sys_write`
- `93` - `sys_exit`
- `137` - `sys_execve`
- `138` - `sys_fork`
- `139` - `sys_vfork`

**⚠️ Important**: ARM64 system call numbers vary significantly between kernel versions. Always check the correct numbers for your kernel.

---

## 📝 Code Examples

### Example 1: Hello World (Basic)

See `src/arm64/syscalls/hello_world_arm64.asm` for a complete example.

```nasm
; File: src/arm64/syscalls/hello_world_arm64.asm

section .data
    hello_msg db 'Hello, World from ARM64!', 0x0A
    hello_len equ $ - hello_msg

section .text
    global _start

_start:
    ; sys_write(1, hello_msg, hello_len)
    mov w8, #64         ; __NR_write = 64 (check your kernel!)
    mov x0, #1          ; fd = stdout = 1
    ldr x1, =hello_msg  ; buffer address
    ldr x2, =hello_len  ; buffer length
    svc #0              ; invoke system call
    
    ; sys_exit(0)
    mov w8, #93         ; __NR_exit = 93
    mov x0, #0          ; status = 0
    svc #0
```

#### Build Notes:

Building ARM64 code requires an ARM64 toolchain:
```bash
# Install ARM64 cross-compiler
sudo apt install gcc-aarch64-linux-gnu

# Build with ARM64 NASM (if available) or use GAS
# Note: Standard NASM may not support ARM64
# Use: aarch64-linux-gnu-nasm (if available)

# Or use GAS syntax with ARM64 assembler
aarch64-linux-gnu-as -o hello_world.o hello_world.s
```

### Example 2: Hello World with Error Handling

```nasm
section .data
    hello_msg db 'Hello, ARM64!', 0x0A
    hello_len equ $ - hello_msg
    error_msg db 'Error!', 0x0A
    error_len equ $ - error_msg

section .text
    global _start

_start:
    ; sys_write
    mov w8, #64
    mov x0, #1
    ldr x1, =hello_msg
    ldr x2, =hello_len
    svc #0
    
    ; Check for error
    cmp x0, #0
    b.lt error
    
    ; Success - exit
    mov w8, #93
    mov x0, #0
    svc #0

error:
    ; sys_write error message to stderr
    mov w8, #64
    mov x0, #2          ; stderr
    ldr x1, =error_msg
    ldr x2, =error_len
    svc #0
    
    ; Exit with error
    mov w8, #93
    mov x0, #1
    svc #0
```

### Example 3: File Operations

See `src/arm64/syscalls/file_operations_arm64.asm` for a complete example.

```nasm
section .data
    filename db 'test_file_arm64.txt', 0
    file_content db 'ARM64 file content', 0x0A
    file_content_len equ $ - file_content
    
    ; File flags
    O_RDWR equ 0x2
    O_CREAT equ 0x40
    O_TRUNC equ 0x200
    S_IRUSR equ 0x100
    S_IWUSR equ 0x80

section .text
    global _start

_start:
    ; sys_open(filename, flags, mode)
    ldr x0, =filename
    mov w1, O_RDWR | O_CREAT | O_TRUNC
    mov w2, S_IRUSR | S_IWUSR
    mov w8, #56          ; __NR_open (check your kernel!)
    svc #0
    
    cmp x0, #0
    b.lt error
    mov x19, x0          ; Save fd in x19 (callee-saved)
    
    ; sys_write(fd, buffer, length)
    mov x0, x19
    ldr x1, =file_content
    ldr x2, =file_content_len
    mov w8, #64          ; __NR_write
    svc #0
    
    cmp x0, #0
    b.lt error
    
    ; sys_close(fd)
    mov x0, x19
    mov w8, #57          ; __NR_close
    svc #0
    
    ; sys_exit(0)
    mov w8, #93
    mov x0, #0
    svc #0

error:
    ; Exit with error
    mov w8, #93
    mov x0, #1
    svc #0
```

---

## 🔍 Finding ARM64 System Call Numbers

### Method 1: Check Header Files

On ARM64 systems:
```bash
cat /usr/include/asm/unistd.h
```

Or search for specific calls:
```bash
grep "define __NR_" /usr/include/asm/unistd.h
```

### Method 2: Use Cross-Compiler Headers

If you have an ARM64 cross-compiler:
```bash
# Find ARM64 includes
ls /usr/aarch64-linux-gnu/include/asm/unistd.h
```

### Method 3: Online References

- [Linux ARM64 System Call Table](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md)
- [ARM64 Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/arm64/)

### Method 4: Experiment with strace

Create a simple C program and trace it on ARM64:

```c
// test_syscall.c
#include <unistd.h>
#include <fcntl.h>

int main() {
    write(1, "test\n", 5);
    return 0;
}
```

```bash
# On ARM64 system
strace -e trace=write ./a.out
```

---

## ⚠️ System Call Number Stability

ARM64 system call numbers are **less stable** than x86-64. They can vary between:
- Different kernel versions
- Different Linux distributions
- Different hardware platforms

### Common ARM64 System Call Numbers (Kernel 4.x+)

| System Call | Number | Notes |
|-------------|--------|-------|
| `sys_read` | 63 | |
| `sys_write` | 64 | |
| `sys_open` | 56 | Varies! |
| `sys_close` | 57 | |
| `sys_stat` | 4 | |
| `sys_fstat` | 5 | |
| `sys_lstat` | 6 | |
| `sys_poll` | 7 | |
| `sys_lseek` | 62 | |
| `sys_mmap` | 9 | |
| `sys_mprotect` | 10 | |
| `sys_munmap` | 11 | |
| `sys_brk` | 12 | |
| `sys_rt_sigaction` | 13 | |
| `sys_rt_sigprocmask` | 14 | |
| `sys_rt_sigreturn` | 15 | |
| `sys_ioctl` | 16 | |
| `sys_pread64` | 17 | |
| `sys_pwrite64` | 18 | |
| `sys_access` | 21 | |
| `sys_pipe` | 22 | |
| `sys_select` | 23 | |
| `sys_sched_yield` | 24 | |
| `sys_fork` | 138 | |
| `sys_vfork` | 139 | |
| `sys_execve` | 137 | |
| `sys_exit` | 93 | |
| `sys_wait4` | 61 | |
| `sys_kill` | 62 | Conflict with lseek! |
| `sys_getpid` | 39 | |

**⚠️ Note**: There are conflicts in the table above. This is why it's crucial to check your specific kernel version.

---

## 🔄 Porting x86-64 Code to ARM64

### Step 1: Change System Call Instruction

```nasm
; x86-64
mov rax, syscall_number
syscall

; ARM64
mov w8, syscall_number
svc #0
```

### Step 2: Change Argument Registers

```nasm
; x86-64
mov rdi, arg1
mov rsi, arg2
mov rdx, arg3
mov r10, arg4
mov r8, arg5
mov r9, arg6

; ARM64
mov x0, arg1
mov x1, arg2
mov x2, arg3
mov x3, arg4
mov x4, arg5
mov x5, arg6
```

### Step 3: Change Return Value Register

```nasm
; x86-64
; rax contains return value

; ARM64
; x0 contains return value
```

### Step 4: Update System Call Numbers

```nasm
; x86-64
mov rax, 1    ; sys_write

; ARM64
mov w8, 64    ; __NR_write on ARM64
```

### Step 5: Error Handling

```nasm
; x86-64
cmp rax, 0
jl error

; ARM64
cmp x0, #0
b.lt error
```

---

## 🧪 Practical Exercises

### Exercise 1: Simple Echo

Create an ARM64 program that reads from stdin and writes to stdout.

**Hint**: Use `sys_read` (63) with fd=0 and `sys_write` (64) with fd=1.

### Exercise 2: File Size

Create an ARM64 program that prints the size of a file.

**Hint**: Use `sys_lseek` (62) with SEEK_END (0) to get file size.

### Exercise 3: Process ID

Create an ARM64 program that prints its process ID.

**Hint**: Use `sys_getpid` (39).

### Exercise 4: Port x86-64 Example

Take one of the x86-64 examples and port it to ARM64.

**Hint**: Follow the porting guide above.

---

## 🎯 Best Practices

### 1. Use Equates for System Call Numbers

```nasm
__NR_write equ 64
__NR_exit equ 93

mov w8, __NR_write
svc #0
```

### 2. Always Check Return Values

```nasm
svc #0
cmp x0, #0
b.lt error_handler
```

### 3. Preserve Callee-Saved Registers

ARM64 callee-saved registers: `x19`-`x28`, `x29` (FP), `x30` (LR)

```nasm
stp x19, x20, [sp, #-16]!
; ... use x19, x20 ...
ldp x19, x20, [sp], #16
```

### 4. Use Proper Load/Store Instructions

ARM64 doesn't have `push` and `pop` instructions like x86-64:

```nasm
; Instead of: push x19, x20
stp x19, x20, [sp, #-16]!

; Instead of: pop x19, x20
ldp x19, x20, [sp], #16
```

### 5. Maintain Stack Alignment

ARM64 requires **16-byte stack alignment** at all times:

```nasm
; Allocate space (must be multiple of 16)
sub sp, sp, #16

; Deallocate
add sp, sp, #16
```

---

## 🔗 Related Topics

- [ARM64 Stack Frames](./STACK_FRAMES.md) - Stack frame management on ARM64
- [ARM64 Calling Conventions](./CALLING_CONVENTIONS.md) - AAPCS64 calling convention
- [x86-64 System Calls](../x86_64/SYSCALLS.md) - Compare with x86-64

---

## 📚 Next Steps

After mastering ARM64 system calls, explore:

1. **[ARM64 Stack Frames](./STACK_FRAMES.md)** - Stack management on ARM64
2. **[ARM64 Calling Conventions](./CALLING_CONVENTIONS.md)** - AAPCS64 ABI
3. **Cross-Architecture Development** - Writing portable assembly
4. **ARM64 Assembly Language** - Advanced ARM64 topics

---

*Keep exploring ARM64! 🚀*
