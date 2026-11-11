# ASM Primitives Lab - Project Overview

## 🎯 Project Mission

This lab provides **clean, production-quality assembly language routines** that demonstrate fundamental low-level programming concepts. Each example is self-contained, well-commented, and designed to help you understand the core mechanisms of system calls, stack frames, and calling conventions on both x86-64 and ARM64 architectures.

---

## 🧩 Core Components

### 1. Raw System Calls

Direct interaction with the operating system kernel without libc mediation.

**Key Concepts:**
- System call instruction (`syscall` on x86-64, `svc #0` on ARM64)
- System call number passing
- Argument registers
- Return value handling
- Error checking

**Why It Matters:**
- Understand how libc functions are implemented
- Create minimal, dependency-free binaries
- Learn OS interface fundamentals
- Essential for embedded systems and bootloaders

### 2. Stack Frame Layouts

Managing the call stack for function calls and local storage.

**Key Concepts:**
- Function prologue and epilogue
- Stack pointer (RSP/SP) manipulation
- Base pointer (RBP/FP) usage
- Local variable allocation
- Stack alignment requirements

**Why It Matters:**
- Understand how functions maintain their state
- Debug stack-related issues
- Optimize stack usage
- Essential for compiler development

### 3. Calling Conventions

How arguments are passed between functions and how return values are handled.

**Key Concepts:**
- Register-based argument passing
- Stack-based argument passing
- Callee-saved vs caller-saved registers
- Return value conventions
- ABI compliance

**Why It Matters:**
- Interoperate with compiled code
- Understand compiler-generated assembly
- Write efficient assembly functions
- Essential for FFI (Foreign Function Interface)

---

## 🎓 Learning Philosophy

### Progressive Complexity

The examples are organized from simplest to most complex:

1. **Beginner**: Basic system calls with minimal context
2. **Intermediate**: Stack manipulation and function calls
3. **Advanced**: Complex calling conventions and nested calls

### Architecture Comparison

Each concept is demonstrated on **both x86-64 and ARM64**, highlighting:
- Similarities between architectures
- Key differences in implementation
- ABI variations
- Instruction set differences

### Hands-On Learning

Each example includes:
- ✅ Complete, working code
- ✅ Detailed comments explaining each instruction
- ✅ Build instructions
- ✅ Expected output

---

## 🔄 Development Workflow

### Recommended Approach

1. **Read the Code** - Study the well-commented examples
2. **Build and Run** - Compile and execute to see results
3. **Modify** - Make small changes and observe effects
4. **Experiment** - Try implementing your own variations
5. **Debug** - Use GDB and objdump to inspect the binaries

### Tools You'll Use

| Tool | Purpose | Usage |
|------|---------|-------|
| `nasm` | Assemble source to object | `nasm -f elf64 file.asm -o file.o` |
| `ld` | Link object files | `ld file.o -o file` |
| `objdump` | Disassemble binaries | `objdump -d file` |
| `gdb` | Debug binaries | `gdb ./file` |
| `strace` | Trace system calls | `strace ./file` |
| `readelf` | Inspect ELF headers | `readelf -S file` |

---

## 🏆 Learning Outcomes

By completing this lab, you will:

### 🎯 Knowledge
- Understand x86-64 and ARM64 architectures
- Know how system calls work at the hardware level
- Understand stack frame management
- Master calling conventions for both architectures

### 🛠️ Skills
- Write correct and efficient assembly code
- Use NASM to assemble programs
- Link and debug assembly programs
- Read and understand disassembled code
- Debug low-level issues

### 🧠 Understanding
- How compilers generate assembly
- How operating systems provide services
- How functions call each other
- How ABIs ensure compatibility

---

## 📚 Documentation Structure

The documentation is organized to support different learning paths:

### By Architecture
```
docs/
├── x86_64/         # x86-64 specific documentation
│   ├── SYSCALLS.md
│   ├── STACK_FRAMES.md
│   └── CALLING_CONVENTIONS.md
└── arm64/          # ARM64 specific documentation
    ├── SYSCALLS.md
    ├── STACK_FRAMES.md
    └── CALLING_CONVENTIONS.md
```

### By Concept
```
docs/
├── OVERVIEW.md     # This file
├── SYSCALLS/       # Cross-architecture syscall docs
│   ├── x86_64.md
│   └── arm64.md
├── STACK_FRAMES/   # Cross-architecture stack docs
│   ├── x86_64.md
│   └── arm64.md
└── CALLING_CONVENTIONS/ # Cross-architecture ABI docs
    ├── x86_64.md
    └── arm64.md
```

---

## 🔍 Code Organization

The source code follows a clean, modular structure:

```
src/
├── x86_64/              # x86-64 architecture
│   ├── syscalls/        # System call examples
│   │   ├── hello_world.asm         # Simple write
│   │   ├── file_operations.asm     # File I/O
│   │   └── syscall_numbers.asm     # Reference
│   ├── stack/           # Stack frame examples
│   │   ├── stack_frame.asm         # Function frames
│   │   └── stack_operations.asm    # Stack manipulation
│   └── calling_conventions/ # ABI examples
│       ├── system_v_amd64.asm      # Linux ABI
│       └── microsoft_x64.asm      # Windows ABI (reference)
└── arm64/               # ARM64 architecture
    ├── syscalls/
    │   ├── hello_world_arm64.asm
    │   ├── file_operations_arm64.asm
    │   └── syscall_numbers_arm64.asm
    ├── stack/
    │   ├── stack_frame_arm64.asm
    │   └── stack_operations_arm64.asm
    └── calling_conventions/
        └── aapcs64.asm             # ARM64 ABI
```

---

## 🎯 Recommended Learning Path

### Week 1: System Calls
1. Read `docs/x86_64/SYSCALLS.md`
2. Study `src/x86_64/syscalls/hello_world.asm`
3. Build and run it
4. Modify to print different messages
5. Study `src/x86_64/syscalls/file_operations.asm`

### Week 2: Stack Frames
1. Read `docs/x86_64/STACK_FRAMES.md`
2. Study `src/x86_64/stack/stack_frame.asm`
3. Build and run it
4. Modify to add more functions
5. Study `src/x86_64/stack/stack_operations.asm`

### Week 3: Calling Conventions
1. Read `docs/x86_64/CALLING_CONVENTIONS.md`
2. Study `src/x86_64/calling_conventions/system_v_amd64.asm`
3. Build and run it
4. Create your own functions

### Week 4: ARM64
1. Read ARM64 documentation
2. Compare with x86-64 implementations
3. Build ARM64 examples (if you have ARM64 hardware/toolchain)
4. Understand the differences

---

## 💡 Tips for Success

1. **Take Notes** - Write down what you learn
2. **Ask Questions** - If something is unclear, dig deeper
3. **Experiment** - Try breaking things and fixing them
4. **Compare** - Look at the differences between x86-64 and ARM64
5. **Document** - Keep a journal of your experiments

---

## 🔗 Next Steps

After completing this lab, consider exploring:

- **Shellcoding** - Writing position-independent code
- **Kernel Development** - Writing OS-level code
- **Exploit Development** - Understanding vulnerabilities
- **Compiler Development** - Writing your own compiler backend
- **Embedded Systems** - Bare-metal programming

---

## 📞 Support

If you have questions or need help:

1. Check the documentation first
2. Review the example code
3. Use debugging tools (GDB, objdump)
4. Consult the reference materials
5. Ask in the community forums

---

*Good luck, and happy learning! 🚀*
