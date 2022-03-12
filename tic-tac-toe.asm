; -----------------------
; Tic Tac Toe Mini-Project
; -----------------------
; Authors:
; Ajay Krishna K V,         Roll No.: 07
; Nanda Kishor M Pai,       Roll No.: 45
; Paurnami Pradeep,         Roll No.: 50
; Sudev Suresh Sreedevi,    Roll No.: 60
; 
; Created on: 05/03/2022

data segment       
    new_line db 0DH, 0AH, "$"
    
    game_draw db "_|_|_", 0DH, 0AH
              db "_|_|_", 0DH, 0AH
              db "_|_|_", 0DH, 0AH, "$"    
                  
    game_pointer db 03H, 05H, 07H, 0AH, 0CH, 0EH, 11H, 13H, 15H
    
    win_flag db 0 
    player db "0$"
    
    game_over_message db "GAME OVER", 0DH, 0AH, "$"    
    game_start_message db "TIC TAC TOE", 0DH, 0AH, "$"
    player_message db "PLAYER $"   
    win_message db " WIN!$"   
    type_message db "TYPE A POSITION: $"
    tie_game_message db "TIE GAME!$"

    chance_count db 00h
data ends

code segment
start:
    ; set segment registers
    mov     ax, data
    mov     ds, ax
            
main_loop:
    inc chance_count
    call    clear_screen   
    
    lea     dx, game_start_message 
    call    print
    
    lea     dx, new_line
    call    print                      
    
    lea     dx, player_message
    call    print
    lea     dx, player
    call    print  
    
    lea     dx, new_line
    call    print    
    
    lea     dx, game_draw
    call    print    
    
    lea     dx, new_line
    call    print    
    
    ; If chance count exceeds 9, game is tied
    cmp chance_count, 0AH;
    jl continue_game
    lea dx, tie_game_message
    call print
    jmp final

    continue_game:
    lea     dx, type_message    
    call    print            
                        
    ; read draw position                   
    call    read_keyboard
                       
    ; calculate draw position                   
    sub     al, 31H             
    mov     bh, 00H
    mov     bl, al                                  
                                  
    call    update_draw                                    


    
    cmp chance_count, 04h ; No need of checking winner for the first 4 chances
    jle     winner   
                                            
    call    check  
                       
    winner:
    ; check if game ends                   
    cmp     win_flag, 01h  
    je      game_over  
    
    call    change_player 
            
    jmp     main_loop   


change_player proc   
    lea     si, player    
    xor     [si], 01h 
    
    ret
endp
      
 
update_draw proc
    mov     bl, game_pointer[bx]
    mov     bh, 00h
    
    lea     si, player
    
    cmp     [si], "0"
    je      draw_x     
                  
    cmp     [si], "1"
    je      draw_o              
                  
    draw_x:
    mov     cl, "x"
    jmp     update

    draw_o:          
    mov     cl, "o"  
    jmp     update    
          
    update:         
    mov     [bx], cl
      
    ret
endp
       
       
check proc
    call    check_line
    ret
endp  
       
       
check_line proc
    mov     cx, 00h
    
    check_line_loop:     
    cmp     cx, 00h
    je      first_line
    
    cmp     cx, 01h
    je      second_line
    
    cmp     cx, 02h
    je      third_line  
    
    call    check_column
    ret    
        
    first_line:    
    mov     si, 00h   
    jmp     do_check_line   

    second_line:    
    mov     si, 03h
    jmp     do_check_line
    
    third_line:    
    mov     si, 06h
    jmp     do_check_line        

    do_check_line:
    inc     cx
  
    mov     bh, 00h
    mov     bl, game_pointer[si]
    mov     al, [bx]
    cmp     al, "_"
    je      check_line_loop
    
    inc     si
    mov     bl, game_pointer[si]    
    cmp     al, [bx]
    jne     check_line_loop 
      
    inc     si
    mov     bl, game_pointer[si]  
    cmp     al, [bx]
    jne     check_line_loop
                 
                         
    mov     win_flag, 01h
    ret         
endp
       
       
check_column proc
    mov     cx, 00h
    
    check_column_loop:     
    cmp     cx, 00h
    je      first_column
    
    cmp     cx, 01h
    je      second_column
    
    cmp     cx, 02h
    je      third_column  
    
    call    check_diagonal
    ret    
        
    first_column:    
    mov     si, 00h   
    jmp     do_check_column   

    second_column:    
    mov     si, 01h
    jmp     do_check_column
    
    third_column:    
    mov     si, 02h
    jmp     do_check_column        

    do_check_column:
    inc     cx
  
    mov     bh, 00h
    mov     bl, game_pointer[si]
    mov     al, [bx]
    cmp     al, "_"
    je      check_column_loop
    
    add     si, 03h
    mov     bl, game_pointer[si]    
    cmp     al, [bx]
    jne     check_column_loop 
      
    add     si, 03h
    mov     bl, game_pointer[si]  
    cmp     al, [bx]
    jne     check_column_loop
                 
                         
    mov     win_flag, 01h
    ret
endp      


check_diagonal proc
    mov     cx, 00h
    
    check_diagonal_loop:     
    cmp     cx, 00h
    je      first_diagonal
    
    cmp     cx, 01h
    je      second_diagonal                         
    
    ret    
        
    first_diagonal:    
    mov     si, 00h                
    mov     dx, 04h
    jmp     do_check_diagonal   

    second_diagonal:    
    mov     si, 02h
    mov     dx, 02h
    jmp     do_check_diagonal       

    do_check_diagonal:
    inc     cx
  
    mov     bh, 00h
    mov     bl, game_pointer[si]
    mov     al, [bx]
    cmp     al, "_"
    je      check_diagonal_loop
    
    add     si, dx
    mov     bl, game_pointer[si]    
    cmp     al, [bx]
    jne     check_diagonal_loop 
      
    add     si, dx
    mov     bl, game_pointer[si]  
    cmp     al, [bx]
    jne     check_diagonal_loop
                 
                         
    mov     win_flag, 01h
    ret
endp
           

game_over proc  
    call    clear_screen   
    
    lea     dx, game_start_message 
    call    print
    
    lea     dx, new_line
    call    print                          
    
    lea     dx, game_draw
    call    print    
    
    lea     dx, new_line
    call    print

    lea     dx, game_over_message
    call    print  
    
    lea     dx, player_message
    call    print
    
    lea     dx, player
    call    print
    
    lea     dx, win_message
    call    print 

    jmp     final
    ret
endp
  
         
print proc
    ; print dx content  
    mov     ah, 09H
    int     21h   
    
    ret 
endp
    

clear_screen proc       
    ; get and set video mode
    mov     ah, 0fh
    int     10h   
    
    mov     ah, 00h
    int     10h
    
    ret
endp
       
    
read_keyboard proc  
    ; read keybord and return content in ah
    mov     ah, 01h       
    int     21h  
    
    ret
endp
      
      
final:
    mov ah, 4ch   
    int 21h
      
code ends
end start
