;=============================================================================
; x86-64 Stack Operations Demonstration
; 
; Demonstrates: Push, pop, stack pointer manipulation
; Architecture: x86-64
; Assembler: NASM
; System: Linux
; 
; Build: nasm -f elf64 stack_operations.asm -o stack_operations.o
;        ld stack_operations.o -o stack_operations
; Run:   ./stack_operations
;=============================================================================

section .data
    stack_msg db 'Stack operations demonstration', 0x0A
    stack_msg_len equ $ - stack_msg
    
    value1 dq 0x1122334455667788
    value2 dq 0xAABBCCDDEEFF0011
    value3 dq 0x123456789ABCDEF0

section .text
    global _start

_start:
    ; Demonstrate push/pop operations
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Manipulate stack pointer
    sub rsp, 64         ; Allocate 64 bytes on stack
    
    ; Store values on stack
    mov rax, [value1]
    mov [rsp], rax
    mov rax, [value2]
    mov [rsp+8], rax
    mov rax, [value3]
    mov [rsp+16], rax
    
    ; Load values from stack
    mov rax, [rsp]
    mov rbx, [rsp+8]
    mov rcx, [rsp+16]
    
    ; More push operations
    mov rax, 0xDEADBEEFCAFEBABE
    push rax
    push rbx
    push rcx
    
    ; Pop operations
    pop rcx
    pop rbx
    pop rax
    
    ; Restore stack pointer
    add rsp, 64
    
    ; Restore registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    
    ; Print completion message
    mov rax, 1
    mov rdi, 1
    mov rsi, stack_msg
    mov rdx, stack_msg_len
    syscall
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
