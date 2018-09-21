.STACK 100H 



.DATA
    STR DB ?
    COUNT DB ?
    SUM DB ?
    VAL DB ?
    ENTER EQU 0DH
    PROMPT DB 10,13,'ENTER THE NUMBER:$' 
    
.CODE

MAIN PROC

    MOV AX, @DATA
    MOV DS, AX 
    
    MOV CL,0
    MOV DL,0
    
    MOV AH,9
    LEA DX,PROMPT
    INT 21H
           
    
    MOV VAL,0
    JMP READ   

READ:
    MOV AH,1
    INT 21H
    
    CMP AL, ENTER    
    JE DONE     
    MOV STR,AL
    
    MOV CL, 0
    ;MOV VAL,DL
    MOV DL, 0

    DO:     
        ADD DL,VAL
        INC CL
        CMP CL,10
        JL DO
    SUB STR,48
    ADD DL,STR
    MOV VAL, DL             
    JMP READ  
   
   
DONE:
    MOV SUM,0
    MOV CL,1
    MOV BL,0
    JMP BUILD
    
    
CND1:
    MOV BL,0
    SUB SUM,CL
    JMP REST
BUILD:    
    ;CMP CL,VAL
    
    CMP BL,1
    JE  CND1
    
    ADD SUM,CL
    MOV BL,1
REST:
    ADD CL,2
    CMP CL,VAL
    JLE BUILD 
    
    MOV AH,2
    MOV DL,10
    INT 21H 
    
    MOV AH,2
    MOV DL,13
    INT 21H    
            
    MOV BL, SUM

    CMP BL,0
    JE  NEGATIVE
    JMP POS
    
NEGATIVE:
        
    MOV AH,2
    MOV DL,'N'
    INT 21H 
    JMP EXIT
    
POS: 
    MOV AH,2
    MOV DL,'P'
    INT 21H
    
EXIT:
    MOV AH, 4CH
    INT 21H
    
MAIN ENDP
END MAIN     