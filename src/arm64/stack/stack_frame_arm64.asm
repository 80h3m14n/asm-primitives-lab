;=============================================================================
; ARM64 Stack Frame Layout Demonstration
; 
; Demonstrates: ARM64 function prologue, epilogue, and stack frame management
; Architecture: ARM64 (AArch64)
; Assembler: NASM or GAS
; System: Linux
; 
; ARM64 ABI:
; - Stack must be 16-byte aligned
; - Frame pointer (x29) is optional but commonly used
; - Link register (x30) holds return address
; - Callee-saved: x19-x28, x29 (FP), x30 (LR)
;=============================================================================

section .data
    msg db 'ARM64 stack frame demonstration complete!', 0x0A
    msg_len equ $ - msg

section .text
    global _start

;---------------------------------------------------------------------
; Function: arm64_function
; Purpose: Demonstrate ARM64 stack frame setup
; Input:   x0-x7 (first 8 arguments)
;---------------------------------------------------------------------
arm64_function:
    ; Standard ARM64 prologue
    stp x29, x30, [sp, #-16]!  ; Save FP and LR, allocate 16 bytes
    mov x29, sp               ; Set new frame pointer
    
    ; Save callee-saved registers (x19-x28)
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    
    ; Allocate space for local variables
    sub sp, sp, #64           ; 64 bytes for locals
    
    ; Store some values on stack
    str x0, [sp, #0]
    str x1, [sp, #8]
    str x2, [sp, #16]
    
    ; Function body
    ; For this demo, we'll just use the input values
    
    ; Clean up local variable space
    add sp, sp, #64
    
    ; Restore callee-saved registers
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    
    ; Standard epilogue
    ldp x29, x30, [sp], #16    ; Restore FP and LR, deallocate 16 bytes
    ret

;---------------------------------------------------------------------
; Function: nested_function
; Purpose: Function with nested calls
;---------------------------------------------------------------------
nested_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Save some registers
    stp x19, x20, [sp, #-16]!
    
    ; Call another function
    mov x0, #1
    mov x1, #2
    bl level3_function
    
    ; Restore registers
    ldp x19, x20, [sp], #16
    
    ldp x29, x30, [sp], #16
    ret

level3_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Minimal function
    
    ldp x29, x30, [sp], #16
    ret

_start:
    ; Set up initial stack frame
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ; Call nested functions
    mov x0, #0x1122334455667788
    mov x1, #0xAABBCCDDEEFF0011
    bl nested_function
    
    ; Call arm64_function
    mov x0, #1
    mov x1, #2
    mov x2, #3
    bl arm64_function
    
    ; Print completion message using sys_write
    mov w8, #64         ; __NR_write
    mov x0, #1          ; stdout
    ldr x1, =msg        ; message address
    ldr x2, =msg_len    ; message length
    svc #0
    
    ; Clean up
    ldp x29, x30, [sp], #16
    
    ; Exit
    mov w8, #93         ; __NR_exit
    mov x0, #0
    svc #0
