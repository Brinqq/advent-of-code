# exports
.global main

//

//TODO: Maybe test a memory mapping soultion over fread(). https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createfilemappinga

.section .data
file_name: .asciz "C:/main/.dev/projects/advent-of-code/2024/1/data.txt"
file_mode_r: .asciz "rb"

anon_str0: .asciz "empty"
anon_str1: .asciz "uint64: %lu\n"
.anon_str2: .asciz "Test: %s\n"
.anon_str3: .asciz "q:%lu, r:%lu\n"
.anon_str4: .asciz "%c\n"

err_str0: .asciz "failed to allocate memory.\n"


// Messed up function stack to lazy this is tmp smh...
.align 64
.out_buffer1:
.space 5000
.out_buffer2:
.space 5000


.section .text

# zig extern

# C std externs
.extern fopen
.extern fclose
.extern fseek
.extern malloc
.extern free
.extern fgets

.equ SEEK_END, 0x2
.equ SEEK_START, 0x0

//@params *adr buffer, bytes
_debug_print_buffer:
  callq printf
  ret

//@params: *adr _src1, *adr _src2, *adr _dst
_sub_buffers:
  pushq %rbp
  subq $64 ,%rsp

  addq $64 ,%rsp
  popq %rbp
  ret

//@params *adr src, *adr ds1, *adr dst2
_shuffle_interleaved_buffer:
  push %rbp
  movq %rsp, %rbp
  subq $64, %rsp
  movq %rcx, 16(%rbp)
  
  
  addq $64, %rsp
  pop %rbp
  ret

//@params: *adr filestream, uint64 filestream_size | @returns: *adr[] result
_fread_solution:
  push %rbp
  movq %rsp, %rbp
  movq %rcx, 24(%rbp)
  movq %rdx, 16(%rbp)
  subq $80, %rsp

  //alloc enough memory for filestream_size
  movq 16(%rbp), %rcx
  callq malloc
  movq %rax, (%rbp)
  cmpq $0, %rax
  je malloc_err_lbl

  //read data into the allocated memory block.
  movq $15, %rcx
  movq $0, %rdx
  movq 16(%rbp), %rax
  divq %rcx
  cmp $0, %rdx
  jne .a.err1
  movq %rax, -8(%rbp)

  xor %r9, %r9
  movq %r9, -16(%rbp)
  .a.loop0:
  movq -8(%rbp), %r8
  movq -16(%rbp), %r9
  cmp %r9, %r8
  je .a.skip0

  //hardcoded line read info. 
  //TODO: maybe read more lines per call, pack to avx registers? Also fix the hardcoded stuff.
  leaq -45(%rbp), %rcx 
  movq $16, %rdx
  # movq $1, %r8
  movq 24(%rbp), %r8
  callq fgets

  movq -16(%rbp), %rax
  movq $5, %rdi
  mulq %rdi
  push %rax


  //offsets: 37 - 45

  leaq .out_buffer1(%rip), %rcx
  addq %rax, %rcx
  movb -45(%rbp), %bl
  movb %bl, (%rcx)

  leaq .out_buffer2(%rip), %rcx
  addq %rax, %rcx
  movb -37(%rbp), %bl
  movb %bl, (%rcx)
  pop %rax

  # leaq .anon_str2(%rip) ,%rcx
  # leaq -45(%rbp), %rdx
  # leaq .anon_str4(%rip) ,%rcx
  # movb -37(%rbp), %dl
  # callq printf


  # movb -33%(rbp), .out_buffer2(%rip)

  movq -16(%rbp), %r9
  inc %r9
  movq %r9, -16(%rbp)
  jmp .a.loop0

  callq _sub_buffers

  .a.skip0:

  movq (%rbp), %rcx
  callq free

  xor %rax, %rax;
  .a.return:
  addq $80, %rsp
  pop %rbp
  ret


  malloc_err_lbl:
  leaq err_str0(%rip), %rcx
  call printf
  jmp .a.return

  .a.err1:
  movq $1, %rax
  jmp .a.return

# test stack frame for reference. offset relative to rsp low/high.
#
# caller stack frame bytes: 72
# [caller stack - offset: 40-72]
# [shadow stack - offset: 8-40]
# [return adr - offset: 0-8]
# [calles stack]
# [............]


# file data layout in memory
#
# [x5(char)value] [x3(char)whitspace] [x5(char)value] [1x(encoded as 2 bytes on windows)\n] or - [xxxxx   xxxxx\r\n]

  main:
      subq $72, %rsp

      //open file
      leaq file_name(%rip), %rcx
      leaq file_mode_r(%rip), %rdx
      callq fopen
      movq %rax, 64(%rsp)

      //get file size
      movq %rax, %rcx
      call ftell
      movq %rax, 56(%rsp)

      movq 64(%rsp), %rcx
      movl $0, %edx
      movl $SEEK_END, %r8d
      call fseek
      cmp $0, %rax
      jne error_lbl

      movq 64(%rsp), %rcx
      call ftell
      movq 56(%rsp), %rsi
      subq %rax, %rsi
      movq %rax, 56(%rsp)

      # movq %rax, %rdx
      # leaq anon_str1(%rip), %rcx
      # call printf
    

      //seek start
      movq 64(%rsp), %rcx
      movl $0, %edx
      movl $SEEK_START, %r8d
      call fseek
      cmp $0, %rax
      jne error_lbl

      movq 64(%rsp), %rcx
      movq 56(%rsp), %rdx
      callq _fread_solution
      

      //close file
      movq 64(%rsp), %rcx
      callq fclose

      //return
      xor %rax, %rax
      addq $72, %rsp
      retq

      error_lbl:
      mov $1, %rax
      addq $72, %rsp
      retq
