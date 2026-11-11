# x86-64 Calling Conventions - Complete Guide

## 📖 Overview

This guide covers **calling conventions** on x86-64 architecture. Calling conventions define how functions receive arguments, return values, and preserve registers. Understanding calling conventions is essential for interoperating with compiled code, writing efficient assembly, and debugging complex programs.

---

## 🎯 Why Calling Conventions Matter

Calling conventions ensure that:
1. **Arguments are passed consistently** - Both caller and callee know where to find arguments
2. **Return values are communicated** - Both know where to find the result
3. **Registers are preserved** - Functions don't break each other's assumptions
4. **Stack is managed correctly** - No memory leaks or corruption

Without calling conventions, functions written in different languages or by different compilers couldn't interoperate.

---

## 🏗️ Major x86-64 Calling Conventions

### 1. System V AMD64 ABI (Linux, macOS, BSD, etc.)

This is the **most common** calling convention on Unix-like systems.

#### Register Usage

| Register | Purpose | Description |
|----------|---------|-------------|
| `rdi` | Argument 1 | First integer/pointer argument |
| `rsi` | Argument 2 | Second integer/pointer argument |
| `rdx` | Argument 3 | Third integer/pointer argument |
| `rcx` | Argument 4 | Fourth integer/pointer argument |
| `r8` | Argument 5 | Fifth integer/pointer argument |
| `r9` | Argument 6 | Sixth integer/pointer argument |
| `xmm0` | Argument 1 | First floating-point argument |
| `xmm1` | Argument 2 | Second floating-point argument |
| `xmm2` | Argument 3 | Third floating-point argument |
| `xmm3` | Argument 4 | Fourth floating-point argument |
| `xmm4` | Argument 5 | Fifth floating-point argument |
| `xmm5` | Argument 6 | Sixth floating-point argument |
| `xmm6` | Argument 7 | Seventh floating-point argument |
| `xmm7` | Argument 8 | Eighth floating-point argument |
| `rax` | Return Value | Primary return value (integer/pointer) |
| `rdx` | Return Value 2 | Secondary return value (for 128-bit values) |
| `xmm0` | Return Value | Floating-point return value |
| `xmm1` | Return Value 2 | Secondary floating-point return value |

#### Stack Usage

For arguments beyond the first 8:
- Pushed onto stack **right to left** (last argument first)
- Each argument is 8-byte aligned
- Caller cleans up the stack

#### Register Preservation

| Register | Preserved By | Notes |
|----------|--------------|-------|
| `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8-r11` | Caller | Caller-saved (scratch) |
| `rbx`, `rbp`, `r12-r15` | Callee | Callee-saved (must be preserved) |
| `rsp` | Both | Stack pointer (must be maintained) |
| `rip` | Both | Instruction pointer |
| `rflags` | Both | Processor flags |

#### Stack Alignment

The stack **must** be **16-byte aligned** at function calls.

---

### 2. Microsoft x64 Calling Convention (Windows)

Used on Windows x64 systems.

#### Register Usage

| Register | Purpose | Description |
|----------|---------|-------------|
| `rcx` | Argument 1 | First integer/pointer argument |
| `rdx` | Argument 2 | Second integer/pointer argument |
| `r8` | Argument 3 | Third integer/pointer argument |
| `r9` | Argument 4 | Fourth integer/pointer argument |
| `xmm0` | Argument 1 | First floating-point argument |
| `xmm1` | Argument 2 | Second floating-point argument |
| `xmm2` | Argument 3 | Third floating-point argument |
| `xmm3` | Argument 4 | Fourth floating-point argument |
| `rax` | Return Value | Primary return value |
| `xmm0` | Return Value | Floating-point return value |

#### Stack Usage

- First 4 arguments in registers
- Additional arguments on stack (right to left)
- **32-byte "shadow space"** must be allocated by caller (even if not used)
- Caller cleans up the stack

#### Register Preservation

| Register | Preserved By | Notes |
|----------|--------------|-------|
| `rax`, `rcx`, `rdx`, `r8-r11` | Caller | Caller-saved |
| `rbx`, `rbp`, `rdi`, `rsi`, `r12-r15` | Callee | Callee-saved |

#### Stack Alignment

The stack **must** be **16-byte aligned** at function calls.

---

### 3. Comparison Table

| Feature | System V AMD64 | Microsoft x64 |
|---------|----------------|---------------|
| Integer Arg Registers | rdi, rsi, rdx, rcx, r8, r9 | rcx, rdx, r8, r9 |
| Floating-Point Arg Registers | xmm0-xmm7 | xmm0-xmm3 |
| Max Register Args | 8 | 4 |
| Stack Direction | Right to left | Right to left |
| Shadow Space | No | 32 bytes |
| Stack Cleanup | Caller | Caller |
| Stack Alignment | 16-byte | 16-byte |
| Return Integer | rax, rdx | rax |
| Return Float | xmm0, xmm1 | xmm0 |

---

## 📝 Code Examples

### Example 1: System V AMD64 - Function with 6 Arguments

See `src/x86_64/calling_conventions/system_v_amd64.asm` for a complete example.

```nasm
; Function: add_six_numbers
; Purpose: Add six numbers using System V AMD64
; Input: rdi, rsi, rdx, rcx, r8, r9
; Output: rax = sum

add_six_numbers:
    push rbp
    mov rbp, rsp
    
    ; Sum all register arguments
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    
    mov rsp, rbp
    pop rbp
    ret

; Caller
_start:
    ; Set up stack frame
    push rbp
    mov rbp, rsp
    
    ; Call add_six_numbers with 6 arguments
    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    mov rcx, 4
    mov r8, 5
    mov r9, 6
    
    call add_six_numbers
    
    ; rax contains sum (21)
    
    mov rsp, rbp
    pop rbp
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

### Example 2: System V AMD64 - Function with Stack Arguments

```nasm
; Function: add_ten_numbers
; Purpose: Add ten numbers (6 in registers, 4 on stack)
; Input: rdi-r9 (args 1-6), [rsp+16] (arg 7), [rsp+24] (arg 8), etc.
; Output: rax = sum

add_ten_numbers:
    push rbp
    mov rbp, rsp
    
    ; Sum register arguments
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    
    ; Sum stack arguments
    ; Stack layout at entry:
    ; [rbp+16] - arg7
    ; [rbp+24] - arg8
    ; [rbp+32] - arg9
    ; [rbp+40] - arg10
    add rax, [rbp+16]
    add rax, [rbp+24]
    add rax, [rbp+32]
    add rax, [rbp+40]
    
    mov rsp, rbp
    pop rbp
    ret

; Caller
caller_function:
    push rbp
    mov rbp, rsp
    
    ; Push stack arguments (right to left)
    mov r10, 10
    push r10            ; arg10
    mov r10, 9
    push r10            ; arg9
    mov r10, 8
    push r10            ; arg8
    mov r10, 7
    push r10            ; arg7
    
    ; Set register arguments
    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    mov rcx, 4
    mov r8, 5
    mov r9, 6
    
    ; Ensure 16-byte stack alignment
    sub rsp, 8          ; Allocate 8 bytes for alignment
    
    call add_ten_numbers
    
    add rsp, 8          ; Remove alignment padding
    
    ; Clean up stack arguments (4 * 8 = 32 bytes)
    add rsp, 32
    
    ; rax contains sum
    
    mov rsp, rbp
    pop rbp
    ret
```

### Example 3: System V AMD64 - Function with Callee-Saved Registers

```nasm
; Function: process_data
; Purpose: Process data using callee-saved registers
; Input: rdi = pointer to data, rsi = length
; Output: rax = result

process_data:
    push rbp
    mov rbp, rsp
    
    ; Save callee-saved registers we'll use
    push rbx
    push r12
    push r13
    
    ; Use rbx, r12, r13 for local storage
    mov rbx, rdi        ; Save data pointer in rbx
    mov r12, rsi        ; Save length in r12
    
    xor r13, r13        ; Initialize accumulator in r13
    
    ; Process data
    xor rcx, rcx        ; Counter
    
.process_loop:
    cmp rcx, r12
    jge .done
    
    movzx rax, byte [rbx + rcx]
    add r13, rax
    inc rcx
    jmp .process_loop
    
.done:
    mov rax, r13        ; Return accumulator
    
    ; Restore callee-saved registers
    pop r13
    pop r12
    pop rbx
    
    mov rsp, rbp
    pop rbp
    ret
```

### Example 4: Microsoft x64 - Windows-Style Function

See `src/x86_64/calling_conventions/microsoft_x64.asm` for reference.

```nasm
; Function: windows_add
; Purpose: Add numbers using Microsoft x64 convention
; Input: rcx, rdx, r8, r9 (first 4 args)
; Output: rax = sum

windows_add:
    push rbp
    mov rbp, rsp
    
    ; Save callee-saved registers
    push rbx
    push rsi
    push rdi
    
    ; Sum register arguments
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9
    
    ; Restore callee-saved registers
    pop rdi
    pop rsi
    pop rbx
    
    mov rsp, rbp
    pop rbp
    ret

; Caller (Linux version for demonstration)
caller_function:
    push rbp
    mov rbp, rsp
    
    ; Allocate shadow space (32 bytes)
    sub rsp, 32
    
    ; Set register arguments
    mov rcx, 1
    mov rdx, 2
    mov r8, 3
    mov r9, 4
    
    call windows_add
    
    ; Clean up shadow space
    add rsp, 32
    
    ; rax contains sum (10)
    
    mov rsp, rbp
    pop rbp
    ret
```

---

## 🔍 Argument Classification

### Integer and Pointer Classes

In System V AMD64, arguments are classified into **classes**:

| Class | Registers | Description |
|-------|-----------|-------------|
| INTEGER | rdi, rsi, rdx, rcx, r8, r9 | Integer, pointer, boolean, char, short, int, long, etc. |
| SSE | xmm0-xmm7 | float, double, SSE vectors |
| SSEUP | xmm8-xmm15 | Upper SSE registers (8-15) |
| MEMORY | Stack | All other types (structs > 16 bytes, arrays, etc.) |

### Argument Passing Rules

1. **INTEGER class** arguments go in: rdi, rsi, rdx, rcx, r8, r9, then stack
2. **SSE class** arguments go in: xmm0-xmm7, then stack
3. **SSEUP class** arguments go on stack (not in registers)
4. **MEMORY class** arguments go on stack

### Structure Passing

For **structures**:
- If the structure is **8 bytes or less**: Passed like an integer
- If the structure is **16 bytes or less**: Passed in two registers (e.g., rax:rdx)
- If the structure is **larger than 16 bytes**: A **pointer** to the structure is passed instead

---

## 🧪 Practical Exercises

### Exercise 1: Function with Mixed Argument Types

Create a function that takes:
- 2 integer arguments (in registers)
- 2 floating-point arguments (in xmm registers)
- 1 structure argument (> 16 bytes, so passed as pointer)

**Hint**: Structure arguments > 16 bytes are passed as pointers.

### Exercise 2: Variadic Function

Create a variadic function (like `printf`) that:
- Takes a format string
- Takes variable arguments
- Processes them according to the format

**Hint**: Use the stack to access variable arguments.

### Exercise 3: Call C Function from Assembly

Create an assembly program that calls a C function (e.g., `printf`).

**Hint**: Follow the System V AMD64 ABI for argument passing.

### Exercise 4: Return Structure

Create a function that returns a structure (8 bytes, 16 bytes, > 16 bytes).

**Hint**: For > 16 bytes, the caller passes a pointer to store the result.

---

## ⚡ Optimization Techniques

### 1. Tail Call Optimization

If a function's last action is calling another function, you can reuse the stack frame:

```nasm
; Without tail call optimization
foo:
    push rbp
    mov rbp, rsp
    ; ...
    call bar
    mov rsp, rbp
    pop rbp
    ret

; With tail call optimization
foo:
    push rbp
    mov rbp, rsp
    ; ...
    ; Instead of call + ret, use jmp
    jmp bar  ; Tail call - reuse current stack frame
```

**Warning**: This is only safe if the caller's stack frame layout is compatible with the callee's expectations.

### 2. Inline Functions

For very small functions, the caller can inline the function body:

```nasm
; Instead of:
; call small_function

; Inline:
; mov rax, rdi
; add rax, 10
; (instead of calling a function that does this)
```

### 3. Argument Passing Optimization

If you control both caller and callee, optimize argument passing:

```nasm
; Instead of passing in registers then loading to stack:
; mov [rsp+8], rdi

; Use directly:
; mov rax, rdi
```

---

## 🎯 Best Practices

### 1. Follow the ABI

Always follow the System V AMD64 ABI (or Microsoft x64 on Windows) for:
- Argument passing
- Register preservation
- Stack alignment
- Return values

### 2. Use Meaningful Names

Use descriptive names for functions and labels:

```nasm
; Good
calculate_sum:
    ; ...
    ret

; Bad
func1:
    ; ...
    ret
```

### 3. Document Function Signatures

Comment your function's signature:

```nasm
; Function: add_numbers
; Purpose: Add two numbers
; Input: rdi = a, rsi = b
; Output: rax = a + b
; Clobbers: rax
; Preserves: rbx, r12-r15
add_numbers:
    mov rax, rdi
    add rax, rsi
    ret
```

### 4. Preserve Callee-Saved Registers

If you modify `rbx`, `rbp`, or `r12-r15`, **always** save and restore them:

```nasm
my_function:
    push rbx
    push r12
    ; ... use rbx and r12 ...
    pop r12
    pop rbx
    ret
```

### 5. Ensure Stack Alignment

Always ensure the stack is 16-byte aligned before calling functions:

```nasm
; Before calling a function
sub rsp, 8          ; Ensure 16-byte alignment
call some_function
add rsp, 8
```

### 6. Clean Up Stack Arguments

The caller must clean up stack arguments after a function call:

```nasm
; Call function with 2 stack arguments
sub rsp, 16         ; Allocate space for 2 args
mov [rsp], arg1
mov [rsp+8], arg2
call my_function
add rsp, 16         ; Clean up
```

---

## 🔗 Related Topics

- [x86-64 System Calls](./SYSCALLS.md) - Using system calls with calling conventions
- [x86-64 Stack Frames](./STACK_FRAMES.md) - How stack frames support calling conventions
- [ARM64 Calling Conventions](../arm64/CALLING_CONVENTIONS.md) - Compare with ARM64

---

## 📚 Next Steps

After mastering calling conventions, explore:

1. **ARM64 Calling Conventions** - Compare with AAPCS64
2. **Inline Assembly in C** - Mixing assembly and C code
3. **System Programming** - Writing low-level system code
4. **Compiler Development** - Understanding how compilers implement calling conventions

---

*Keep coding and learning! 🎯*
