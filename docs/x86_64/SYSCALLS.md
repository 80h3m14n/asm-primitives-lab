# x86-64 System Calls - Complete Guide

## 📖 Overview

This guide covers **raw system calls** on x86-64 Linux architecture. System calls are the fundamental interface between user-space programs and the Linux kernel, allowing direct access to operating system services without the overhead of libc.

---

## 🎯 Key Concepts

### What is a System Call?

A **system call** is a controlled entry point into the kernel that allows user-space programs to request services from the operating system. Examples include:
- Reading from/writing to files
- Memory allocation
- Process creation and management
- Network operations
- Time-related operations

### Why Use Raw System Calls?

1. **Minimal Dependencies** - No need for libc
2. **Smaller Binaries** - No library overhead
3. **Educational Value** - Understand how libc functions work
4. **Performance** - Direct kernel interface (though usually negligible)
5. **Control** - Full control over the system call interface

---

## 🔧 x86-64 System Call Mechanism

### The `syscall` Instruction

On x86-64 Linux, system calls use the `syscall` instruction, which:
1. Transitions from user mode to kernel mode
2. Saves processor state
3. Transfers control to the kernel
4. Returns to user mode with results

### Register Usage

| Register | Purpose | Description |
|----------|---------|-------------|
| `rax` | System Call Number | Identifies which system call to invoke |
| `rdi` | Argument 1 | First argument |
| `rsi` | Argument 2 | Second argument |
| `rdx` | Argument 3 | Third argument |
| `r10` | Argument 4 | Fourth argument |
| `r8` | Argument 5 | Fifth argument |
| `r9` | Argument 6 | Sixth argument |
| `rax` | Return Value | Primary return value (also error indicator) |
| `rdx` | Return Value 2 | Secondary return value for some calls |

### System Call Numbers

Each system call has a unique number. See `src/x86_64/syscalls/syscall_numbers.asm` for a comprehensive list.

Common system calls:
- `0` - `sys_read` - Read from file descriptor
- `1` - `sys_write` - Write to file descriptor
- `2` - `sys_open` - Open a file
- `3` - `sys_close` - Close a file
- `9` - `sys_mmap` - Memory mapping
- `12` - `sys_brk` - Change data segment size
- `39` - `sys_getpid` - Get process ID
- `56` - `sys_clone` - Create a child process
- `57` - `sys_fork` - Fork a process
- `59` - `sys_execve` - Execute a program
- `60` - `sys_exit` - Terminate process
- `61` - `sys_wait4` - Wait for process termination
- `62` - `sys_kill` - Send signal to process

---

## 📝 Code Examples

### Example 1: Hello World (Basic)

```nasm
; File: src/x86_64/syscalls/hello_world.asm

section .data
    hello_msg db 'Hello, World!', 0x0A
    hello_len equ $ - hello_msg

section .text
    global _start

_start:
    ; sys_write(1, hello_msg, hello_len)
    mov rax, 1          ; sys_write = 1
    mov rdi, 1          ; fd = stdout = 1
    mov rsi, hello_msg  ; buffer address
    mov rdx, hello_len  ; buffer length
    syscall             ; invoke system call
    
    ; sys_exit(0)
    mov rax, 60         ; sys_exit = 60
    xor rdi, rdi        ; status = 0
    syscall
```

#### Build & Run:
```bash
nasm -f elf64 hello_world.asm -o hello_world.o
ld hello_world.o -o hello_world
./hello_world
```

#### Expected Output:
```
Hello, World!
```

### Example 2: Hello World with Error Handling

```nasm
section .data
    hello_msg db 'Hello, World!', 0x0A
    hello_len equ $ - hello_msg
    error_msg db 'Error!', 0x0A
    error_len equ $ - error_msg

section .text
    global _start

_start:
    ; sys_write
    mov rax, 1
    mov rdi, 1
    mov rsi, hello_msg
    mov rdx, hello_len
    syscall
    
    ; Check for error (negative return in rax)
    cmp rax, 0
    jl error
    
    ; Success - exit
    mov rax, 60
    xor rdi, rdi
    syscall

error:
    ; sys_write error message
    mov rax, 1
    mov rdi, 2          ; stderr
    mov rsi, error_msg
    mov rdx, error_len
    syscall
    
    ; Exit with error
    mov rax, 60
    mov rdi, 1
    syscall
```

### Example 3: File Operations

See `src/x86_64/syscalls/file_operations.asm` for a complete example of:
- Opening files (`sys_open`)
- Writing to files (`sys_write`)
- Reading from files (`sys_read`)
- Seeking in files (`sys_lseek`)
- Closing files (`sys_close`)

---

## 🔍 Understanding System Call Numbers

### Finding System Call Numbers

System call numbers can vary between kernel versions. Here are ways to find them:

#### Method 1: Check Header Files
```bash
# x86-64 system call numbers
cat /usr/include/asm/unistd_64.h

# Or search for specific calls
grep "define __NR_" /usr/include/asm/unistd_64.h
```

#### Method 2: Use strace
```bash
# Trace system calls of a program
strace -e trace=write ls > /dev/null 2>&1

# Or use a simple C program
strace -e trace=write ./a.out
```

#### Method 3: Online References
- [Linux System Call Table](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md)
- [Linux man pages](https://man7.org/linux/man-pages/)

### System Call Number Stability

System call numbers are **stable** within major kernel versions, but can change between major versions. The most common calls (0-200) are generally stable.

---

## ⚡ Error Handling

### Return Value Convention

- **Success**: Non-negative value in `rax`
- **Error**: Negative value in `rax` (errno = -rax)

### Checking for Errors

```nasm
syscall
cmp rax, 0
jl error_handler  ; Jump if negative (error)
```

Or more concisely:
```nasm
syscall
js error_handler  ; Jump if sign flag set (negative result)
```

### Getting errno

The error number is the negative of the return value:
```nasm
syscall
neg rax           ; Convert negative to positive errno
; rax now contains errno value
```

### Common errno Values

| errno | Name | Description |
|-------|------|-------------|
| 1 | EPERM | Operation not permitted |
| 2 | ENOENT | No such file or directory |
| 3 | ESRCH | No such process |
| 4 | EINTR | Interrupted system call |
| 5 | EIO | I/O error |
| 9 | EBADF | Bad file number |
| 11 | EAGAIN | Try again |
| 12 | ENOMEM | Out of memory |
| 13 | EACCES | Permission denied |
| 14 | EFAULT | Bad address |
| 17 | EEXIST | File exists |
| 20 | ENOTDIR | Not a directory |
| 21 | EISDIR | Is a directory |

---

## 🧪 Practical Exercises

### Exercise 1: Simple Echo

Create a program that reads a line from stdin and writes it to stdout.

**Hint**: Use `sys_read` with fd=0 (stdin) and `sys_write` with fd=1 (stdout).

### Exercise 2: Copy File

Create a program that copies one file to another.

**Steps**:
1. Open source file (read-only)
2. Open destination file (write-only, create, truncate)
3. Read from source in chunks
4. Write to destination
5. Close both files

### Exercise 3: File Size

Create a program that prints the size of a file.

**Hint**: Use `sys_lseek` with SEEK_END to get file size.

### Exercise 4: Current Time

Create a program that prints the current time.

**Hint**: Use `sys_gettimeofday` (system call number varies).

---

## 📊 System Call Categories

### File Operations
- `sys_read` (0) - Read from file descriptor
- `sys_write` (1) - Write to file descriptor
- `sys_open` (2) - Open file
- `sys_close` (3) - Close file
- `sys_stat` (4) - Get file status
- `sys_fstat` (5) - Get file status (by fd)
- `sys_lstat` (6) - Get file status (no symlink follow)
- `sys_poll` (7) - Poll file descriptors
- `sys_lseek` (8) - Seek in file
- `sys_mmap` (9) - Memory map
- `sys_truncate` (76) - Truncate file
- `sys_ftruncate` (77) - Truncate file (by fd)

### Process Management
- `sys_fork` (57) - Fork process
- `sys_vfork` (58) - Virtual memory fork
- `sys_execve` (59) - Execute program
- `sys_exit` (60) - Exit process
- `sys_wait4` (61) - Wait for process
- `sys_kill` (62) - Send signal
- `sys_uname` (63) - Get system info
- `sys_getpid` (39) - Get process ID
- `sys_getppid` (110) - Get parent process ID

### Memory Management
- `sys_brk` (12) - Change data segment
- `sys_mmap` (9) - Memory map
- `sys_munmap` (11) - Memory unmap
- `sys_mprotect` (10) - Memory protection
- `sys_madvise` (28) - Memory advice
- `sys_mincore` (27) - Check memory residency

### Network Operations
- `sys_socket` (41) - Create socket
- `sys_connect` (42) - Connect socket
- `sys_accept` (43) - Accept connection
- `sys_bind` (49) - Bind socket
- `sys_listen` (50) - Listen on socket
- `sys_sendto` (44) - Send message
- `sys_recvfrom` (45) - Receive message
- `sys_sendmsg` (46) - Send message (struct)
- `sys_recvmsg` (47) - Receive message (struct)

### Time Operations
- `sys_gettimeofday` (96) - Get time
- `sys_settimeofday` (97) - Set time
- `sys_times` (100) - Get process times
- `sys_nanosleep` (35) - Sleep
- `sys_alarm` (37) - Set alarm

---

## 🎯 Best Practices

### 1. Use Equates for System Call Numbers

Instead of:
```nasm
mov rax, 1    ; What is 1?
```

Use:
```nasm
SYS_WRITE equ 1
mov rax, SYS_WRITE
```

Or better, include the syscall numbers file:
```nasm
%include "syscall_numbers.asm"
```

### 2. Always Check Return Values

```nasm
syscall
cmp rax, 0
jl error_handler
```

### 3. Preserve Registers When Needed

If your function calls system calls and needs to preserve registers:
```nasm
push rbx
push r12
; ... your code ...
pop r12
pop rbx
```

### 4. Keep Stack Aligned

The x86-64 ABI requires **16-byte stack alignment** at function calls:
```nasm
sub rsp, 8    ; Ensure 16-byte alignment before call
call some_function
add rsp, 8
```

### 5. Use Meaningful Labels

```nasm
; Good
open_file:
    mov rax, SYS_OPEN
    ; ...
    syscall
    jc open_failed
    ret

open_failed:
    ; error handling
    ret

; Bad
label1:
    mov rax, 2
    ; ...
    syscall
    jc label2
    ret

label2:
    ret
```

---

## 🔗 Related Topics

- [Linux System Call Reference](https://man7.org/linux/man-pages/man2/syscalls.2.html)
- [x86-64 ABI Specification](https://refspecs.linuxfoundation.org/elf/x86_64-SysV-psABI.pdf)
- [NASM Documentation](https://www.nasm.us/doc/)
- [Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/)

---

## 📚 Next Steps

After mastering system calls, explore:

1. **[Stack Frames](./STACK_FRAMES.md)** - How functions manage their local state
2. **[Calling Conventions](./CALLING_CONVENTIONS.md)** - How functions communicate
3. **ARM64 System Calls** - Compare with x86-64 implementation

---

*Keep experimenting and learning! 🚀*
