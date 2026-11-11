;=============================================================================
; ARM64 Stack Operations Demonstration
; 
; Demonstrates: ARM64 push/pop equivalent operations using store/load
; Architecture: ARM64 (AArch64)
; Assembler: NASM or GAS
; System: Linux
; 
; Note: ARM64 doesn't have push/pop instructions like x86
; Instead, it uses str (store) and ldr (load) with pre-decrement/post-increment
;=============================================================================

section .data
    stack_msg db 'ARM64 stack operations demonstration', 0x0A
    stack_msg_len equ $ - stack_msg
    
    value1 dq 0x1122334455667788
    value2 dq 0xAABBCCDDEEFF0011
    value3 dq 0x123456789ABCDEF0

section .text
    global _start

_start:
    ; ARM64 stack operations
    ; Instead of push, we use: stp reg1, reg2, [sp, #-16]!
    ; Instead of pop, we use: ldp reg1, reg2, [sp], #16
    
    ; Save registers (like push)
    stp x0, x1, [sp, #-16]!   ; Push x0 and x1
    stp x2, x3, [sp, #-16]!   ; Push x2 and x3
    stp x4, x5, [sp, #-16]!   ; Push x4 and x5
    
    ; Store values on stack
    ldr x0, =value1
    ldr x1, [x0]
    str x1, [sp, #-16]!       ; Allocate space and store
    
    ldr x0, =value2
    ldr x1, [x0]
    str x1, [sp, #-16]!
    
    ldr x0, =value3
    ldr x1, [x0]
    str x1, [sp, #-16]!
    
    ; Load values from stack
    ldr x0, [sp], #16        ; Pop into x0
    ldr x1, [sp], #16        ; Pop into x1
    ldr x2, [sp], #16        ; Pop into x2
    
    ; Restore registers (like pop)
    ldp x4, x5, [sp], #16     ; Pop x4 and x5
    ldp x2, x3, [sp], #16     ; Pop x2 and x3
    ldp x0, x1, [sp], #16     ; Pop x0 and x1
    
    ; More stack operations
    ; Allocate space for local variables
    sub sp, sp, #64           ; Allocate 64 bytes
    
    ; Use the space
    mov x0, #0xDEADBEEFCAFEBABE
    str x0, [sp]
    mov x1, #0x123456789ABCDEF0
    str x1, [sp, #8]
    
    ; Load back
    ldr x2, [sp]
    ldr x3, [sp, #8]
    
    ; Deallocate
    add sp, sp, #64
    
    ; Print completion message
    mov w8, #64             ; __NR_write
    mov x0, #1              ; stdout
    ldr x1, =stack_msg      ; message address
    ldr x2, =stack_msg_len  ; message length
    svc #0
    
    ; Exit
    mov w8, #93             ; __NR_exit
    mov x0, #0
    svc #0
