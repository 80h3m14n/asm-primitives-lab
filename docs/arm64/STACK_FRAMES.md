# ARM64 Stack Frames - Complete Guide

## 📖 Overview

This guide covers **stack frame management** on ARM64 (AArch64) architecture. While conceptually similar to x86-64, ARM64 has important differences in instruction usage, register naming, and ABI requirements.

---

## 🎯 Key Differences from x86-64

| Feature | x86-64 | ARM64 |
|---------|--------|-------|
| Frame Pointer Register | `rbp` | `x29` (FP) |
| Link Register | `rip` (implicit) | `x30` (LR) |
| Stack Pointer | `rsp` | `sp` |
| Push/Pop Instructions | `push`, `pop` | No dedicated instructions |
| Stack Alignment | 16-byte | 16-byte |
| Prologue Pattern | `push rbp; mov rbp, rsp` | `stp x29, x30, [sp, #-16]!; mov x29, sp` |
| Epilogue Pattern | `mov rsp, rbp; pop rbp` | `ldp x29, x30, [sp], #16` |

---

## 🏗️ ARM64 Stack Frame Structure

A typical ARM64 stack frame looks like this:

```
Higher Addresses
+------------------+
|   Arguments      |  (pushed by caller)
+------------------+
|   Return Address |  (stored in LR/x30 by BL instruction)
+------------------+
|   Saved FP (x29) |  (saved by callee)
+------------------+
|   Saved LR (x30) |  (saved by callee)
+------------------+
|   Local Variables|  (allocated by function)
+------------------+
|   Saved Registers|  (callee-saved: x19-x28)
+------------------+
|   ...            |  (temporary storage)
+------------------+
Lower Addresses
```

---

## 🔧 ARM64 Stack Instructions

### Load/Store Pair Instructions

ARM64 doesn't have dedicated `push` and `pop` instructions. Instead, it uses **store pair** (`stp`) and **load pair** (`ldp`) instructions:

| Instruction | Description | Equivalent x86-64 |
|-------------|-------------|-------------------|
| `stp x1, x2, [sp, #-16]!` | Store x1, x2 to stack, decrement sp by 16 | `push x1; push x2` |
| `ldp x1, x2, [sp], #16` | Load x1, x2 from stack, increment sp by 16 | `pop x2; pop x1` |
| `str x1, [sp, #-8]!` | Store x1 to stack, decrement sp by 8 | `push x1` |
| `ldr x1, [sp], #8` | Load x1 from stack, increment sp by 8 | `pop x1` |

The `!` suffix means **pre-index** (decrement/increment before access).

### Other Stack Instructions

```nasm
sub sp, sp, #N    ; Allocate N bytes on stack
add sp, sp, #N    ; Deallocate N bytes from stack
mov sp, x1        ; Set stack pointer to x1
```

---

## 📝 Standard Prologue and Epilogue

### Function Prologue

The **prologue** sets up the stack frame:

```nasm
; Standard ARM64 prologue
stp x29, x30, [sp, #-16]!  ; Save FP and LR, allocate 16 bytes
mov x29, sp               ; Set new frame pointer
```

This does:
1. Stores `x29` (FP) and `x30` (LR) to the stack
2. Decrements `sp` by 16
3. Sets `x29` to the current `sp` value

### Function Epilogue

The **epilogue** cleans up the stack frame:

```nasm
; Standard ARM64 epilogue
ldp x29, x30, [sp], #16    ; Restore FP and LR, deallocate 16 bytes
ret                         ; Return to caller
```

This does:
1. Loads `x29` and `x30` from the stack
2. Increments `sp` by 16
3. Returns to the caller

### Complete Example

```nasm
my_function:
    ; Prologue
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Save callee-saved registers
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    
    ; Allocate local variable space
    sub sp, sp, #32
    
    ; Function body
    ; ... your code here ...
    
    ; Deallocate local variable space
    add sp, sp, #32
    
    ; Restore callee-saved registers
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    
    ; Epilogue
    ldp x29, x30, [sp], #16
    ret
```

---

## 📝 Code Examples

### Example 1: Simple Function with Stack Frame

See `src/arm64/stack/stack_frame_arm64.asm` for a complete example.

```nasm
section .data
    msg db 'ARM64 stack frame demo', 0x0A
    msg_len equ $ - msg

section .text
    global _start

; Function with stack frame
arm64_function:
    ; Standard prologue
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Save callee-saved registers
    stp x19, x20, [sp, #-16]!
    
    ; Allocate local variable space
    sub sp, sp, #16
    
    ; Use local variables
    str x0, [sp]        ; Store first arg at local var 1
    str x1, [sp, #8]    ; Store second arg at local var 2
    
    ; Do something
    ldr x0, [sp]
    ldr x1, [sp, #8]
    add x0, x0, x1
    
    ; Deallocate local variable space
    add sp, sp, #16
    
    ; Restore callee-saved registers
    ldp x19, x20, [sp], #16
    
    ; Standard epilogue
    ldp x29, x30, [sp], #16
    ret

_start:
    ; Set up stack frame
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Call function
    mov x0, #10
    mov x1, #20
    bl arm64_function
    
    ; Print message
    mov w8, #64         ; __NR_write
    mov x0, #1          ; stdout
    ldr x1, =msg
    ldr x2, =msg_len
    svc #0
    
    ; Clean up
    ldp x29, x30, [sp], #16
    
    ; Exit
    mov w8, #93         ; __NR_exit
    mov x0, #0
    svc #0
```

### Example 2: Nested Function Calls

```nasm
section .text
    global _start

; Level 3 function (deepest)
level3_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Minimal function - just add 100 to input
    add x0, x0, #100
    
    ldp x29, x30, [sp], #16
    ret

; Level 2 function
level2_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #16
    
    ; Call level3
    bl level3_function
    
    ; rax (x0) has result from level3
    add x0, x0, #50
    
    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret

; Level 1 function
level1_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #16
    
    ; Call level2
    mov x0, #42
    bl level2_function
    
    ; x0 has result from level2
    add x0, x0, #25
    
    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret

_start:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Call level1
    bl level1_function
    
    ; x0 has final result
    
    ldp x29, x30, [sp], #16
    
    ; Exit
    mov w8, #93
    mov x0, #0
    svc #0
```

### Example 3: Stack Operations

See `src/arm64/stack/stack_operations_arm64.asm` for push/pop equivalent operations.

```nasm
section .text
    global _start

_start:
    ; Save registers (like push)
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    
    ; Allocate space for local variables
    sub sp, sp, #64
    
    ; Store values on stack
    mov x0, #0xDEADBEEFCAFEBABE
    str x0, [sp]
    mov x1, #0x123456789ABCDEF0
    str x1, [sp, #8]
    
    ; Load values from stack
    ldr x2, [sp]
    ldr x3, [sp, #8]
    
    ; Deallocate space
    add sp, sp, #64
    
    ; Restore registers (like pop)
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16
    
    ; Exit
    mov w8, #93
    mov x0, #0
    svc #0
```

---

## 🔧 Stack Frame Management

### Accessing Function Arguments

With a stack frame, arguments can be accessed relative to `x29` (FP):

```nasm
my_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Arguments (assuming AAPCS64)
    ; x0-x7 are in registers
    ; Additional arguments are on stack
    
    ; 9th argument (if any) is at [x29, #16]
    ; 10th argument (if any) is at [x29, #24]
    ; etc.
    
    ldr x8, [x29, #16]  ; Get 9th argument
    
    ldp x29, x30, [sp], #16
    ret
```

### Accessing Local Variables

Local variables are accessed relative to `sp` or `x29` with **negative offsets**:

```nasm
my_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #32         ; Allocate 32 bytes
    
    ; Local variables
    str x0, [sp]            ; Local var 1
    str x1, [sp, #8]        ; Local var 2
    str x2, [sp, #16]       ; Local var 3
    
    ; Or relative to x29
    str x0, [x29, #-8]      ; Local var 1 (same as [sp])
    str x1, [x29, #-16]     ; Local var 2 (same as [sp, #8])
    
    ; Access local variables
    ldr x3, [sp]
    ldr x4, [sp, #8]
    
    add sp, sp, #32
    ldp x29, x30, [sp], #16
    ret
```

---

## 📊 Register Classification (ARM64)

### Callee-Saved Registers

These registers **must be preserved** by the function (callee):
- `x19`-`x28` - General purpose
- `x29` (FP) - Frame pointer
- `x30` (LR) - Link register (return address)

If your function modifies these, you **must** save and restore them:

```nasm
; Save callee-saved registers
stp x19, x20, [sp, #-16]!
stp x21, x22, [sp, #-16]!
stp x23, x24, [sp, #-16]!
stp x25, x26, [sp, #-16]!
stp x27, x28, [sp, #-16]!

; ... use the registers ...

; Restore callee-saved registers
ldp x27, x28, [sp], #16
ldp x25, x26, [sp], #16
ldp x23, x24, [sp], #16
ldp x21, x22, [sp], #16
ldp x19, x20, [sp], #16
```

### Caller-Saved Registers

These registers **can be modified** by the function (callee). The caller must save them if needed:
- `x0`-`x18` - General purpose (also used for arguments)
- `x29` (FP) - Can be used as general purpose if not using frame pointers
- `x30` (LR) - Can be used if not making function calls

### Special Registers

- `sp` - Stack pointer (must always point to valid stack)
- `pc` - Program counter (read-only in user mode)
- `xzr` - Zero register (always reads as 0, writes are ignored)
- `wsp` - Stack pointer (32-bit version of `sp`)

---

## 🧪 Practical Exercises

### Exercise 1: Frame Pointer Chain

Create a program that walks the frame pointer chain and prints the return addresses.

**Hint**: Each frame's return address is at `[x29, #8]` (the saved LR).

### Exercise 2: Local Array

Create a function that declares a local array and fills it with values.

**Hint**: Allocate space with `sub sp, sp, #N` and access with `[sp, offset]`.

### Exercise 3: Recursive Function

Create a recursive function (e.g., factorial or Fibonacci).

**Hint**: Each recursive call gets its own stack frame. Use `x19`-`x28` for preserved values across calls.

### Exercise 4: Variable Argument Function

Create a function that accepts a variable number of arguments (like `printf`).

**Hint**: Use the stack to access arguments beyond the first 8.

---

## ⚡ Optimization Techniques

### Omitting Frame Pointer

For **leaf functions** (functions that don't call other functions), you can omit the frame pointer:

```nasm
; Without frame pointer
leaf_function:
    sub sp, sp, #16         ; Allocate space only
    ; ... function body ...
    add sp, sp, #16
    ret
```

**Pros**: Saves memory and instructions.

**Cons**: Makes debugging harder (no frame chain to walk).

### Using `stp`/`ldp` for Efficiency

Use pair instructions to save/restore registers efficiently:

```nasm
; Save 4 registers with 2 instructions
stp x19, x20, [sp, #-16]!
stp x21, x22, [sp, #-16]!

; Restore 4 registers with 2 instructions
ldp x21, x22, [sp], #16
ldp x19, x20, [sp], #16
```

---

## 🎯 Best Practices

### 1. Always Maintain Stack Alignment

ARM64 requires **16-byte stack alignment** at all times:

```nasm
; Allocate space (must be multiple of 16)
sub sp, sp, #16

; Deallocate
add sp, sp, #16
```

### 2. Use Frame Pointers for Debugging

Even if optimizing for performance, use frame pointers during development:

```nasm
stp x29, x30, [sp, #-16]!
mov x29, sp
```

This makes debugging with GDB much easier.

### 3. Document Stack Layout

Comment your stack frame layout:

```nasm
my_function:
    stp x29, x30, [sp, #-16]!  ; Save FP and LR
    mov x29, sp               ; Set new FP
    sub sp, sp, #32            ; Allocate 32 bytes
    ; Stack layout:
    ; [sp+0]   - local_var1
    ; [sp+8]   - local_var2
    ; [sp+16]  - local_var3
    ; [sp+24]  - local_var4
```

### 4. Save Callee-Saved Registers

If you modify `x19`-`x28`, `x29`, or `x30`, **always** save and restore them:

```nasm
stp x19, x20, [sp, #-16]!
; ... use x19 and x20 ...
ldp x19, x20, [sp], #16
```

### 5. Use Efficient Memory Access

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

- [ARM64 System Calls](./SYSCALLS.md) - Using system calls in your stack frames
- [ARM64 Calling Conventions](./CALLING_CONVENTIONS.md) - How arguments are passed
- [x86-64 Stack Frames](../x86_64/STACK_FRAMES.md) - Compare with x86-64

---

## 📚 Next Steps

After mastering ARM64 stack frames, explore:

1. **[ARM64 Calling Conventions](./CALLING_CONVENTIONS.md)** - AAPCS64 ABI
2. **Cross-Architecture Development** - Writing portable assembly
3. **ARM64 Assembly Language** - Advanced topics
4. **Kernel Development** - Understanding kernel stack frames

---

*Keep building on ARM64! 💪*
