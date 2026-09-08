name "hangman"

org 100h                

jmp start

word1 db 'COMPUTER', 0
word2 db 'ORGANIZATION', 0
word3 db 'ASSEMBLY', 0
word4 db 'LANGUAGE', 0
word5 db 'ARCTICMONKEYS', 0
word6 db 'TAYLORSWIFT', 0
word7 db 'BROOKLYNNINENINE', 0
word8 db 'FRIENDS', 0
word9 db 'THEOFFICE', 0
word10 db 'KAAVISH', 0

word_list dw word1, word2, word3, word4, word5, word6, word7, word8, word9, word10
word_count equ 10

secret_word db 20 dup(0)    
display_word db 20 dup('_'), 0 
guessed_letters db 26 dup(0)
wrong_guesses db 0           
max_wrong equ 7              
game_won db 0             
word_length db 0           
random_seed dw 0            

hangman0 db '  +---+', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '=========$'

hangman1 db '  +---+', 13, 10
         db '  |   |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '=========$'

hangman2 db '  +---+', 13, 10
         db '  |   |', 13, 10
         db '  O   |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '=========$'

hangman3 db '  +---+', 13, 10
         db '  |   |', 13, 10
         db '  O   |', 13, 10
         db '  |   |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '=========$'

hangman4 db '  +---+', 13, 10
         db '  |   |', 13, 10
         db '  O   |', 13, 10
         db ' /|   |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '=========$'

hangman5 db '  +---+', 13, 10
         db '  |   |', 13, 10
         db '  O   |', 13, 10
         db ' /|\  |', 13, 10
         db '      |', 13, 10
         db '      |', 13, 10
         db '=========$'

hangman6 db '  +---+', 13, 10
         db '  |   |', 13, 10
         db '  O   |', 13, 10
         db ' /|\  |', 13, 10
         db ' /    |', 13, 10
         db '      |', 13, 10
         db '=========$'

hangman7 db '  +---+', 13, 10
         db '  |   |', 13, 10
         db '  O   |', 13, 10
         db ' /|\  |', 13, 10
         db ' / \  |', 13, 10
         db '      |', 13, 10
         db '=========$'

msg_title db 'HANGMAN', 13, 10, '$'
msg_guess db 13, 10, 'Guess a letter: $'
msg_wrong db 13, 10, 'Wrong guesses: $'
msg_used db 13, 10, 'Used letters: $'
msg_win db 13, 10, 'Congratulations! You won!', 13, 10, '$'
msg_lose db 13, 10, 'Game Over! The word was: $'
msg_play_again db 13, 10, 'Play again? (Y/N): $'
msg_invalid db 13, 10, 'Invalid input! Enter a letter A-Z.', 13, 10, '$'
msg_word_display db 13, 10, 'Word: $'

start:
    call init_game
    
game_loop:
    call draw_screen
    call get_guess
    call update_game
    
    cmp byte ptr game_won, 0
    je game_loop
    
    call draw_screen
    call show_result

    call play_again
    
    cmp al, 'Y'
    je restart_game

    mov ax, 4c00h   
    int 21h
    
restart_game:
    call init_game
    jmp game_loop

init_game proc
   
    mov ax, 3
    int 10h
    
    mov ah, 0
    int 1ah          
    mov random_seed, dx
    
    mov byte ptr wrong_guesses, 0
    mov byte ptr game_won, 0
    mov byte ptr word_length, 0

    mov cx, 26
    mov si, 0
clear_guessed:
    mov byte ptr guessed_letters[si], 0
    inc si
    loop clear_guessed

    call select_word

    mov cx, 0
    mov si, 0
init_display:
    mov al, byte ptr secret_word[si]
    cmp al, 0
    je end_init_display
    mov byte ptr display_word[si], '_'
    inc si
    inc cx
    jmp init_display
    
end_init_display:
    mov byte ptr word_length, cl
    mov byte ptr display_word[si], 0
    ret
init_game endp

select_word proc
  
    mov ax, random_seed
    mov bx, 25173
    mul bx
    add ax, 13849
    mov random_seed, ax
    
    xor dx, dx
    mov bx, word_count
    div bx
    mov ax, dx             

    shl ax, 1

    mov si, ax
    mov bx, word_list[si]

    mov si, 0
copy_word:
    mov al, byte ptr [bx + si]
    mov byte ptr secret_word[si], al
    cmp al, 0
    je copy_done
    inc si
    jmp copy_word
    
copy_done:
    ret
select_word endp

draw_screen proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov ax, 3
    int 10h

    mov ah, 9
    mov dx, offset msg_title
    int 21h

    mov al, byte ptr wrong_guesses
    cmp al, 0
    je draw_stage0
    cmp al, 1
    je draw_stage1
    cmp al, 2
    je draw_stage2
    cmp al, 3
    je draw_stage3
    cmp al, 4
    je draw_stage4
    cmp al, 5
    je draw_stage5
    cmp al, 6
    je draw_stage6
    cmp al, 7
    je draw_stage7
    jmp draw_stage7  
    
draw_stage0:
    mov ah, 9
    mov dx, offset hangman0
    int 21h
    jmp after_hangman
    
draw_stage1:
    mov ah, 9
    mov dx, offset hangman1
    int 21h
    jmp after_hangman
    
draw_stage2:
    mov ah, 9
    mov dx, offset hangman2
    int 21h
    jmp after_hangman
    
draw_stage3:
    mov ah, 9
    mov dx, offset hangman3
    int 21h
    jmp after_hangman
    
draw_stage4:
    mov ah, 9
    mov dx, offset hangman4
    int 21h
    jmp after_hangman
    
draw_stage5:
    mov ah, 9
    mov dx, offset hangman5
    int 21h
    jmp after_hangman
    
draw_stage6:
    mov ah, 9
    mov dx, offset hangman6
    int 21h
    jmp after_hangman
    
draw_stage7:
    mov ah, 9
    mov dx, offset hangman7
    int 21h
    
after_hangman:
   
    mov ah, 9
    mov dx, offset msg_word_display
    int 21h
    
    mov si, 0
display_word_loop:
    mov al, byte ptr display_word[si]
    cmp al, 0
    je end_display_word
    
    mov ah, 2
    mov dl, al
    int 21h

    mov dl, ' '
    int 21h
    
    inc si
    jmp display_word_loop
    
end_display_word:
   
    mov ah, 9
    mov dx, offset msg_wrong
    int 21h
    
    mov al, byte ptr wrong_guesses
    add al, '0'
    mov ah, 2
    mov dl, al
    int 21h
    
    mov dl, '/'
    int 21h
    
    mov al, max_wrong
    add al, '0'
    mov dl, al
    int 21h

    mov ah, 9
    mov dx, offset msg_used
    int 21h

    mov cx, 0
    mov si, 0
show_guessed:
    cmp byte ptr guessed_letters[si], 1
    jne next_letter
    
    mov dl, 'A'
    add dl, cl
    mov ah, 2
    int 21h
    mov dl, ' '
    int 21h
    
next_letter:
    inc si
    inc cx
    cmp cx, 26
    jl show_guessed
    
    mov ah, 9
    mov dx, offset msg_guess
    int 21h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_screen endp

get_guess proc
  
    mov ah, 1
    int 21h
    
    cmp al, 'a'
    jl check_upper
    cmp al, 'z'
    jg invalid_input
    sub al, 32          
    jmp check_upper
    
invalid_input:
 
    mov ah, 2
    mov dl, 8           
    int 21h
    mov dl, ' '        
    int 21h
    mov dl, 8           
    int 21h
  
    mov ah, 9
    mov dx, offset msg_invalid
    int 21h
 
    mov ah, 7
    int 21h
 
    mov ah, 2
    mov dl, 13          
    int 21h
    mov dl, 10          
    int 21h

    jmp get_guess
    
check_upper:
    cmp al, 'A'
    jl invalid_input
    cmp al, 'Z'
    jg invalid_input

    ret
get_guess endp

update_game proc
    push ax
    push bx
    push si

    sub al, 'A'       
    xor ah, ah
    mov si, ax
    
    cmp byte ptr guessed_letters[si], 1
    je already_guessed

    mov byte ptr guessed_letters[si], 1

    push ax          
    add al, 'A'      
    call check_letter
    pop ax           
    
    cmp bl, 0        
    je letter_not_found
    
    add al, 'A'        
    call update_display
    
    call check_win
    jmp update_done
    
letter_not_found:
    inc byte ptr wrong_guesses
    
    mov al, byte ptr wrong_guesses
    cmp al, max_wrong
    jl not_game_over

    mov byte ptr game_won, 2
    jmp update_done
    
not_game_over:
    jmp update_done
    
already_guessed:
   
    
update_done:
    pop si
    pop bx
    pop ax
    ret
update_game endp

check_letter proc
    push ax
    push si
    
    mov bl, 0          
    mov si, offset secret_word
    
check_loop:
    mov ah, byte ptr [si]
    cmp ah, 0
    je end_check
    
    cmp ah, al
    jne next_char

    mov bl, 1
    
next_char:
    inc si
    jmp check_loop
    
end_check:
    pop si
    pop ax
    ret
check_letter endp

update_display proc
    push ax
    push si
    push di
    
    mov si, offset secret_word
    mov di, offset display_word
    
update_loop:
    mov ah, byte ptr [si]
    cmp ah, 0
    je end_update
    
    cmp ah, al        
    jne no_match
 
    mov byte ptr [di], al
    
no_match:
    inc si
    inc di
    jmp update_loop
    
end_update:
    pop di
    pop si
    pop ax
    ret
update_display endp

check_win proc
    push ax
    push si
    
    mov si, offset display_word
    
check_win_loop:
    mov al, byte ptr [si]
    cmp al, 0
    je player_won     
    
    cmp al, '_'
    je not_won_yet     
    
    inc si
    jmp check_win_loop
    
player_won:
    mov byte ptr game_won, 1
    
not_won_yet:
    pop si
    pop ax
    ret
check_win endp


show_result proc
    push ax
    push bx
    push dx
    push si

    mov ah, 9
    
    cmp byte ptr game_won, 1
    je show_win_msg

    mov dx, offset msg_lose
    int 21h
    
    mov si, 0
show_secret_word:
    mov al, byte ptr secret_word[si]
    cmp al, 0
    je result_done
    
    mov ah, 2
    mov dl, al
    int 21h
    mov dl, ' '
    int 21h
    
    inc si
    jmp show_secret_word
    
show_win_msg:
    mov dx, offset msg_win
    int 21h
    
result_done:
    pop si
    pop dx
    pop bx
    pop ax
    ret
show_result endp

play_again proc
    push dx
 
    mov ah, 9
    mov dx, offset msg_play_again
    int 21h

    mov ah, 1
    int 21h

    cmp al, 'y'
    jne not_lower_y
    mov al, 'Y'
not_lower_y:
    
    pop dx
    ret
play_again endp