# x86-64 Stack Frames - Complete Guide

## 📖 Overview

This guide covers **stack frame management** on x86-64 architecture. Stack frames are essential for function calls, local variable storage, and maintaining the call chain. Understanding stack frames is crucial for writing correct assembly code and debugging complex programs.

---

## 🎯 Key Concepts

### What is a Stack Frame?

A **stack frame** (or **activation record**) is a data structure on the call stack that contains:
- Function arguments
- Local variables
- Saved registers
- Return address
- Previous stack frame pointer

Each function call creates a new stack frame, and the stack grows downward in memory (toward lower addresses).

### Stack Pointer vs Frame Pointer

| Register | Purpose | Description |
|----------|---------|-------------|
| `rsp` | Stack Pointer | Points to the top of the stack |
| `rbp` | Base Pointer (Frame Pointer) | Points to the current stack frame's base |

- **`rsp`** - Always points to the most recently pushed value
- **`rbp`** - Points to the saved `rbp` from the caller's frame

---

## 🏗️ Stack Frame Structure

A typical x86-64 stack frame looks like this:

```
Higher Addresses
+------------------+
|   Arguments      |  (pushed by caller)
+------------------+
|   Return Address |  (pushed by `call` instruction)
+------------------+
|   Saved RBP      |  (pushed by function prologue)
+------------------+
|   Local Variables|  (allocated by function)
+------------------+
|   Saved Registers|  (callee-saved registers)
+------------------+
|   ...            |  (temporary storage)
+------------------+
Lower Addresses
```

---

## 📝 Standard Prologue and Epilogue

### Function Prologue

The **prologue** is the code at the beginning of a function that sets up the stack frame:

```nasm
push rbp            ; Save caller's frame pointer
mov rbp, rsp        ; Set new frame pointer
sub rsp, N          ; Allocate space for local variables (N bytes)
```

### Function Epilogue

The **epilogue** is the code at the end of a function that cleans up the stack frame:

```nasm
mov rsp, rbp        ; Deallocate local variables
pop rbp             ; Restore caller's frame pointer
ret                 ; Return to caller
```

### Complete Example

```nasm
my_function:
    ; Prologue
    push rbp
    mov rbp, rsp
    sub rsp, 32         ; 32 bytes for local variables
    
    ; Save callee-saved registers
    push rbx
    push r12
    push r13
    
    ; Function body
    ; ... your code here ...
    
    ; Restore callee-saved registers
    pop r13
    pop r12
    pop rbx
    
    ; Epilogue
    mov rsp, rbp
    pop rbp
    ret
```

---

## 📝 Code Examples

### Example 1: Simple Function with Stack Frame

See `src/x86_64/stack/stack_frame.asm` for a complete working example.

```nasm
section .data
    msg db 'Stack frame demonstration', 0x0A
    msg_len equ $ - msg

section .text
    global _start

; Function with stack frame
my_function:
    ; Standard prologue
    push rbp
    mov rbp, rsp
    sub rsp, 16         ; Allocate 16 bytes for locals
    
    ; Save callee-saved registers
    push rbx
    push r12
    
    ; Use local variables
    mov [rbp-8], rdi    ; Store first arg at local var 1
    mov [rbp-16], rsi   ; Store second arg at local var 2
    
    ; Do something
    mov rax, [rbp-8]
    add rax, [rbp-16]
    
    ; Restore callee-saved registers
    pop r12
    pop rbx
    
    ; Standard epilogue
    mov rsp, rbp
    pop rbp
    ret

_start:
    ; Set up stack frame
    push rbp
    mov rbp, rsp
    
    ; Call function
    mov rdi, 10
    mov rsi, 20
    call my_function
    
    ; Print result
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    mov rax, 1
    syscall
    
    ; Clean up
    mov rsp, rbp
    pop rbp
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

### Example 2: Nested Function Calls

```nasm
section .text
    global _start

; Level 3 function (deepest)
level3:
    push rbp
    mov rbp, rsp
    
    ; Minimal function
    mov rax, rdi
    add rax, 100
    
    mov rsp, rbp
    pop rbp
    ret

; Level 2 function
level2:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    
    ; Call level3
    mov rdi, [rbp+16]  ; Access argument from caller
    call level3
    
    ; rax has result from level3
    add rax, 50
    
    mov rsp, rbp
    pop rbp
    ret

; Level 1 function
level1:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    
    ; Call level2
    mov rdi, 42
    call level2
    
    ; rax has result from level2
    add rax, 25
    
    mov rsp, rbp
    pop rbp
    ret

_start:
    push rbp
    mov rbp, rsp
    
    ; Call level1
    call level1
    
    ; rax has final result
    
    mov rsp, rbp
    pop rbp
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

### Example 3: Stack Operations

See `src/x86_64/stack/stack_operations.asm` for push/pop operations.

```nasm
section .text
    global _start

_start:
    ; Push registers onto stack
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Allocate space on stack
    sub rsp, 64
    
    ; Store values on stack
    mov [rsp], rax
    mov [rsp+8], rbx
    mov [rsp+16], rcx
    
    ; Load values from stack
    mov r8, [rsp]
    mov r9, [rsp+8]
    mov r10, [rsp+16]
    
    ; Deallocate space
    add rsp, 64
    
    ; Pop registers from stack
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

---

## 🔧 Stack Frame Management

### Stack Alignment

The **System V AMD64 ABI** requires the stack to be **16-byte aligned** at function calls:

```nasm
; Ensure 16-byte alignment before calling a function
sub rsp, 8          ; Allocate 8 bytes to maintain alignment
call some_function
add rsp, 8          ; Deallocate
```

### Accessing Function Arguments

With a stack frame, arguments can be accessed relative to `rbp`:

```nasm
my_function:
    push rbp
    mov rbp, rsp
    
    ; Arguments (assuming System V AMD64)
    ; rdi, rsi, rdx, rcx, r8, r9 are in registers
    ; Additional arguments are on stack
    
    ; 7th argument (if any) is at [rbp + 16]
    ; 8th argument (if any) is at [rbp + 24]
    ; etc.
    
    mov rax, [rbp + 16]  ; Get 7th argument
    
    mov rsp, rbp
    pop rbp
    ret
```

### Accessing Local Variables

Local variables are accessed relative to `rbp` with **negative offsets**:

```nasm
my_function:
    push rbp
    mov rbp, rsp
    sub rsp, 32         ; Allocate 32 bytes
    
    ; Local variables
    mov [rbp - 8], rdi   ; Local var 1 (8 bytes)
    mov [rbp - 16], rsi  ; Local var 2 (8 bytes)
    mov [rbp - 24], rdx  ; Local var 3 (8 bytes)
    
    ; Access local variables
    mov rax, [rbp - 8]
    add rax, [rbp - 16]
    
    mov rsp, rbp
    pop rbp
    ret
```

---

## 📊 Register Classification

### Callee-Saved Registers

These registers **must be preserved** by the function (callee):
- `rbx` - General purpose
- `rbp` - Base pointer (frame pointer)
- `r12` - General purpose
- `r13` - General purpose
- `r14` - General purpose
- `r15` - General purpose

If your function modifies these, you **must** save and restore them:
```nasm
push rbx
push r12
; ... use rbx and r12 ...
pop r12
pop rbx
```

### Caller-Saved Registers

These registers **can be modified** by the function (callee). The caller must save them if needed:
- `rax` - Return value / scratch
- `rcx` - 4th argument / scratch
- `rdx` - 3rd argument / scratch
- `rsi` - 2nd argument / scratch
- `rdi` - 1st argument / scratch
- `r8` - 5th argument / scratch
- `r9` - 6th argument / scratch
- `r10` - 4th argument (syscall) / scratch
- `r11` - Scratch

### Special Registers

- `rsp` - Stack pointer (must always point to valid stack)
- `rip` - Instruction pointer (read-only in user mode)
- `rflags` - Processor flags

---

## 🧪 Practical Exercises

### Exercise 1: Frame Pointer Chain

Create a program that walks the frame pointer chain and prints the return addresses.

**Hint**: Each frame's return address is at `[rbp + 8]`.

### Exercise 2: Local Array

Create a function that declares a local array and fills it with values.

**Hint**: Allocate space with `sub rsp, N` and access with `[rbp - offset]`.

### Exercise 3: Recursive Function

Create a recursive function (e.g., factorial or Fibonacci).

**Hint**: Each recursive call gets its own stack frame.

### Exercise 4: Variable Argument Function

Create a function that accepts a variable number of arguments (like `printf`).

**Hint**: Use the stack to access arguments beyond the 6 register arguments.

---

## ⚡ Optimization Techniques

### Omitting Frame Pointer

For **leaf functions** (functions that don't call other functions), you can omit the frame pointer:

```nasm
; Without frame pointer
leaf_function:
    sub rsp, 16         ; Allocate space only
    ; ... function body ...
    add rsp, 16
    ret
```

**Pros**: Saves 2 instructions (push/pop rbp) and one register.

**Cons**: Makes debugging harder (no frame chain to walk).

### Using `enter` and `leave` Instructions

The `enter` and `leave` instructions provide a more compact way to manage stack frames:

```nasm
my_function:
    enter 32, 0    ; Allocate 32 bytes, no nested access
    ; ... function body ...
    leave
    ret
```

`enter N, 0` is equivalent to:
```nasm
push rbp
mov rbp, rsp
sub rsp, N
```

`leave` is equivalent to:
```nasm
mov rsp, rbp
pop rbp
```

**Note**: These instructions are slower on modern CPUs, so manual prologue/epilogue is preferred.

---

## 🎯 Best Practices

### 1. Always Maintain Stack Alignment

The stack **must** be 16-byte aligned at function calls. If you allocate an odd number of bytes, adjust:

```nasm
; Allocate 24 bytes (not 16-byte aligned)
sub rsp, 24

; Call a function - stack is not 16-byte aligned!
; FIX: Allocate 32 bytes instead
sub rsp, 32
```

### 2. Use Frame Pointers for Debugging

Even if optimizing for performance, use frame pointers during development:
```nasm
push rbp
mov rbp, rsp
```

This makes debugging with GDB much easier.

### 3. Document Stack Layout

Comment your stack frame layout:
```nasm
my_function:
    push rbp            ; Save frame pointer
    mov rbp, rsp        ; Set new frame pointer
    sub rsp, 32         ; Allocate 32 bytes
    ; Stack layout:
    ; [rbp-8]   - local_var1
    ; [rbp-16]  - local_var2
    ; [rbp-24]  - local_var3
    ; [rbp-32]  - local_var4
```

### 4. Save Callee-Saved Registers

If you modify `rbx`, `r12-r15`, or `rbp`, **save and restore them**:
```nasm
push rbx
push r12
; ... use rbx and r12 ...
pop r12
pop rbx
```

### 5. Keep Stack Frames Small

Allocate only the space you need. Large stack frames can cause stack overflow.

---

## 🔗 Related Topics

- [x86-64 System Calls](./SYSCALLS.md) - Using system calls in your stack frames
- [x86-64 Calling Conventions](./CALLING_CONVENTIONS.md) - How arguments are passed
- [ARM64 Stack Frames](../arm64/STACK_FRAMES.md) - Compare with ARM64 implementation

---

## 📚 Next Steps

After mastering stack frames, explore:

1. **[Calling Conventions](./CALLING_CONVENTIONS.md)** - How functions communicate
2. **ARM64 Stack Frames** - Compare with x86-64
3. **Shellcoding** - Writing position-independent code
4. **Kernel Development** - Understanding kernel stack frames

---

*Keep building and learning! 💪*
