
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here
.DATA  
            time db 0 ;  bara moghayese time
            ball_random db 0fh
            BALL_X DW 2Ah
            BALL_Y DW 2Ah 
            BALL_SIZE DW 04h
             
            BALL_VELOCITY_X DW 06h 
            BALL_VELOCITY_Y DW 03h 
         
            start_col dw   15d 
            start_row dw   15d
            finish_col dw  295d
            finish_row dw  180d 
             
            score db 00h
              
            paddle_X dw 295d
            paddle_y dw 90d
            paddle_h dw 40d  
            paddle_w dw 05h  
            PADDLE_VELOCITY DW 04H 
            
             
            msg DB 'Game over!$'
            msgWIN DB 'YOU WIN!$'
        
.CODE


main proc far
    mov ax, @data
    mov ds, ax   
    ;ball random aval sefide
    call clear_screen    
    call set_graphic_mode 
    
    ;initial score
    ;mov bl , 0  
    
    ;time system   
    check_time:
    mov ah , 2ch    ; dl contains 1/100s
    int 21h
    cmp dl,time
    je check_time 
    
    ;agar zaman avaz shode bode hala dge mire baghie kara
    mov time,dl ;update
   
    call clear_screen 
    
    call draw_game_map
    
    CALL MOVE_BALL
    
    call draw_ball 
    
    call move_paddle
    
    call draw_paddle
     
    call printScore
                
    jmp check_time ;harvaght hame kararo kard
    

    ;finoalfinefinishshshshshsh                   
    mov ax, 4c00h ; exit to operating system.
    int 21h    

main endp



clear_screen proc
	MOV AH,00h ;set the configuration to video mode
	MOV AL,13h ;choose the video mode
	INT 10h    ;execute the configuration           
    ret                    
endp clear_screen 
    
    
set_graphic_mode proc
    mov ah, 00h
    mov al, 13h
    int 10h 
    ret
endp set_graphic_mode


draw_game_map proc   
    ;khat balaei
	    MOV AH,0Ch ;set the configuration to writing a pixel
		MOV AL,0Fh ;sefid 
		INT 10h  
		mov dx , start_row
		mov cx , start_col 
		khat:
		int 10h
        inc cx
        cmp cx, finish_col
        jnz khat 
               
               ;khat paeini
        MOV AH,0Ch ;set the configuration to writing a pixel
		MOV AL,0Fh ;sefid 
		INT 10h  
		mov dx , finish_row
		mov cx , start_col 
		khat1:
		int 10h
        inc cx
        cmp cx, finish_col
        jnz khat1
        
        ;khat vaset
        :
        mov dx , start_row
		mov cx , start_col 
		khat2:
		int 10h
        inc dx
        cmp dx, finish_row
        jnz khat2
    
    ret
    endp gam_map	
	
MOVE_BALL PROC 
		
		MOV AX,BALL_VELOCITY_X
		ADD BALL_X,AX 
		
		mov ax ,0fh                 ;x<15 -x
		add ax, ball_size 
        cmp ball_X,ax
        jl  NEG_VELOCITY_X  
        
        mov ax,140h
        sub ax,ball_size                            
        cmp ball_X,ax
        jg  gameover            ;x>295 gameover
		 
		 
		MOV AX,BALL_VELOCITY_Y
		ADD BALL_Y,AX
		                                         ;ball zasize ro kam ya ezafe mikonim ke talaghi ro bartaraf kone
		mov ax , 0fh
		add ax,ball_size
		cmp ball_y,ax                    ;y<15
		jl neg_velocity_y                      ;y>180
		
		mov ax , 0b4h
		sub ax,ball_size
		cmp ball_y,ax
        jg  NEG_VELOCITY_y  
        
        
        
        
        ; Check if the ball is colliding with the  paddle
           ;in se shart bayad check beshe dar barkhord do obj
		; BALL_X + BALL_SIZE > PADDLE_RIGHT_X && BALL_X < PADDLE_RIGHT_X + PADDLE_WIDTH 
		; && BALL_Y + BALL_SIZE > PADDLE_RIGHT_Y && BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT
		
		MOV AX,BALL_X
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_X
		JNG continiue  ;age ok bood bere sharte badi age na ke hichi
		
		MOV AX,PADDLE_X
		ADD AX,PADDLE_w
		CMP BALL_X,AX
		JNL continiue  ;;age ok bood bere sharte badi age na ke hichi
		
		MOV AX,BALL_Y
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_Y
		JNG continiue  ;;age ok bood bere sharte badi age na ke hichi
		
		MOV AX,PADDLE_Y
		ADD AX,PADDLE_H
		CMP BALL_Y,AX
		JNL continiue  
		
;       age be inja berese yani barkhord dashtim
;       pas bayad vel ha ro ham baraks konim   
        call findRandColor
        NEG BALL_VELOCITY_X
        neg ball_velocity_y   
        ;score++ 
        inc score          ;reverses the horizontal velocity of the ball    
        
        ;check if score reach 30
        cmp score , 30d
        je wingame
        
		RET          
	
	continiue:
              
	ret	
	
MOVE_BALL ENDP

draw_ball proc

		MOV CX,BALL_X 
		MOV DX,BALL_Y 
		  
		  
		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,ball_random ;sefid 
			INT 10h    
			
			INC CX    
			MOV AX,CX          ;agar be tahe khat resid bere satr badi
			SUB AX,BALL_X
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			
			MOV CX,BALL_X ;az aval shoro mikone bere jolo to khat jaddid
			INC DX        ;khat jadid
			
			MOV AX,DX              ;DX - BALL_Y > BALL_SIZE (Y -> tamom
			SUB AX,BALL_Y
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL

    ret
endp draw_ball


draw_paddle proc
        MOV CX,PADDLE_X 
		MOV DX,PADDLE_Y 
		
		DRAW_PADDLE_HORIZONTAL:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0Fh ;choose white as color
			MOV BH,00h ;set the page number 
			INT 10h    ;execute the configuration
			
			INC CX     
			MOV AX,CX          
			SUB AX,PADDLE_X
			CMP AX,PADDLE_W
			JNG DRAW_PADDLE_HORIZONTAL             ;chon chand line e padle miyam itrate mikonim hamasho bekeshim
			
			MOV CX,PADDLE_X ;the CX register goes back to the initial column
			INC DX        ;we advance one line
			
			MOV AX,DX              
			SUB AX,PADDLE_Y
			CMP AX,PADDLE_h
			JNG DRAW_PADDLE_HORIZONTAL
		
    ret
    endp draw_paddle


    
	MOVE_PADDLE PROC 
		
		
		;check if any key is being pressed 
		MOV AH,01h
		INT 16h
		JZ EXIT_PADDLE_MOVEMENT ;ZF = 1, JZ -> Jump If Zero
		
		;check which key is being pressed (AL = ASCII character)
		MOV AH,00h
		INT 16h
		
		;if it is 'w' or 'W' move up
		CMP AL,77h ;'w'
		JE PADDLE_UP
		CMP AL,57h ;'W'
		JE PADDLE_UP
		
		;if it is 's' or 'S' move down
		CMP AL,73h ;'s'
		JE PADDLE_DOWN
		CMP AL,53h ;'S'
		JE PADDLE_DOWN
		JMP EXIT_PADDLE_MOVEMENT
		
		PADDLE_UP:
			MOV AX,PADDLE_VELOCITY
			SUB PADDLE_Y,AX
			
			MOV AX,15d ;shayad ghalat bashe'
			CMP PADDLE_Y,AX
			JL FIX_PADDLE_TOP_POSITION
			JMP  EXIT_PADDLE_MOVEMENT
			
			FIX_PADDLE_TOP_POSITION:
				MOV PADDLE_Y,AX
				JMP EXIT_PADDLE_MOVEMENT
			
		PADDLE_DOWN:
			MOV AX,PADDLE_VELOCITY
			ADD PADDLE_Y,AX
			MOV AX,finish_row
		;	SUB AX,WINDOW_BOUNDS  ;shayad ghalat
			SUB AX,PADDLE_H
			CMP PADDLE_Y,AX
			JG FIX_PADDLE_BOTTOM_POSITION
			JMP EXIT_PADDLE_MOVEMENT
			
			FIX_PADDLE_BOTTOM_POSITION:
				MOV PADDLE_Y,AX
				JMP EXIT_PADDLE_MOVEMENT
		
		EXIT_PADDLE_MOVEMENT:
		
			RET
endp move_paddle


findRandColor Proc
    
   mov ah , 00h ;get system time
   int 1Ah ; cx:hOUR RO MIRIZE ,
   xor ax , ax
   mov al , dl
   
   mov  ax, dx
   xor  dx, dx
   mov  cx, 0Fh    
   div  cx      
   
   inc dl
   
   mov ball_random, dl
       
    ret    
findRandColor ENDP

;PRINTSCORE FUNCTION BORROWED FROM P
printScore PROC
    mov al , score
    mov ah , 0
    xor cx , cx
    mov bx , 0Ah      
dividDigits:

        xor dx , dx
        div bx ; => dx = digit and ax = kharej ghesmat 
        add dx , 48
        add ax , 48
        mov cx , dx
printDIGIT: 
       mov di , dx
       mov bp , ax
       
       mov dh , 1
       mov dl , 57
       mov bh , 0
       mov ah , 02h
       int 10h
       
       mov ax , bp
       mov bh , 00h
       mov bl , 046h
       mov cx , 1
       mov ah , 09h
       int 10h
         
       mov dh , 1
       mov dl , 58
       mov bh , 0
       mov ah , 02h
       int 10h
       
       mov cx , di
       mov al ,cl
       mov bh , 00h
       mov bl , 046h
       mov cx , 1
       mov ah , 09h
       int 10h 
       ret
printScore ENDP  

    
NEG_VELOCITY_X:
			NEG BALL_VELOCITY_X   ;BALL_VELOCITY_X = - BALL_VELOCITY_X
			RET
	
NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y   ;BALL_VELOCITY_Y = - BALL_VELOCITY_Y
			RET

wingame:      
call clear_screen
LEA DX,msgWIN 
    MOV AH,09H
    INT 21H  

MOV AH, 0
INT 21H  
RET

gameover:      
call clear_screen    
LEA DX,msg 
    MOV AH,09H
    INT 21H  
    
mov ah , bl
int 13h
MOV AH, 0
INT 21H   
RET 

