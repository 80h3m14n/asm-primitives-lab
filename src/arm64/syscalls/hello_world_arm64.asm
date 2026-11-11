;=============================================================================
; ARM64 Linux System Call: Hello World
; 
; Demonstrates: Raw sys_write system call using ARM64 ABI
; Architecture: ARM64 (AArch64)
; Assembler: NASM (with ARM64 support) or use GAS syntax
; System: Linux
; 
; Note: ARM64 uses different system call numbers than x86-64
; System calls are invoked via 'svc #0' instruction
; System call number goes in w8 register
; Arguments in x0-x5 registers
; 
; Build: nasm -f elf64 hello_world_arm64.asm -o hello_world_arm64.o
;        ld hello_world_arm64.o -o hello_world_arm64
;        Note: May need ARM64 toolchain
;=============================================================================

section .data
    hello_msg db 'Hello, World from ARM64 raw syscall!', 0x0A
    hello_len equ $ - hello_msg

section .text
    global _start

_start:
    ; System call: sys_write
    ; w8 = syscall number (64 for write on ARM64)
    ; x0 = file descriptor (1 for stdout)
    ; x1 = buffer address
    ; x2 = buffer length
    
    mov w8, #64         ; __NR_write syscall number for ARM64
    mov x0, #1          ; stdout file descriptor
    ldr x1, =hello_msg ; address of string to write
    ldr x2, =hello_len  ; length of string
    svc #0              ; invoke system call (supervisor call)
    
    ; System call: sys_exit
    ; w8 = syscall number (93 for exit on ARM64)
    ; x0 = exit status
    
    mov w8, #93         ; __NR_exit syscall number for ARM64
    mov x0, #0          ; exit status 0
    svc #0              ; invoke system call
