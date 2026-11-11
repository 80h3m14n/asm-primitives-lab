# ARM64 Calling Conventions - Complete Guide

## 📖 Overview

This guide covers the **AAPCS64** (ARM 64-bit Procedure Call Standard) calling convention used on ARM64 (AArch64) architecture. This is the standard calling convention for Linux, macOS, Windows, and other operating systems on ARM64.

---

## 🎯 Key Differences from x86-64

| Feature | x86-64 (System V) | ARM64 (AAPCS64) |
|---------|-------------------|-----------------|
| Integer Arg Registers | rdi, rsi, rdx, rcx, r8, r9 | x0-x7 |
| Floating-Point Arg Registers | xmm0-xmm7 | q0-q7 |
| Max Register Args | 6 (integer) + 8 (FP) | 8 (integer) + 8 (FP) |
| Stack Direction | Right to left | Right to left |
| Shadow Space | No | No |
| Stack Cleanup | Caller | Caller |
| Stack Alignment | 16-byte | 16-byte |
| Return Integer | rax, rdx | x0, x1 |
| Return Float | xmm0, xmm1 | q0, q1 |
| Frame Pointer | rbp | x29 |
| Link Register | rip (implicit) | x30 |

---

## 🏗️ AAPCS64 Overview

### Register Usage

#### Argument Registers

| Register | Purpose | Description |
|----------|---------|-------------|
| `x0`-`x7` | Integer/Pointer Arguments | First 8 integer or pointer arguments |
| `q0`-`q7` | Floating-Point Arguments | First 8 floating-point or SIMD arguments |
| `x8`-`x15` | Scratch Registers | Temporary storage |
| `x16`-`x17` | Intra-Procedure-Call Scratch | Temporary, may be used by linker |
| `x18` | Platform Register | Special purpose (e.g., thread local storage) |
| `x19`-`x28` | Callee-Saved | Must be preserved by callee |
| `x29` (FP) | Frame Pointer | Optional, but commonly used |
| `x30` (LR) | Link Register | Return address |
| `sp` | Stack Pointer | Must be 16-byte aligned |

#### Return Registers

| Register | Purpose | Description |
|----------|---------|-------------|
| `x0` | Integer Return | Primary 64-bit integer return value |
| `x1` | Integer Return 2 | Secondary 64-bit integer return value |
| `q0` | Float Return | Primary 128-bit floating-point return value |
| `q1` | Float Return 2 | Secondary 128-bit floating-point return value |

### Stack Usage

For arguments beyond the first 8:
- Pushed onto stack **right to left** (last argument first)
- Each argument is 8-byte aligned
- Caller cleans up the stack

### Register Preservation

| Register | Preserved By | Notes |
|----------|--------------|-------|
| `x0`-`x15` | Caller | Caller-saved (scratch) |
| `x16`, `x17` | Caller | Intra-procedure-call scratch |
| `x18` | Platform | Platform-defined |
| `x19`-`x28` | Callee | Callee-saved |
| `x29` (FP) | Callee | Optional frame pointer |
| `x30` (LR) | Callee | Link register (return address) |
| `sp` | Both | Stack pointer |

---

## 📝 Code Examples

### Example 1: Simple Function Call

See `src/arm64/calling_conventions/aapcs64.asm` for a complete example.

```nasm
section .text
    global _start

; Function: add_numbers
; Purpose: Add two numbers
; Input: x0 = a, x1 = b
; Output: x0 = a + b

add_numbers:
    ; Prologue
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Function body
    add x0, x0, x1
    
    ; Epilogue
    ldp x29, x30, [sp], #16
    ret

_start:
    ; Set up stack frame
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Call add_numbers
    mov x0, #10
    mov x1, #20
    bl add_numbers
    
    ; x0 contains 30
    
    ; Clean up
    ldp x29, x30, [sp], #16
    
    ; Exit
    mov w8, #93         ; __NR_exit
    mov x0, #0
    svc #0
```

### Example 2: Function with 8 Arguments

```nasm
; Function: add_eight_numbers
; Purpose: Add eight numbers
; Input: x0-x7 = eight numbers
; Output: x0 = sum

add_eight_numbers:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Sum all register arguments
    add x0, x0, x1
    add x0, x0, x2
    add x0, x0, x3
    add x0, x0, x4
    add x0, x0, x5
    add x0, x0, x6
    add x0, x0, x7
    
    ldp x29, x30, [sp], #16
    ret

; Caller
caller_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Set up arguments
    mov x0, #1
    mov x1, #2
    mov x2, #3
    mov x3, #4
    mov x4, #5
    mov x5, #6
    mov x6, #7
    mov x7, #8
    
    bl add_eight_numbers
    
    ; x0 contains sum (36)
    
    ldp x29, x30, [sp], #16
    ret
```

### Example 3: Function with Stack Arguments

```nasm
; Function: add_twelve_numbers
; Purpose: Add twelve numbers (8 in registers, 4 on stack)
; Input: x0-x7 (args 1-8), [sp] (arg9), [sp+8] (arg10), [sp+16] (arg11), [sp+24] (arg12)
; Output: x0 = sum

add_twelve_numbers:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Save callee-saved registers
    stp x19, x20, [sp, #-16]!
    
    ; Sum register arguments
    add x19, x0, x1
    add x19, x19, x2
    add x19, x19, x3
    add x19, x19, x4
    add x19, x19, x5
    add x19, x19, x6
    add x19, x19, x7
    
    ; Sum stack arguments
    ; Stack layout: [x29, #16] = arg9, [x29, #24] = arg10, etc.
    ldr x0, [x29, #16]
    ldr x1, [x29, #24]
    ldr x2, [x29, #32]
    ldr x3, [x29, #40]
    
    add x19, x19, x0
    add x19, x19, x1
    add x19, x19, x2
    add x19, x19, x3
    
    mov x0, x19
    
    ; Restore callee-saved registers
    ldp x19, x20, [sp], #16
    
    ldp x29, x30, [sp], #16
    ret

; Caller
caller_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Push stack arguments (right to left)
    mov x0, #12
    push x0            ; arg12
    mov x0, #11
    push x0            ; arg11
    mov x0, #10
    push x0            ; arg10
    mov x0, #9
    push x0            ; arg9
    
    ; Set register arguments
    mov x0, #1
    mov x1, #2
    mov x2, #3
    mov x3, #4
    mov x4, #5
    mov x5, #6
    mov x6, #7
    mov x7, #8
    
    ; Ensure 16-byte stack alignment
    sub sp, sp, #0      ; Already aligned (4 pushes = 32 bytes)
    
    bl add_twelve_numbers
    
    ; Clean up stack arguments
    add sp, sp, #32     ; 4 * 8 = 32 bytes
    
    ; x0 contains sum
    
    ldp x29, x30, [sp], #16
    ret
```

### Example 4: Function with Callee-Saved Registers

```nasm
; Function: process_data
; Purpose: Process data using callee-saved registers
; Input: x0 = pointer to data, x1 = length
; Output: x0 = result

process_data:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Save callee-saved registers we'll use
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    
    ; Use callee-saved registers
    mov x19, x0          ; Save data pointer
    mov x20, x1          ; Save length
    mov x21, xzr         ; Initialize accumulator
    
    mov x22, xzr         ; Initialize counter
    
.process_loop:
    cmp x22, x20
    b.ge .done
    
    ldrb w0, [x19, x22]  ; Load byte
    add x21, x21, x0     ; Add to accumulator
    add x22, x22, #1     ; Increment counter
    b .process_loop
    
.done:
    mov x0, x21          ; Return accumulator
    
    ; Restore callee-saved registers
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    
    ldp x29, x30, [sp], #16
    ret
```

---

## 🔍 Argument Classification

### Data Types and Classes

AAPCS64 classifies arguments into **types** and **classes**:

| Type | Class | Registers |
|------|-------|-----------|
| Integer, pointer, boolean, char, short, int, long | Integer | x0-x7 |
| float, double | Float | q0-q7 |
| struct (8 bytes or less) | Integer | x0-x7 |
| struct (16 bytes or less) | Integer | x0:x1, x2:x3, etc. |
| struct (> 16 bytes) | Memory | Passed as pointer |
| array | Memory | Passed as pointer |

### Composite Types

For **structures** and **unions**:
- If the structure is **8 bytes or less**: Passed like an integer
- If the structure is **16 bytes or less**: Passed in two registers (e.g., x0 and x1)
- If the structure is **larger than 16 bytes**: A **pointer** to the structure is passed instead

For **arrays**: Always passed as pointers.

### Floating-Point and SIMD

- `float` and `double`: Passed in `q0`-`q7` (or `s0`-`s7` for float, `d0`-`d7` for double)
- SIMD vectors: Passed in `q0`-`q7`

---

## 🧪 Practical Exercises

### Exercise 1: Function with Mixed Argument Types

Create a function that takes:
- 2 integer arguments (in x0, x1)
- 2 floating-point arguments (in q0, q1)
- 1 structure argument (> 16 bytes, so passed as pointer)

### Exercise 2: Variadic Function

Create a variadic function (like `printf`) that:
- Takes a format string in x0
- Takes variable arguments on the stack
- Processes them according to the format

### Exercise 3: Call C Function from Assembly

Create an ARM64 assembly program that calls a C function (e.g., `printf`).

**Hint**: Follow the AAPCS64 for argument passing.

### Exercise 4: Return Structure

Create a function that returns:
- An 8-byte structure
- A 16-byte structure
- A > 16-byte structure

---

## ⚡ Optimization Techniques

### 1. Tail Call Optimization

If a function's last action is calling another function, you can reuse the stack frame:

```nasm
; Without tail call optimization
foo:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    ; ...
    bl bar
    ldp x29, x30, [sp], #16
    ret

; With tail call optimization
foo:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    ; ...
    ; Instead of bl + ret, use b
    b bar  ; Tail call - reuse current stack frame
```

**Warning**: This is only safe if the caller's stack frame layout is compatible with the callee's expectations.

### 2. Inline Functions

For very small functions, the caller can inline the function body:

```nasm
; Instead of:
; bl small_function

; Inline:
; add x0, x0, #10
; (instead of calling a function that does this)
```

### 3. Argument Passing Optimization

If you control both caller and callee, optimize argument passing:

```nasm
; Instead of storing to stack then loading:
; str x0, [sp, #-8]!
; bl some_function

; Pass directly in register:
; bl some_function
```

---

## 🎯 Best Practices

### 1. Follow AAPCS64

Always follow the AAPCS64 for:
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
; Input: x0 = a, x1 = b
; Output: x0 = a + b
; Clobbers: x0
; Preserves: x19-x28, x29, x30
add_numbers:
    add x0, x0, x1
    ret
```

### 4. Preserve Callee-Saved Registers

If you modify `x19`-`x28`, `x29`, or `x30`, **always** save and restore them:

```nasm
my_function:
    stp x19, x20, [sp, #-16]!
    ; ... use x19 and x20 ...
    ldp x19, x20, [sp], #16
    ret
```

### 5. Ensure Stack Alignment

Always ensure the stack is 16-byte aligned before calling functions:

```nasm
; Before calling a function
sub sp, sp, #0      ; Ensure 16-byte alignment (adjust as needed)
bl some_function
add sp, sp, #0      ; Restore if adjusted
```

### 6. Use Efficient Memory Access

Use `stp`/`ldp` for pairs of registers:

```nasm
; Instead of:
str x19, [sp, #-16]!
str x20, [sp, #-8]!

; Use:
stp x19, x20, [sp, #-16]!
```

---

## 🔗 Related Topics

- [ARM64 System Calls](./SYSCALLS.md) - Using system calls with calling conventions
- [ARM64 Stack Frames](./STACK_FRAMES.md) - How stack frames support calling conventions
- [x86-64 Calling Conventions](../x86_64/CALLING_CONVENTIONS.md) - Compare with System V AMD64

---

## 📚 Next Steps

After mastering AAPCS64, explore:

1. **Cross-Architecture Development** - Writing portable assembly
2. **Inline Assembly in C** - Mixing assembly and C code
3. **System Programming** - Writing low-level system code
4. **Compiler Development** - Understanding how compilers implement AAPCS64

---

*Keep coding on ARM64! 🎯*
