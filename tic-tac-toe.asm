data segment       
    new_line db 0DH, 0AH, "$"
    
    game_draw db "_|_|_", 0DH, 0AH
              db "_|_|_", 0DH, 0AH
              db "_|_|_", 0DH, 0AH, "$"    
                  
    ;game_pointer db 9 DUP(?)  
    game_pointer db 03H, 05H, 07H, 0AH, 0CH, 0EH, 11H, 13H, 15H
    
    win_flag db 0 
    player db "0$" 
    
    game_over_message db "GAME OVER", 0DH, 0AH, "$"    
    game_start_message db "TIC TAC TOE by ", 0DH, 0AH, "$"
    player_message db "PLAYER $"   
    win_message db " WIN!$"   
    type_message db "TYPE A POSITION: $"
data ends

code segment
start:
    ; set segment registers
    mov     ax, data
    mov     ds, ax

    ; game start   
    call    set_game_pointer    
            
main_loop:  
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
    
    lea     dx, type_message    
    call    print            
                        
    ; read draw position                   
    call    read_keyboard
                       
    ; calculate draw position                   
    sub     al, 31H             
    mov     bh, 00H
    mov     bl, al                                  
                                  
    call    update_draw                                    
                                                          
    call    check  
                       
    ; check if game ends                   
    cmp     win_flag, 1  
    je      game_over  
    
    call    change_player 
            
    jmp     main_loop   


change_player:   
    lea     si, player    
    xor     [si], 1 
    
    ret
      
 
update_draw proc
    mov     bl, game_pointer[bx]
    mov     bh, 0
    
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
       
       
check:
    call    check_line
    ret     
       
       
check_line:
    mov     cx, 0
    
    check_line_loop:     
    cmp     cx, 0
    je      first_line
    
    cmp     cx, 1
    je      second_line
    
    cmp     cx, 2
    je      third_line  
    
    call    check_column
    ret    
        
    first_line:    
    mov     si, 0   
    jmp     do_check_line   

    second_line:    
    mov     si, 3
    jmp     do_check_line
    
    third_line:    
    mov     si, 6
    jmp     do_check_line        

    do_check_line:
    inc     cx
  
    mov     bh, 0
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
                 
                         
    mov     win_flag, 1
    ret         
       
       
       
check_column:
    mov     cx, 0
    
    check_column_loop:     
    cmp     cx, 0
    je      first_column
    
    cmp     cx, 1
    je      second_column
    
    cmp     cx, 2
    je      third_column  
    
    call    check_diagonal
    ret    
        
    first_column:    
    mov     si, 0   
    jmp     do_check_column   

    second_column:    
    mov     si, 1
    jmp     do_check_column
    
    third_column:    
    mov     si, 2
    jmp     do_check_column        

    do_check_column:
    inc     cx
  
    mov     bh, 0
    mov     bl, game_pointer[si]
    mov     al, [bx]
    cmp     al, "_"
    je      check_column_loop
    
    add     si, 3
    mov     bl, game_pointer[si]    
    cmp     al, [bx]
    jne     check_column_loop 
      
    add     si, 3
    mov     bl, game_pointer[si]  
    cmp     al, [bx]
    jne     check_column_loop
                 
                         
    mov     win_flag, 1
    ret        


check_diagonal:
    mov     cx, 0
    
    check_diagonal_loop:     
    cmp     cx, 0
    je      first_diagonal
    
    cmp     cx, 1
    je      second_diagonal                         
    
    ret    
        
    first_diagonal:    
    mov     si, 0                
    mov     dx, 4 ;tamanho do pulo
    jmp     do_check_diagonal   

    second_diagonal:    
    mov     si, 2
    mov     dx, 2
    jmp     do_check_diagonal       

    do_check_diagonal:
    inc     cx
  
    mov     bh, 0
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
                 
                         
    mov     win_flag, 1
    ret  
           

game_over:        
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

    jmp     fim    
  
     
set_game_pointer:
    lea     si, game_draw
    lea     bx, game_pointer          
              
    mov     cx, 9   
    
    loop_1:
    cmp     cx, 6
    je      add_1                
    
    cmp     cx, 3
    je      add_1
    
    jmp     add_2 
    
    add_1:
    add     si, 1
    jmp     add_2     
      
    add_2:                                
    mov     [bx], si 
    add     si, 2
                        
    inc     bx               
    loop    loop_1 
 
    ret  
         
       
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
      
      
fim:
    jmp     fim         
      
code ends

end start