;=============================================================================
; x86-64 Linux System Call: Hello World
; 
; Demonstrates: Raw sys_write system call using Linux x86-64 ABI
; Architecture: x86-64
; Assembler: NASM
; System: Linux
; 
; Build: nasm -f elf64 hello_world.asm -o hello_world.o
;        ld hello_world.o -o hello_world
; Run:   ./hello_world
;=============================================================================

section .data
    hello_msg db 'Hello, World from x86-64 raw syscall!', 0x0A
    hello_len equ $ - hello_msg

section .text
    global _start

_start:
    ; System call: sys_write
    ; rax = syscall number (1 for write)
    ; rdi = file descriptor (1 for stdout)
    ; rsi = buffer address
    ; rdx = buffer length
    
    mov rax, 1          ; sys_write system call number
    mov rdi, 1          ; stdout file descriptor
    mov rsi, hello_msg  ; address of string to write
    mov rdx, hello_len  ; length of string
    syscall             ; invoke system call
    
    ; System call: sys_exit
    ; rax = syscall number (60 for exit)
    ; rdi = exit status
    
    mov rax, 60         ; sys_exit system call number
    xor rdi, rdi        ; exit status 0
    syscall             ; invoke system call
