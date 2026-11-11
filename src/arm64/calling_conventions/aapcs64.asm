;=============================================================================
; ARM64 AAPCS64 Calling Convention Demonstration
; 
; Demonstrates: ARM64 procedure call standard (AAPCS64)
; Architecture: ARM64 (AArch64)
; Assembler: NASM or GAS
; System: Linux
; 
; AAPCS64 Rules:
; - First 8 arguments in x0-x7
; - Additional arguments on stack
; - Return value in x0 (or x0:x1 for 128-bit)
; - Callee-saved: x19-x28, x29 (FP), x30 (LR)
; - Caller-saved: x0-x18
; - Stack must be 16-byte aligned
; - Arguments on stack are 8-byte aligned
;=============================================================================

section .data
    result_msg db 'AAPCS64 Result: ', 0
    newline db 0x0A, 0

section .text
    global _start

;---------------------------------------------------------------------
; Function: aapcs64_add
; Purpose: Add multiple numbers using AAPCS64 convention
; Input:   x0-x7 (first 8 arguments)
;          Additional args on stack
; Output:  x0 = sum
;---------------------------------------------------------------------
aapcs64_add:
    ; Standard prologue
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Save callee-saved registers we might use
    stp x19, x20, [sp, #-16]!
    
    ; Initialize sum in x19 (callee-saved)
    mov x19, xzr
    
    ; Add register arguments
    add x19, x19, x0
    add x19, x19, x1
    add x19, x19, x2
    add x19, x19, x3
    add x19, x19, x4
    add x19, x19, x5
    add x19, x19, x6
    add x19, x19, x7
    
    ; Access stack arguments if any
    ; In AAPCS64, stack arguments are at [sp], [sp+8], etc.
    ; But our frame pointer setup means they're at [x29, #16], [x29, #24], etc.
    
    ; For this example, we'll just use the register arguments
    
    ; Return result in x0
    mov x0, x19
    
    ; Restore callee-saved registers
    ldp x19, x20, [sp], #16
    
    ; Standard epilogue
    ldp x29, x30, [sp], #16
    ret

;---------------------------------------------------------------------
; Function: aapcs64_multiply
; Purpose: Multiply two numbers
; Input:   x0 = first number, x1 = second number
; Output:  x0 = product
;---------------------------------------------------------------------
aapcs64_multiply:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    mul x0, x0, x1      ; Multiply and return in x0
    
    ldp x29, x30, [sp], #16
    ret

;---------------------------------------------------------------------
; Function: aapcs64_with_stack
; Purpose: Function with more than 8 arguments (some on stack)
; Input:   x0-x7 = first 8 args, stack = additional args
; Output:  x0 = sum of all args
;---------------------------------------------------------------------
aapcs64_with_stack:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
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
    ; Stack layout: caller pushed args in reverse order
    ; They're at [x29, #16], [x29, #24], etc.
    ldr x0, [x29, #16]   ; 9th argument
    ldr x1, [x29, #24]   ; 10th argument
    add x19, x19, x0
    add x19, x19, x1
    
    mov x0, x19
    
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_start:
    ; Set up stack frame
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Ensure 16-byte stack alignment for calls
    sub sp, sp, #16
    
    ; Call aapcs64_add with 8 arguments
    mov x0, #1
    mov x1, #2
    mov x2, #3
    mov x3, #4
    mov x4, #5
    mov x5, #6
    mov x6, #7
    mov x7, #8
    
    bl aapcs64_add
    
    ; x0 contains sum (36)
    ; Save it
    mov x19, x0
    
    ; Call aapcs64_multiply
    mov x0, #10
    mov x1, #5
    bl aapcs64_multiply
    
    ; x0 contains 50
    ; Restore stack alignment
    add sp, sp, #16
    
    ; For demonstration, print a message
    mov w8, #64         ; __NR_write
    mov x0, #1          ; stdout
    ldr x1, =result_msg
    mov x2, #12         ; length
    svc #0
    
    ; Print newline
    mov w8, #64
    mov x0, #1
    ldr x1, =newline
    mov x2, #1
    svc #0
    
    ; Clean up
    ldp x29, x30, [sp], #16
    
    ; Exit
    mov w8, #93         ; __NR_exit
    mov x0, #0
    svc #0
