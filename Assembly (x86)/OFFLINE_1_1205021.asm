
.STACK 100H 



.DATA
    STR DB ?
    WON DB ?
    COUNT DB ? 
    ENTER EQU 0DH
    PROMPT DB 10,13,'ENTER THE RUN OF FIRST TEAM:$'
    VICTORY_MSG DB 10,13,'MY PREDICTION: VICTORY$'
    DEFEAT_MSG DB 10,13,'MY PREDICTION: DEFEAT$' 
    
.CODE

MAIN PROC

    MOV AX, @DATA
    MOV DS, AX 
    
    MOV CL,0
    
    MOV AH,9
    LEA DX,PROMPT
    INT 21H
    
    JMP READ 
     
CONDITION2:
    MOV WON ,1
    JMP REST
    
CONDITION1:
     CMP STR, '3'
     JGE CONDITION2
     MOV WON ,0
     JMP REST

READ:
    MOV AH,1
    INT 21H
    
    CMP AL, ENTER    
    JE DONE     
    MOV STR,AL
    
    CMP CL,0;
    JE  CONDITION1
REST:
    ADD CL,1       
    JMP READ
    
DONE:
    MOV AH, 2
    MOV DL,ENTER
    INT 21H     
    MOV DL, 0AH
    INT 21H
    
    CMP CL,3
    JL DEFEAT
    JG VICTORY
    CMP WON, 0
    JE DEFEAT
    JMP VICTORY  
    
VICTORY:
    MOV AH,9
    LEA DX,VICTORY_MSG
    INT 21H
    JMP EXIT
DEFEAT:    
    MOV AH,9
    LEA DX,DEFEAT_MSG
    INT 21H
     
EXIT:
    MOV AH, 4CH
    INT 21H
    
    
MAIN ENDP
END MAIN