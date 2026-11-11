;=============================================================================
; x86-64 Stack Frame Layout Demonstration
; 
; Demonstrates: Function prologue, epilogue, and stack frame management
; Architecture: x86-64
; Assembler: NASM
; System: Linux
; 
; Build: nasm -f elf64 stack_frame.asm -o stack_frame.o
;        ld stack_frame.o -o stack_frame
; Run:   ./stack_frame
;=============================================================================

section .data
    msg db 'Stack frame demonstration complete!', 0x0A
    msg_len equ $ - msg

section .text
    global _start

; External function to call
print_message:
    ; Standard prologue
    push rbp            ; Save base pointer
    mov rbp, rsp        ; Set new base pointer
    sub rsp, 16         ; Allocate space for local variables
    
    ; Save caller-saved registers
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    
    ; Function body
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg        ; message address
    mov rdx, msg_len    ; message length
    syscall
    
    ; Restore caller-saved registers
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    
    ; Standard epilogue
    mov rsp, rbp        ; Restore stack pointer
    pop rbp             ; Restore base pointer
    ret

; Function with nested calls
level2_function:
    push rbp
    mov rbp, rsp
    sub rsp, 32         ; Allocate 32 bytes on stack
    
    ; Store some values on stack
    mov [rbp-8], rax
    mov [rbp-16], rbx
    mov [rbp-24], rcx
    
    ; Call another function
    call level3_function
    
    ; Clean up
    mov rsp, rbp
    pop rbp
    ret

level3_function:
    push rbp
    mov rbp, rsp
    
    ; Minimal function - just return
    mov rsp, rbp
    pop rbp
    ret

_start:
    ; Set up initial stack frame
    push rbp
    mov rbp, rsp
    
    ; Call nested functions
    mov rax, 0x1122334455667788
    mov rbx, 0xAABBCCDDEEFF0011
    mov rcx, 0x123456789ABCDEF0
    
    call level2_function
    
    ; Call print function
    call print_message
    
    ; Clean up and exit
    mov rsp, rbp
    pop rbp
    
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; exit status 0
    syscall
