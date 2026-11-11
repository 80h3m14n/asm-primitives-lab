# ARM64 Quick Start Guide

## 🚀 Get Started with ARM64 Assembly

This guide will help you get started with ARM64 assembly programming. Note that ARM64 development typically requires either ARM64 hardware or a cross-compilation toolchain.

---

## ✅ Prerequisites

### Option 1: Native ARM64 System

If you have an ARM64 machine (Raspberry Pi 4, AWS Graviton, Apple M1/M2, etc.):

**Ubuntu/Debian ARM64:**
```bash
sudo apt update
sudo apt install nasm binutils build-essential gdb
```

**Fedora ARM64:**
```bash
sudo dnf install nasm binutils gcc gdb
```

### Option 2: Cross-Compilation Toolchain

If you're on x86-64 and want to build ARM64 binaries:

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
```

**macOS (Homebrew):**
```bash
brew install aarch64-elf-gcc
```

### Option 3: QEMU Emulation

Run ARM64 binaries on x86-64 using QEMU:

```bash
sudo apt install qemu-user-static
```

---

## 📝 Your First ARM64 Program

### Step 1: Create the File

Create a new file called `hello_arm64.asm`:

```bash
nano hello_arm64.asm
```

### Step 2: Write the Code

```nasm
; File: hello_arm64.asm
; Simple Hello World for ARM64 using raw system calls

section .data
    hello_msg db 'Hello, ARM64 World!', 0x0A
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

### Step 3: Assemble and Link

#### On Native ARM64:
```bash
nasm -f elf64 hello_arm64.asm -o hello_arm64.o
ld hello_arm64.o -o hello_arm64
```

#### With Cross-Compiler:
```bash
# Note: Standard NASM may not support ARM64
# Use ARM64-specific assembler instead
aarch64-linux-gnu-as -o hello_arm64.o hello_arm64.asm
# Or use the provided examples with GAS syntax
aarch64-linux-gnu-ld hello_arm64.o -o hello_arm64
```

### Step 4: Run It!

#### On Native ARM64:
```bash
./hello_arm64
```

#### With QEMU:
```bash
qemu-aarch64-static ./hello_arm64
```

**Expected Output:**
```
Hello, ARM64 World!
```

**⚠️ Important**: The system call numbers may differ on your system. Check `src/arm64/syscalls/syscall_numbers_arm64.asm` or use `strace` to find the correct numbers.

---

## 🔍 Understanding ARM64 Assembly

### Key Differences from x86-64

| Feature | x86-64 | ARM64 |
|---------|--------|-------|
| System Call Instruction | `syscall` | `svc #0` |
| System Call Number Register | `rax` | `w8` (32-bit) or `x8` (64-bit) |
| Argument Registers | `rdi`, `rsi`, `rdx`, `r10`, `r8`, `r9` | `x0`-`x5` |
| Return Value Register | `rax` | `x0` (and `x1` for 128-bit) |
| Frame Pointer | `rbp` | `x29` |
| Link Register | `rip` (implicit) | `x30` |
| Stack Pointer | `rsp` | `sp` |
| Push/Pop | `push`, `pop` | `stp`, `ldp` |

### ARM64 Registers

| Register | Name | Purpose |
|----------|------|---------|
| `x0`-`x30` | General Purpose | 64-bit registers |
| `w0`-`w30` | General Purpose | 32-bit versions of x0-x30 |
| `x29` | FP | Frame Pointer |
| `x30` | LR | Link Register (return address) |
| `sp` | SP | Stack Pointer |
| `pc` | PC | Program Counter |
| `xzr` | XZR | Zero Register (always 0) |

### ARM64 Instructions

| Instruction | Description | x86-64 Equivalent |
|-------------|-------------|-------------------|
| `mov x0, #10` | Move immediate to register | `mov rax, 10` |
| `ldr x0, [sp]` | Load from memory | `mov rax, [rsp]` |
| `str x0, [sp]` | Store to memory | `mov [rsp], rax` |
| `stp x0, x1, [sp, #-16]!` | Store pair, pre-decrement | `push rax; push rbx` |
| `ldp x0, x1, [sp], #16` | Load pair, post-increment | `pop rbx; pop rax` |
| `add x0, x1, x2` | Add registers | `add rax, rbx, rcx` |
| `sub x0, x1, x2` | Subtract registers | `sub rax, rbx, rcx` |
| `bl label` | Branch with link (call) | `call label` |
| `ret` | Return | `ret` |
| `svc #0` | Supervisor call (syscall) | `syscall` |

---

## 📊 Code Breakdown

Let's break down the `hello_arm64.asm` program:

### 1. Data Definition

```nasm
section .data
    hello_msg db 'Hello, ARM64 World!', 0x0A
    hello_len equ $ - hello_msg
```

- Same as x86-64: defines a string and its length

### 2. Entry Point

```nasm
section .text
    global _start
_start:
```

- Same as x86-64: `_start` is the entry point

### 3. System Call: Write

```nasm
mov w8, #64         ; __NR_write = 64
mov x0, #1          ; fd = stdout = 1
ldr x1, =hello_msg  ; buffer address
ldr x2, =hello_len  ; buffer length
svc #0              ; invoke system call
```

- `w8` = 32-bit version of x8 (system call numbers fit in 32 bits)
- `x0`, `x1`, `x2` = argument registers (vs `rdi`, `rsi`, `rdx` on x86-64)
- `ldr` = Load register with address (ARM64 doesn't have direct addressing like x86-64)
- `svc #0` = Supervisor call (vs `syscall` on x86-64)

### 4. System Call: Exit

```nasm
mov w8, #93         ; __NR_exit = 93
mov x0, #0          ; status = 0
svc #0
```

- Same pattern as write, but different system call number

---

## 🛠️ Building ARM64 Programs

### Method 1: Using GAS Syntax (Recommended)

The examples in `src/arm64/` use NASM syntax, but you can also use GAS (GNU Assembler) syntax:

```nasm
/* hello_arm64.s - GAS syntax */

.data
hello_msg: .asciz "Hello, ARM64 World!\n"
hello_len = . - hello_msg

.text
.globl _start

_start:
    /* sys_write */
    mov w8, #64
    mov x0, #1
    ldr x1, =hello_msg
    ldr x2, =hello_len
    svc #0
    
    /* sys_exit */
    mov w8, #93
    mov x0, #0
    svc #0
```

Build with:
```bash
aarch64-linux-gnu-as -o hello_arm64.o hello_arm64.s
aarch64-linux-gnu-ld hello_arm64.o -o hello_arm64
```

### Method 2: Using NASM (if available)

Some versions of NASM support ARM64:
```bash
nasm -f elf64 hello_arm64.asm -o hello_arm64.o
ld hello_arm64.o -o hello_arm64
```

---

## 🔍 Debugging ARM64 Programs

### 1. Disassemble with objdump

```bash
# For ARM64 binary
aarch64-linux-gnu-objdump -d hello_arm64
```

### 2. Debug with GDB

```bash
# For native ARM64
gdb ./hello_arm64

# For cross-compiled (using QEMU)
qemu-aarch64-static -g 1234 ./hello_arm64
gdb -ex "target remote localhost:1234" ./hello_arm64
```

Inside GDB:
```
(gdb) break _start
(gdb) run
(gdb) si                # Single step
(gdb) info registers    # Show registers
(gdb) x/s $x1          # Examine string at x1
(gdb) quit
```

### 3. Trace System Calls

```bash
# On ARM64 system
strace ./hello_arm64

# With QEMU
qemu-aarch64-static -strace ./hello_arm64
```

---

## 📈 Next Steps

### Try These Examples

1. **Echo Program**: Read from stdin, write to stdout
   - Use `sys_read` (63) with fd=0 (stdin)
   - Use `sys_write` (64) with fd=1 (stdout)

2. **Process Info**: Print process ID
   - Use `sys_getpid` (172 on some kernels)

3. **Compare with x86-64**: Port x86-64 examples to ARM64

### Explore the Source Code

Browse the examples in `src/arm64/`:
- `syscalls/hello_world_arm64.asm` - Basic write
- `syscalls/file_operations_arm64.asm` - File I/O
- `stack/stack_frame_arm64.asm` - Function prologue/epilogue
- `calling_conventions/aapcs64.asm` - Function calls

### Read the Documentation

- [ARM64 System Calls Documentation](./SYSCALLS.md) - Deep dive into ARM64 system calls
- [ARM64 Stack Frames Documentation](./STACK_FRAMES.md) - Stack management on ARM64
- [ARM64 Calling Conventions Documentation](./CALLING_CONVENTIONS.md) - AAPCS64 ABI

---

## 🎯 Common Pitfalls

### 1. Wrong System Call Numbers

```nasm
mov w8, #1    ; Trying to use sys_write (should be 64 on ARM64)
```

**Problem**: Using x86-64 system call numbers on ARM64.

**Fix**: Check `src/arm64/syscalls/syscall_numbers_arm64.asm` or use `strace`.

### 2. Using 32-bit Registers Incorrectly

```nasm
mov x8, #64   ; Should be w8 for 32-bit immediate
```

**Problem**: Trying to load a 32-bit value into a 64-bit register.

**Fix**: Use `w8` for 32-bit values (system call numbers are 32-bit).

### 3. Forgetting to Save LR

```nasm
my_function:
    ; Missing prologue
    ; ... calls other functions ...
    ret
```

**Problem**: If your function calls other functions and doesn't save LR, it won't return correctly.

**Fix**: Always save LR in the prologue:
```nasm
stp x29, x30, [sp, #-16]!
mov x29, sp
```

### 4. Stack Misalignment

```nasm
sub sp, sp, #8    ; Allocates 8 bytes (not 16-byte aligned)
bl some_function
```

**Problem**: ARM64 requires 16-byte stack alignment.

**Fix**: Always allocate even multiples of 16:
```nasm
sub sp, sp, #16   ; Allocate 16 bytes
bl some_function
add sp, sp, #16
```

### 5. Using x86-64 Instructions

```nasm
push x0    ; x86-64 instruction, doesn't exist on ARM64
```

**Problem**: Using x86-64-specific instructions.

**Fix**: Use ARM64 equivalents:
```nasm
stp x0, x1, [sp, #-16]!  ; ARM64 push equivalent
```

---

## 💡 Tips for ARM64 Development

1. **Check Your Toolchain** - Verify you have ARM64 support
2. **Use GAS Syntax** - More widely supported for ARM64
3. **Check System Call Numbers** - They vary by kernel version
4. **Maintain Stack Alignment** - Always 16-byte aligned
5. **Save Callee-Saved Registers** - x19-x28, x29, x30
6. **Use `stp`/`ldp` for Efficiency** - Store/load pairs of registers

---

## 📚 Learning Path

### Beginner (1-2 hours)
✅ Complete this Quick Start Guide
✅ Build and run `hello_arm64.asm` (or GAS version)
✅ Understand the key differences from x86-64

### Intermediate (1 day)
- Read [ARM64 System Calls Documentation](./SYSCALLS.md)
- Study `src/arm64/syscalls/file_operations_arm64.asm`
- Port an x86-64 example to ARM64

### Advanced (1 week)
- Read [ARM64 Stack Frames Documentation](./STACK_FRAMES.md)
- Study `src/arm64/stack/stack_frame_arm64.asm`
- Implement recursive functions on ARM64
- Read [ARM64 Calling Conventions Documentation](./CALLING_CONVENTIONS.md)

### Expert (1 month)
- Compare x86-64 and ARM64 implementations
- Write portable assembly code
- Understand AAPCS64 deeply
- Call C functions from ARM64 assembly

---

## 🤝 Need Help?

1. **Check the examples** - The provided ARM64 code has working examples
2. **Read the documentation** - The ARM64 docs cover all concepts
3. **Use strace** - Trace system calls to see what numbers your kernel uses
4. **Consult ARM documentation** - [ARM Architecture Reference Manual](https://developer.arm.com/documentation/)
5. **Google it** - ARM64 assembly questions are common

---

*Happy ARM64 coding! 💻🚀*
