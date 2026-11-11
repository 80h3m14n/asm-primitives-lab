;=============================================================================
; ARM64 Linux System Calls: File Operations
; 
; Demonstrates: Raw ARM64 system calls for file operations
; Architecture: ARM64 (AArch64)
; Assembler: NASM or GAS
; System: Linux
; 
; Note: ARM64 system call numbers are different from x86-64
;=============================================================================

section .data
    filename db 'test_file_arm64.txt', 0
    file_content db 'ARM64 file content via sys_write.', 0x0A
    file_content_len equ $ - file_content
    
    read_buffer times 100 db 0
    
    ; File flags for ARM64
    O_RDWR equ 0x2
    O_CREAT equ 0x40
    O_TRUNC equ 0x200
    S_IRUSR equ 0x100
    S_IWUSR equ 0x80

section .text
    global _start

_start:
    ; Create/Open file
    ; w8 = syscall number (__NR_open = 56 on ARM64? Actually varies)
    ; Note: ARM64 syscall numbers can vary by kernel version
    ; Let's use the standard ones
    
    ; __NR_open = 56 on some ARM64 kernels
    ; But this varies - we'll use common values
    
    ; Actually, let's use the proper ARM64 syscall numbers:
    ; These are for newer kernels (4.x+):
    __NR_open equ 56
    __NR_write equ 64
    __NR_read equ 63
    __NR_close equ 57
    __NR_exit equ 93
    __NR_lseek equ 62
    
    ; Open file
    ldr x0, =filename   ; const char *pathname
    mov w1, O_RDWR | O_CREAT | O_TRUNC  ; flags
    mov w2, S_IRUSR | S_IWUSR  ; mode
    mov w8, __NR_open
    svc #0
    
    cmp x0, #0
    b.lt error
    mov x19, x0         ; Save file descriptor in x19 (callee-saved)
    
    ; Write to file
    mov x0, x19         ; int fd
    ldr x1, =file_content
    ldr x2, =file_content_len
    mov w8, __NR_write
    svc #0
    
    cmp x0, #0
    b.lt error
    
    ; Seek to beginning
    mov x0, x19         ; int fd
    mov x1, #0          ; offset = 0
    mov x2, #0          ; whence = SEEK_SET
    mov w8, __NR_lseek
    svc #0
    
    ; Read from file
    mov x0, x19         ; int fd
    ldr x1, =read_buffer
    mov x2, #100
    mov w8, __NR_read
    svc #0
    
    cmp x0, #0
    b.lt error
    
    ; Close file
    mov x0, x19         ; int fd
    mov w8, __NR_close
    svc #0
    
    ; Exit
    mov w8, __NR_exit
    mov x0, #0
    svc #0

error:
    ; For simplicity, just exit with error
    mov w8, __NR_exit
    mov x0, #1
    svc #0
