;=============================================================================
; x86-64 Linux System Calls: File Operations
; 
; Demonstrates: Raw sys_open, sys_read, sys_write, sys_close system calls
; Architecture: x86-64
; Assembler: NASM
; System: Linux
; 
; Build: nasm -f elf64 file_operations.asm -o file_operations.o
;        ld file_operations.o -o file_operations
; Run:   ./file_operations
;=============================================================================

section .data
    filename db 'test_file.txt', 0
    file_content db 'This is a test file content written via sys_write.', 0x0A
    file_content_len equ $ - file_content
    
    read_buffer times 100 db 0
    
    ; Messages
    open_msg db 'File opened successfully', 0x0A, 0
    read_msg db 'File read successfully', 0x0A, 0
    write_msg db 'File written successfully', 0x0A, 0
    close_msg db 'File closed successfully', 0x0A, 0
    error_msg db 'Error: ', 0
    
    ; File flags
    O_RDWR equ 0x2      ; Read/Write
    O_CREAT equ 0x40    ; Create if not exists
    O_TRUNC equ 0x200   ; Truncate file
    S_IRUSR equ 0x100   ; Read permission for owner
    S_IWUSR equ 0x80    ; Write permission for owner

section .text
    global _start

_start:
    ; Create/Open file
    mov rax, 2          ; sys_open
    mov rdi, filename   ; const char *pathname
    mov rsi, O_RDWR | O_CREAT | O_TRUNC  ; flags
    mov rdx, S_IRUSR | S_IWUSR  ; mode
    syscall
    
    cmp rax, 0
    jl error
    mov r8, rax         ; Save file descriptor in r8
    
    ; Write to file
    mov rax, 1          ; sys_write
    mov rdi, r8         ; int fd
    mov rsi, file_content
    mov rdx, file_content_len
    syscall
    
    cmp rax, 0
    jl error
    
    ; Seek to beginning
    mov rax, 8          ; sys_lseek
    mov rdi, r8         ; int fd
    xor rsi, rsi        ; offset = 0
    xor rdx, rdx        ; whence = SEEK_SET
    syscall
    
    ; Read from file
    mov rax, 0          ; sys_read
    mov rdi, r8         ; int fd
    mov rsi, read_buffer
    mov rdx, 100
    syscall
    
    cmp rax, 0
    jl error
    
    ; Close file
    mov rax, 3          ; sys_close
    mov rdi, r8         ; int fd
    syscall
    
    ; Exit
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; exit status 0
    syscall

error:
    ; Print error message
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, 7
    syscall
    
    ; Exit with error
    mov rax, 60
    mov rdi, 1
    syscall
