;=============================================================================
; x86-64 System V AMD64 Calling Convention Demonstration
; 
; Demonstrates: Register passing, stack passing, callee-saved registers
; Architecture: x86-64
; Assembler: NASM
; System: Linux
; Calling Convention: System V AMD64 ABI
; 
; Build: nasm -f elf64 system_v_amd64.asm -o system_v_amd64.o
;        ld system_v_amd64.o -o system_v_amd64
; Run:   ./system_v_amd64
;=============================================================================

section .data
    result_msg db 'Result: ', 0
    newline db 0x0A, 0

section .text
    global _start

;---------------------------------------------------------------------
; Function: add_numbers
; Purpose: Add multiple numbers using System V AMD64 convention
; Input:   rdi, rsi, rdx, rcx, r8, r9 (first 6 args in registers)
;          Additional args on stack
; Output:  rax = sum
; Registers: rbp, rbx, r12-r15 are callee-saved
;---------------------------------------------------------------------
add_numbers:
    push rbp            ; Save base pointer
    mov rbp, rsp        ; Set new base pointer
    
    ; Save callee-saved registers
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Initialize sum in rbx (callee-saved)
    xor rbx, rbx
    
    ; Add first 6 arguments from registers
    add rbx, rdi
    add rbx, rsi
    add rbx, rdx
    add rbx, rcx
    add rbx, r8
    add rbx, r9
    
    ; Add additional arguments from stack
    ; Stack layout at this point:
    ; [rbp+16] - 7th argument
    ; [rbp+24] - 8th argument
    ; etc.
    
    ; For this example, we'll just handle the register arguments
    
    ; Restore callee-saved registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    
    ; Return result in rax
    mov rax, rbx
    
    ; Restore base pointer and return
    mov rsp, rbp
    pop rbp
    ret

;---------------------------------------------------------------------
; Function: multiply_numbers
; Purpose: Multiply two numbers
; Input:   rdi = first number, rsi = second number
; Output:  rax = product
;---------------------------------------------------------------------
multiply_numbers:
    push rbp
    mov rbp, rsp
    
    ; Save callee-saved registers (though we don't use any here)
    
    mov rax, rdi
    imul rax, rsi
    
    mov rsp, rbp
    pop rbp
    ret

;---------------------------------------------------------------------
; Function: print_number (simplified for this demo)
; Purpose: Print a number (simplified - just prints a message)
; Input:   rdi = number to print
;---------------------------------------------------------------------
print_number:
    push rbp
    mov rbp, rsp
    
    ; For simplicity, just print a static message
    mov rax, 1
    mov rdi, 1
    mov rsi, result_msg
    mov rdx, 8
    syscall
    
    mov rsp, rbp
    pop rbp
    ret

_start:
    ; Set up stack frame
    push rbp
    mov rbp, rsp
    
    ; Call add_numbers with 6 arguments
    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    mov rcx, 4
    mov r8, 5
    mov r9, 6
    
    call add_numbers
    
    ; rax now contains the sum (21)
    ; Save it for later
    push rax
    
    ; Call multiply_numbers
    mov rdi, 10
    mov rsi, 5
    call multiply_numbers
    
    ; rax now contains 50
    ; Pop the saved sum
    pop rdi
    
    ; Call print_number with the sum
    mov rdi, rax
    call print_number
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    ; Clean up
    mov rsp, rbp
    pop rbp
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
