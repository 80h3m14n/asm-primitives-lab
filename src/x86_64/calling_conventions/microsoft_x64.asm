;=============================================================================
; x86-64 Microsoft x64 Calling Convention Demonstration
; 
; Demonstrates: Windows-style calling convention (for comparison)
; Architecture: x86-64
; Assembler: NASM
; Note: This is for educational purposes - won't run on Linux
; 
; Microsoft x64 ABI:
; - First 4 args in RCX, RDX, R8, R9
; - Additional args on stack (right to left)
; - Callee-saved: RBX, RBP, RDI, RSI, R12-R15
; - Return value in RAX
; - Stack must be 16-byte aligned at call sites
;=============================================================================

section .data
    msg db 'Microsoft x64 calling convention demo', 0x0A, 0

section .text
    global _start

;---------------------------------------------------------------------
; Function: microsoft_add
; Purpose: Add numbers using Microsoft x64 convention
; Input:   rcx, rdx, r8, r9 (first 4 args)
; Output:  rax = sum
;---------------------------------------------------------------------
microsoft_add:
    push rbp
    mov rbp, rsp
    
    ; Save callee-saved registers
    push rbx
    push rsi
    push rdi
    
    ; Sum the register arguments
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

;---------------------------------------------------------------------
; Function: microsoft_function_with_stack
; Purpose: Function with more than 4 arguments
; Input:   rcx, rdx, r8, r9, [stack], [stack+8], etc.
;---------------------------------------------------------------------
microsoft_function_with_stack:
    push rbp
    mov rbp, rsp
    
    ; Access stack arguments
    ; In Microsoft x64, additional args are at [rbp+16], [rbp+24], etc.
    ; Note: This is different from System V AMD64
    
    ; For this demo, just return sum of register args
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9
    
    mov rsp, rbp
    pop rbp
    ret

_start:
    ; This won't actually run on Linux, but demonstrates the concept
    
    ; Set up stack frame
    push rbp
    mov rbp, rsp
    
    ; For Microsoft x64, we need 16-byte stack alignment
    ; Linux uses 16-byte alignment too, but let's ensure it
    sub rsp, 8          ; Ensure 16-byte alignment
    
    ; Call microsoft_add
    mov rcx, 1
    mov rdx, 2
    mov r8, 3
    mov r9, 4
    
    call microsoft_add
    
    ; rax contains sum (10)
    
    ; Restore stack
    add rsp, 8
    
    ; Clean up
    mov rsp, rbp
    pop rbp
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
