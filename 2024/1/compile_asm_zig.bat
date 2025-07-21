@echo off


set exe_name=zigxassembler.exe
set root=%~dp0
set bin_dir=%root%bin
set obj_dir=%bin_dir%\obj

if not exist %root%\bin\obj mkdir bin\obj

set target=-target x86_64-windows-msvc

set assembler=clang
set assembler_c_flags=-x assembler -c 

set zig_cmd=zig build-obj
set zig_c_flags=-femit-bin=%obj_dir%

set linker=lld-link
set link_libs=ntdll.lib user32.lib kernel32.lib libucrt.lib msvcrt.lib 
set link_flags=/SUBSYSTEM:console 

set files=%obj_dir%\1-asm.obj

REM %obj_dir%\1-zig.obj

%assembler% %assembler_c_flags% %root%1.asm -o %obj_dir%\1-asm.obj
REM %zig_cmd% %zig_c_flags%\1-zig %target% %root%1.zig
REM %linker%  %files% %link_libs% %link_libs% %link_flags% /OUT:%bin_dir%\%exe_name%
lld-link %files% %link_libs% %link_flags% /OUT:%bin_dir%\%exe_name%

