# ASM Primitives Lab

## 🏗️ Stack: x86-64 & ARM64 Assembly, NASM

Clean assembly routines demonstrating raw system calls, stack frame layouts, and calling conventions, complete with detailed Markdown documentation.

---

## 📁 Project Structure

```
asm-primitives-lab/
├── README.md                           # This file
├── Makefile                           # Build automation
├── docs/
│   ├── OVERVIEW.md                    # Project overview
│   ├── x86_64/
│   │   ├── SYSCALLS.md                # x86-64 system calls
│   │   ├── STACK_FRAMES.md            # x86-64 stack frames
│   │   ├── CALLING_CONVENTIONS.md     # x86-64 calling conventions
│   │   └── QUICK_START.md             # x86-64 quick start
│   └── arm64/
│       ├── SYSCALLS.md                # ARM64 system calls
│       ├── STACK_FRAMES.md            # ARM64 stack frames
│       ├── CALLING_CONVENTIONS.md     # ARM64 calling conventions
│       └── QUICK_START.md             # ARM64 quick start
└── src/
    ├── x86_64/
    │   ├── syscalls/
    │   │   ├── hello_world.asm         # Basic sys_write demo
    │   │   ├── file_operations.asm     # File I/O system calls
    │   │   └── syscall_numbers.asm     # System call number reference
    │   ├── stack/
    │   │   ├── stack_frame.asm         # Function prologue/epilogue
    │   │   └── stack_operations.asm    # Push/pop and stack manipulation
    │   └── calling_conventions/
    │       ├── system_v_amd64.asm      # Linux System V AMD64 ABI
    │       └── microsoft_x64.asm      # Windows x64 ABI (reference)
    └── arm64/
        ├── syscalls/
        │   ├── hello_world_arm64.asm   # ARM64 sys_write demo
        │   ├── file_operations_arm64.asm
        │   └── syscall_numbers_arm64.asm
        ├── stack/
        │   ├── stack_frame_arm64.asm   # ARM64 stack frame management
        │   └── stack_operations_arm64.asm
        └── calling_conventions/
            └── aapcs64.asm             # ARM64 AAPCS64 calling convention
```

---

## 🚀 Quick Start

### Prerequisites

- **NASM** (Netwide Assembler) 2.15 or later
- **GNU Binutils** (ld, objdump, etc.)
- **Linux system** (for running the binaries)
- **ARM64 cross-compiler** (optional, for ARM64 targets)

Install on Ubuntu/Debian:
```bash
sudo apt update
sudo apt install nasm binutils build-essential
```

### Build & Run Examples

#### x86-64 Examples

```bash
# Build and run Hello World
nasm -f elf64 src/x86_64/syscalls/hello_world.asm -o build/hello_world.o
ld build/hello_world.o -o build/hello_world
./build/hello_world

# Build and run file operations
nasm -f elf64 src/x86_64/syscalls/file_operations.asm -o build/file_operations.o
ld build/file_operations.o -o build/file_operations
./build/file_operations

# Build and run stack frame demo
nasm -f elf64 src/x86_64/stack/stack_frame.asm -o build/stack_frame.o
ld build/stack_frame.o -o build/stack_frame
./build/stack_frame

# Build and run calling convention demo
nasm -f elf64 src/x86_64/calling_conventions/system_v_amd64.asm -o build/system_v_amd64.o
ld build/system_v_amd64.o -o build/system_v_amd64
./build/system_v_amd64
```

#### Using Makefile

```bash
# Build all x86-64 examples
make x86_64

# Build specific example
make x86_64/hello_world

# Build specific file
make src/x86_64/syscalls/hello_world.asm

# Clean build
make clean

# Clean and rebuild
make rebuild

# Run tests
make test

# Show help
make help
```
```

---

## 📚 Documentation

### x86-64 Architecture

#### System Calls
- **Raw System Calls**: Direct invocation using `syscall` instruction
- **System Call Numbers**: See `src/x86_64/syscalls/syscall_numbers.asm`
- **Argument Passing**: rax (syscall #), rdi, rsi, rdx, r10, r8, r9
- **Return Values**: rax (result), rdx (secondary for some calls)

#### Stack Frames
- **Prologue**: `push rbp; mov rbp, rsp; sub rsp, N`
- **Epilogue**: `mov rsp, rbp; pop rbp; ret`
- **Stack Alignment**: 16-byte aligned at function calls
- **Callee-Saved**: rbp, rbx, r12-r15
- **Caller-Saved**: rax, rcx, rdx, rsi, rdi, r8-r11

#### Calling Conventions
- **System V AMD64 ABI** (Linux/macOS):
  - First 6 integer args: rdi, rsi, rdx, rcx, r8, r9
  - Additional args: stack (right to left)
  - Return: rax (and rdx for 128-bit)
  - Floating point: xmm0-xmm7

- **Microsoft x64 ABI** (Windows):
  - First 4 integer args: rcx, rdx, r8, r9
  - Additional args: stack
  - Return: rax
  - Shadow space: 32 bytes on stack

### ARM64 Architecture

#### System Calls
- **Raw System Calls**: Using `svc #0` instruction
- **System Call Numbers**: In w8 register (different numbers from x86-64)
- **Argument Passing**: x0-x5, additional on stack
- **Return Values**: x0 (and x1 for 128-bit)

#### Stack Frames
- **Prologue**: `stp x29, x30, [sp, #-16]!; mov x29, sp`
- **Epilogue**: `ldp x29, x30, [sp], #16; ret`
- **Stack Alignment**: 16-byte aligned at all times
- **Callee-Saved**: x19-x28, x29 (FP), x30 (LR)
- **Caller-Saved**: x0-x18

#### Calling Conventions
- **AAPCS64** (ARM64 ABI):
  - First 8 integer args: x0-x7
  - Additional args: stack (8-byte aligned)
  - Return: x0 (and x1 for 128-bit)
  - Floating point: q0-q7 (or s0-s31, d0-d31)

---


## 🎯 Learning Objectives

This lab helps you understand:

1. **System Call Mechanisms**
   - How to make direct system calls without libc
   - Difference between x86-64 and ARM64 system call interfaces
   - System call number management

2. **Stack Frame Management**
   - Function prologue and epilogue patterns
   - Stack alignment requirements
   - Local variable allocation on stack
   - Nested function calls

3. **Calling Conventions**
   - How arguments are passed (registers vs stack)
   - Which registers are preserved by callee vs caller
   - Return value conventions
   - ABI differences between platforms

4. **Assembly Language Basics**
   - NASM syntax
   - Register usage
   - Memory addressing
   - Control flow

---

## 📊 Code Examples Summary

### x86-64 System Calls
| File | Description |
|------|-------------|
| `hello_world.asm` | Basic write syscall |
| `file_operations.asm` | open, write, read, close |
| `syscall_numbers.asm` | Comprehensive syscall reference |

### x86-64 Stack Frames
| File | Description |
|------|-------------|
| `stack_frame.asm` | Function prologue/epilogue |
| `stack_operations.asm` | push/pop operations |

### x86-64 Calling Conventions
| File | Description |
|------|-------------|
| `system_v_amd64.asm` | Linux System V AMD64 ABI |
| `microsoft_x64.asm` | Windows x64 ABI (reference) |

### ARM64 System Calls
| File | Description |
|------|-------------|
| `hello_world_arm64.asm` | Basic ARM64 write syscall |
| `file_operations_arm64.asm` | ARM64 file operations |
| `syscall_numbers_arm64.asm` | ARM64 syscall reference |

### ARM64 Stack Frames
| File | Description |
|------|-------------|
| `stack_frame_arm64.asm` | ARM64 stack frame management |
| `stack_operations_arm64.asm` | ARM64 stack operations |

### ARM64 Calling Conventions
| File | Description |
|------|-------------|
| `aapcs64.asm` | ARM64 AAPCS64 calling convention |

---

## 🔍 Debugging Tips

### Viewing Binary Output

```bash
# Disassemble with objdump
objdump -d build/hello_world

# View symbols
nm build/hello_world

# View section headers
readelf -S build/hello_world

# View in hex
xxd build/hello_world
```

### Debugging with GDB

```bash
# Run with GDB
gdb ./build/hello_world

# Set breakpoint at _start
break _start

# Single step (instruction level)
si

# Next instruction
i

# Examine registers
info registers

# Examine memory
x/x $rsp
```

### Viewing System Call Numbers

```bash
# Check system call table
cat /usr/include/asm/unistd_64.h  # x86-64
cat /usr/include/arm64/unistd.h   # ARM64 (if available)

# Or use strace to see system calls
strace ./build/hello_world
```

---

## 📖 Additional Resources

### x86-64 References
- [Intel® 64 and IA-32 Architectures Software Developer's Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
- [System V Application Binary Interface](https://refspecs.linuxfoundation.org/elf/x86_64-SysV-psABI.pdf)
- [Linux x86-64 System Call Table](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md)

### ARM64 References
- [ARM Architecture Reference Manual](https://developer.arm.com/documentation/)
- [Procedure Call Standard for the ARM 64-bit Architecture (AAPCS64)](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst)
- [ARM64 System Call Table](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md)

### NASM Documentation
- [NASM Manual](https://www.nasm.us/doc/)
- [NASM x86-64 Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial/)

---

## 🎓 Learning Path

### Beginner
1. Start with `src/x86_64/syscalls/hello_world.asm`
2. Read `docs/x86_64/SYSCALLS.md`
3. Try modifying and rebuilding

### Intermediate
1. Study `src/x86_64/stack/stack_frame.asm`
2. Read `docs/x86_64/STACK_FRAMES.md`
3. Experiment with nested function calls

### Advanced
1. Compare x86-64 and ARM64 implementations
2. Study calling convention differences
3. Read `docs/x86_64/CALLING_CONVENTIONS.md` and `docs/arm64/CALLING_CONVENTIONS.md`
4. Implement your own functions

---

## 💡 Tips & Best Practices

1. **Comment your code** - Assembly is hard to read without comments
2. **Use meaningful labels** - `loop_start:` is better than `label1:`
3. **Keep functions small** - Complex logic is harder to debug in assembly
4. **Test frequently** - Small changes can have big effects
5. **Use version control** - Track your progress and experiments

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest improvements
- Add new examples
- Improve documentation

---

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

---

*Happy coding! 💻🔥*
