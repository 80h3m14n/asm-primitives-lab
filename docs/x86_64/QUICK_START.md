# x86-64 Quick Start Guide

## 🚀 Get Started in 5 Minutes

This quick start guide will get you building and running x86-64 assembly programs in minutes.

---

## ✅ Prerequisites

### 1. Install Required Tools

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install nasm binutils build-essential gdb
```

**Fedora/RHEL:**
```bash
sudo dnf install nasm binutils gcc gdb
```

**macOS (Homebrew):**
```bash
brew install nasm
```

### 2. Verify Installation

```bash
nasm -v
ld --version
gdb --version
```

---

## 📝 Your First Program: Hello World

### Step 1: Create the File

Create a new file called `hello.asm`:

```bash
nano hello.asm
```

### Step 2: Write the Code

```nasm
; File: hello.asm
; Simple Hello World using raw system calls

section .data
    hello_msg db 'Hello, x86-64 World!', 0x0A
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

### Step 3: Assemble and Link

```bash
nasm -f elf64 hello.asm -o hello.o
ld hello.o -o hello
```

### Step 4: Run It!

```bash
./hello
```

**Expected Output:**
```
Hello, x86-64 World!
```

---

## 🔍 Understanding the Code

Let's break down the `hello.asm` program:

### 1. Section Directives

```nasm
section .data
    ; Data goes here (variables, strings)

section .text
    ; Code goes here
```

- `.data` section: Contains initialized data (strings, constants)
- `.text` section: Contains executable code

### 2. Data Definition

```nasm
hello_msg db 'Hello, x86-64 World!', 0x0A
hello_len equ $ - hello_msg
```

- `db` = Define Byte: Defines a byte of data
- `0x0A` = ASCII newline character
- `equ` = Equate: Defines a constant (hello_len = length of hello_msg)

### 3. Entry Point

```nasm
global _start
_start:
```

- `global _start` makes the `_start` label visible to the linker
- `_start` is the entry point (where execution begins)

### 4. System Call: Write

```nasm
mov rax, 1          ; sys_write = 1
mov rdi, 1          ; fd = stdout = 1
mov rsi, hello_msg  ; buffer address
mov rdx, hello_len  ; buffer length
syscall
```

- `sys_write` is system call number 1
- Arguments:
  - `rdi` = file descriptor (1 = stdout)
  - `rsi` = pointer to data to write
  - `rdx` = number of bytes to write
- `syscall` invokes the kernel

### 5. System Call: Exit

```nasm
mov rax, 60         ; sys_exit = 60
xor rdi, rdi        ; status = 0
syscall
```

- `sys_exit` is system call number 60
- `xor rdi, rdi` sets `rdi` to 0 (exit status 0 = success)

---

## 📊 Common System Calls

| System Call | Number | Description | Arguments |
|-------------|--------|-------------|-----------|
| `sys_read` | 0 | Read from file | rdi=fd, rsi=buf, rdx=count |
| `sys_write` | 1 | Write to file | rdi=fd, rsi=buf, rdx=count |
| `sys_open` | 2 | Open file | rdi=path, rsi=flags, rdx=mode |
| `sys_close` | 3 | Close file | rdi=fd |
| `sys_exit` | 60 | Exit process | rdi=status |
| `sys_getpid` | 39 | Get process ID | none |

---

## 🛠️ Debugging Your Programs

### 1. Disassemble with objdump

```bash
objdump -d hello
```

This shows the machine code and disassembled instructions.

### 2. Debug with GDB

```bash
gdb ./hello
```

Inside GDB:
```
(gdb) break _start      # Set breakpoint at _start
(gdb) run               # Run the program
(gdb) si                # Single step (instruction level)
(gdb) info registers    # Show all registers
(gdb) x/s $rsi          # Examine string at rsi
(gdb) quit              # Exit GDB
```

### 3. Trace System Calls

```bash
strace ./hello
```

This shows all system calls made by your program.

---

## 📈 Next Steps

### Try These Examples

1. **Echo Program**: Read from stdin, write to stdout
   - Use `sys_read` (0) with fd=0 (stdin)
   - Use `sys_write` (1) with fd=1 (stdout)

2. **File Copy**: Copy one file to another
   - Use `sys_open` (2), `sys_read` (0), `sys_write` (1), `sys_close` (3)

3. **Process Info**: Print process ID
   - Use `sys_getpid` (39)

### Explore the Source Code

Browse the examples in `src/x86_64/`:
- `syscalls/hello_world.asm` - Basic write
- `syscalls/file_operations.asm` - File I/O
- `stack/stack_frame.asm` - Function prologue/epilogue
- `calling_conventions/system_v_amd64.asm` - Function calls

### Read the Documentation

- [System Calls Documentation](../x86_64/SYSCALLS.md) - Deep dive into system calls
- [Stack Frames Documentation](../x86_64/STACK_FRAMES.md) - Stack management
- [Calling Conventions Documentation](../x86_64/CALLING_CONVENTIONS.md) - Function calling

---

## 🎯 Common Pitfalls

### 1. Forgetting `global _start`

```nasm
; Missing global directive
_start:
    ; ... code ...
```

**Error**: `ld: cannot find entry symbol _start`

**Fix**: Add `global _start` before the `_start` label.

### 2. Wrong Section

```nasm
section .text
hello_msg db 'Hello', 0x0A
```

**Problem**: Defining data in the `.text` section (which should be read-only).

**Fix**: Use `section .data` for data definitions.

### 3. Incorrect System Call Number

```nasm
mov rax, 4      ; Trying to use sys_write (should be 1)
```

**Problem**: Using the wrong system call number.

**Fix**: Check `src/x86_64/syscalls/syscall_numbers.asm` for correct numbers.

### 4. Forgetting to Exit

```nasm
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall
    ; Missing exit syscall
```

**Problem**: Program continues executing after write, causing segmentation fault.

**Fix**: Always call `sys_exit` at the end.

### 5. Stack Misalignment

```nasm
call some_function    ; Stack may not be 16-byte aligned
```

**Problem**: Calling functions without ensuring 16-byte stack alignment.

**Fix**: Ensure stack is 16-byte aligned before calls:
```nasm
sub rsp, 8          ; Allocate 8 bytes to align
call some_function
add rsp, 8
```

---

## 💡 Tips for Success

1. **Start Simple** - Begin with basic system calls
2. **Test Frequently** - Build and run after each change
3. **Use GDB** - Step through your code to understand what's happening
4. **Read the Docs** - The Linux man pages are your friend
5. **Copy from Examples** - Use the provided examples as templates

---

## 📚 Learning Path

### Beginner (1-2 hours)
✅ Complete this Quick Start Guide
✅ Build and run `hello.asm`
✅ Modify it to print different messages
✅ Try the echo program exercise

### Intermediate (1 day)
- Read [System Calls Documentation](../x86_64/SYSCALLS.md)
- Study `src/x86_64/syscalls/file_operations.asm`
- Implement file copy program
- Learn about error handling

### Advanced (1 week)
- Read [Stack Frames Documentation](../x86_64/STACK_FRAMES.md)
- Study `src/x86_64/stack/stack_frame.asm`
- Implement recursive functions
- Read [Calling Conventions Documentation](../x86_64/CALLING_CONVENTIONS.md)

### Expert (1 month)
- Port examples to ARM64
- Compare x86-64 and ARM64
- Write your own assembly functions
- Call C functions from assembly
- Understand compiler-generated assembly

---

## 🤝 Need Help?

1. **Check the examples** - Most questions are answered by looking at the provided code
2. **Read the documentation** - The docs cover all the concepts
3. **Use GDB** - Debug your programs step by step
4. **Consult man pages** - `man 2 syscalls` for system call documentation
5. **Google it** - Someone has probably asked your question before

---

*Happy coding! 💻🔥*
