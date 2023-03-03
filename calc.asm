; vim:ft=nasm

%include 'functions.asm'


section .rodata
  menu_item1 db '1. Multiplicar', 0h
  menu_item2 db '2. Dividir', 0h
  menu_item3 db '3. Adicionar', 0h
  menu_item4 db '4. Subtrair dois numeros', 0h
  menu_item5 db '0. Sair', 0h
  menu_emptyitem db '', 0h

  msg_ask db 'Escolha uma opcao: ', 0h
  msg_ask_fnum db 'Digite um numero: ', 0h
  msg_ask_snum db 'Digite mais um numero: ', 0h

  errmsg_1 db 'Opção inválida', 0h
  errmsg_2 db 'Não se pode dividir por zero', 0h

  clearterm     db   27,'[H',27,'[2J' ; <ESC> [H <ESC> [2J
  clearterm_len equ  $-clearterm      ; Length of term clear string

section .data
  fnum dd 0
  snum dd 0

  errlevel dd 0
  result dd 0

section .bss
  option resb 1

section .text
  global _start

_start:
  mov dword [result], 0
  mov dword [errlevel], 0

loop:
  ; Cleaning the screen
  mov edx, clearterm_len
  mov ecx, clearterm
  mov ebx, 1
  mov eax, 4
  int 80h


print_msgerr:
  cmp dword [errlevel], 0
  je print_result

  cmp dword [errlevel], 1
  je .msg1

  cmp dword [errlevel], 2
  je .msg2

  .msg1:
    mov eax, errmsg_1
    call sprintLF
    jmp print_result

  .msg2:
    mov eax, errmsg_2
    call sprintLF
    jmp print_result

print_result:
  mov eax, [result]
  call iprintLF

print_menu:
  ; Printing menu
  mov eax, menu_emptyitem
  call sprintLF

  mov eax, menu_item1
  call sprintLF

  mov eax, menu_item2
  call sprintLF

  mov eax, menu_item3
  call sprintLF

  mov eax, menu_item4
  call sprintLF

  mov eax, menu_emptyitem
  call sprintLF

  mov eax, menu_item5
  call sprintLF

ask_option:
  mov eax, msg_ask
  call sprint

  mov edx, 2
  mov ecx, option
  mov ebx, 0
  mov eax, 3
  int 80h

  mov al, byte [option]

  cmp al, '0'
  je exit

  cmp al, '1'
  je ask_fnum

  cmp al, '2'
  je ask_fnum

  cmp al, '3'
  je ask_fnum

  cmp al, '4'
  je ask_fnum

  mov dword [errlevel], 1
  jmp loop

ask_fnum:
  mov eax, msg_ask_fnum
  call sprint

  mov edx, 10
  mov ecx, fnum
  mov ebx, 0
  mov eax, 3
  int 80h

  mov eax, fnum
  call atoi
  mov dword [fnum], eax

  mov al, byte [option]
  cmp al, '4'
  jne ask_snum

  jmp handle_option

ask_snum:
  mov eax, msg_ask_snum
  call sprint

  mov edx, 10
  mov ecx, snum
  mov ebx, 0
  mov eax, 3
  int 80h

  mov eax, snum
  call atoi
  mov dword [snum], eax

handle_option:
  mov al, byte [option]

  cmp al, '1'
  je mul

  cmp al, '2'
  je div

  cmp al, '3'
  je add

  cmp al, '4'
  je sub

  ; No way it be another thing,
  ; I tested in `ask_option`

  jmp loop

mul:
  mov eax, dword [fnum]
  mov ebx, dword [snum]
  mul ebx

  mov dword [result], eax
  jmp loop

div:
  cmp dword [snum], 0
  je .err

  mov eax, dword [fnum]
  mov ebx, dword [snum]
  xor edx, edx
  div ebx

  mov dword [result], eax
  jmp loop

  .err:
    mov dword [errlevel], 2
    jmp loop

add:
  mov eax, dword [fnum]
  mov ebx, dword [snum]
  add eax, ebx

  mov dword [result], eax
  jmp loop

sub:
  mov eax, dword [fnum]
  mov ebx, 2
  sub eax, ebx

  mov dword [result], eax
  jmp loop

exit:
  call quit
