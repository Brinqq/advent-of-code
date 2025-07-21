# exports
.global main

//

//TODO: Maybe test a memory mapping soultion over fread(). https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createfilemappinga

.section .data
.align 64
file_name: .asciz "C:/main/.dev/projects/advent-of-code/2024/1/data.txt"
file_mode_r: .asciz "rb"

anon_str0: .asciz "empty"
anon_str1: .asciz "uint64: %lu\n"

err_str0: .asciz "failed to allocate memory.\n"

.section .text

# zig extern

# C std externs
.extern fopen
.extern fclose
.extern fseek
.extern malloc

.equ SEEK_END, 0x2
.equ SEEK_START, 0x0

//@params: *adr _src1, *adr _src2, *adr _dst
_sub_buffers:
  ret

//@params *adr src, *adr ds1, *adr dst2
_shuffle_interleaved_buffer:
  ret

//@params: *adr filestream, uint64 filestream_size | @returns: *adr[] result
_fread_solution:
  movq %rcx, 24(%rsp)
  movq %rdx, 16(%rsp)
  subq $56, %rsp

  //alloc enough memory for filestream_size
  movq 72(%rsp), %rcx
  callq malloc
  movq %rax, 40(%rsp)
  cmpq $0, %rax
  je malloc_err_lbl

  //read data into the allocated memory block.
  movq $15, %rcx
  movq $0, %rdx
  movq 72(%rsp), %rax
  divq %rcx

  movq $12, %r8
  movq $15, %rdx
  movq 40(%rsp), %rcx
  movq 80(%rsp), %r9
  callq fread

  movq 40(%rsp), %rcx
  callq free

  addq $56, %rsp
  xor %rax, %rax;
  ret

  malloc_err_lbl:
  leaq err_str0(%rip), %rcx
  call printf
  addq $56, %rsp
  xor %rax, %rax;

  ret

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

P   A   H   N
A P L S I I G
Y   I   R
