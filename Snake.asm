          ; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||    
          ; ||                                                            ||
          ; ||  |||||   ||     ||     ||||||||     ||      ||    ||||||   ||
          ; ||  ||      ||   ||||     ||    ||     ||    ||      ||       ||
          ; ||  |||||   || ||  ||     ||||||||     ||||||        ||||||   ||
          ; ||     ||   ||||   ||     ||    ||     ||    ||      ||       ||
          ; ||  |||||   ||     ||     ||    ||     ||      ||    ||||||   ||
          ; ||                                                            ||
          ; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

          ;Designed and Programmed by Jamie Haazen
          ;SOME routines were assisted by Gemini 
          ;THX to some random guy on github who posted a charactor set loading routine
          ;Uses 3920 bytes (3.85 KB) Ram :Game file size 3399 bytes (3.34 KB) 
          ; Variable space 521 bytes (0.51 KB)
          ;NOT ALL ROUTINES WERE FULLY DESIGNED BY ME
*= $0801
          !BYTE  $0B, $08, $E9, $07, $9E, $34, $39, $31, $35, $32, $0, $0, $0

       

* = $c000

          lda  #05
          sta  Backround
          lda  #$0D
          sta  Border
          lda  #02
          sta  Text


:initionalise

jsr DelayLoop
Snake_X_Array = $C500
Snake_Y_Array = $C600
ScreenRam = $0400
Apple_X_Pos = $C902
Apple_Y_Pos = $C903
Snake_length = $C904
Random_number = $D012
LastPress = $C905
tail_x_save = $C906
tail_y_save = $C907
Backround = $C908
Border = $C909
Text = $C90A



          lda  Backround
          sta  $D020
          lda  Border
          sta  $D021
          lda  Text
          sta $0286

          lda  #$12
          sta  LastPress

          lda  #3
          sta  Snake_length
  
  lda  #12
          sta  Snake_X_Array   ; Head X
          sta  Snake_X_Array+1 ; Body 1 X
          sta  Snake_X_Array+2 ; Body 2 X

          lda  #10
          sta  Snake_Y_Array   ; Head Y
          sta  Snake_Y_Array+1 ; Body 1 Y
          sta  Snake_Y_Array + 2 ; Body 2 Y
          lda  #$93
          jsr $FFD2
         
          jsr  Genarate_apple_pos
         
          
          
    LDA $D018
    AND #$F0         
    ORA #$0C            
    STA  $D018
          
          
         
    
:Title_Screen 

          ldx  #00
          lda  #$93
          jsr $ffd2
   
:Load_Screen1         
          lda  $CA00, x
          sta  ScreenRam, x
          inx
          cpx  #00
          beq  Load_Screen2
          jmp  Load_Screen1

:Load_Screen2
          lda  $CA00 + 256, x
          sta  ScreenRam + 256, x
          inx
          cpx  #00
          beq  Load_Screen3
          jmp  Load_Screen2

:Load_Screen3
          lda  $CA00 + 512, x
          sta  ScreenRam + 512, x
          inx
          cpx  #00
          beq  Load_Screen4
          jmp  Load_Screen3
:Load_Screen4
          lda  $CA00 + 758, x
          sta  ScreenRam + 768, x
          inx
          cpx  #00
          beq  End_Screen_Load
          jmp  Load_Screen4         
               
          
:End_Screen_Load 
          lda  $C5
          cmp  #$3C
          beq  CLR
          cmp  #$04
          beq  Change_Backround
          cmp  #$05
          beq  Change_Border
          cmp  #$06
          beq Change_Text
          jmp  End_Screen_Load

:Change_Backround
          inc  $D020
          inc Backround
          jsr DelayLoop
          jmp  Title_Screen

:Change_Border
          inc  $D021
          inc Border
          jsr DelayLoop
          jmp  Title_Screen

:Change_Text
          inc  $0286
          inc Text
          jsr DelayLoop
          jmp  Title_Screen


          
:CLR
          lda  #$93 
          jsr  $ffd2
          
:Game_run_order

          jsr  KeyboardScan
          lda  Snake_length
          tax
          dex                
          lda  Snake_X_Array,x
          sta  tail_x_save
          lda  Snake_Y_Array,x
          sta  tail_y_save
          jsr Shift_body       
          Jsr  GenarateSnakePos       
          jsr  Print_Score
          jsr ScreenDraw
          jsr  Snake_Col_Check
          jsr Edge_Check
          jsr Apple_Col
          jsr  DelayLoop
          jmp  Game_run_order
          
          
:DelayLoop
          ldy  #$40     ; Outer loop delay factor
:Outer
          ldx  #$00     ; Inner loop
:Inner
          dex
          bne  Inner
          dey
          bne  Outer
          rts

:KeyboardScan
          lda  $C5
          cmp  #$40
Beq ExitScan
          lda  $C5
          cmp  #$09
          beq  StorePress
          cmp  #$0A
          beq  StorePress
          cmp  #$0D
          beq  StorePress
          cmp  #$12
          beq  StorePress
 :ExitScan
          rts
        
  
 :StorePress
          lda  $C5
          sta  LastPress
          rts

      
 :Shift_body
          lda  Snake_length
          tax
 
 :Shift_loop
          dex
          beq  done_shifting
          lda  Snake_X_Array -1, x         
          sta  Snake_X_Array , x
          lda  Snake_Y_Array - 1 , x
          sta  Snake_Y_Array , x
          jmp  Shift_loop
          
 :done_shifting
          rts
          
                   
:ScreenDraw          

  
:SnakeScreenDraw
         
          ldx  tail_y_save
          ldy  tail_x_save
          clc
          jsr  $FFF0
          lda  #$20
          jsr  $FFD2
          ldy  #00

:draw_body_loop
          tya
          pha
          lda  Snake_Y_Array, y
          tax        
          lda  Snake_X_Array, y
          tay
          clc
          jsr  $fff0
          lda  #$5e
          jsr  $FFD2
          pla
          tay
          iny
          cpy  Snake_length
          bne  draw_body_loop
          

          
:screen_draw_Apple
        
          ldx  Apple_Y_Pos
          ldy  Apple_X_Pos
          clc
          jsr  $FFF0
          lda  #64
          jsr  $FFD2       
          rts
 
:Genarate_apple_pos
:GenarateAppleX
          lda  Random_number  ; Read raster line for randomness
          and  #$1F           ; Mask bits to limit number between 0-31
          cmp  #39            ; Ensure it fits on 40-column screen
          bcs  GenarateAppleX ; Re-roll if out of bounds (0-39)
          sta  Apple_X_Pos
:GenarateAppleY
          lda  Random_number   ; Read raster line for randomness
          and  #$1F            ; Mask bits to limit number between 0-31
          cmp  #01
          beq  GenarateAppleY
          cmp  #00
          beq GenarateAppleY
          cmp  #24            ; Ensure it fits on 40-column screen
          bcs  GenarateAppleY ; Re-roll if out of bounds (0-24)
          sta  Apple_Y_Pos
          rts
          

 
          
          
          
 
 
 :GenarateSnakePos
          lda  LastPress
          cmp  #$09
          beq  MovingUp
          cmp  #$0A
          beq  Movingleft
          Cmp  #$0D
          beq  MovingDown
          Cmp  #$12
          beq  MovingRight
          rts
                      
:MovingUp
         dec Snake_Y_Array
          rts
          
:MovingDown
          inc  Snake_Y_Array
         rts
         
:Movingleft
          dec  Snake_X_Array
          Rts
:MovingRight
          inc  Snake_X_Array
         rts            

:Apple_Col
:Apple_X_Check
       
          lda  Snake_X_Array
          cmp  Apple_X_Pos
          beq  Apple_Y_Check
          rts
          
:Apple_Y_Check
          lda  Snake_Y_Array
          cmp  Apple_Y_Pos
          beq  UpdateLen
          rts

:Snake_Col_Check          
          ldx  Snake_length
          dex
:Snake_Loop
          Cpx  #00
          beq  End_Col_Check
          lda  Snake_X_Array, x
          cmp  Snake_X_Array
          bne  Next_segment

          lda  Snake_Y_Array, x
          cmp  Snake_Y_Array
          beq  Game_Over

:Next_segment
          dex
          jmp  Snake_Loop

          
:End_Col_Check
          rts
:Game_Over
          lda  #01
          sta $0286
          lda  #$93
          jsr  $FFD2
          jsr  Print_Score
          jsr  Print_Restart
          jsr Print_Over_Text
          lda  #$02
          sta  $D020
          Sta  $D021
:Brk_Loop       
          lda  $C5
          cmp  #$3C
          beq  Break
          jmp Brk_Loop
:Break         
          jmp initionalise


:Print_Score
          ldx  #00
:Score_Loop          
          lda  Score, x
          cmp  #00
          beq  Print_Score2
          sta  $0428, x
          inx
          jmp  Score_Loop
:Print_Score2
          ldx  #1
          ldy  #9
          clc
          jsr  $FFF0
          ldx  Snake_length
          lda  #00
          sec
          jsr  $BDCD
          rts
          
                  
          
          

         
          
          
:UpdateLen
          inc  Snake_length
         jsr Genarate_apple_pos
          rts

          
:Edge_Check
          lda  Snake_X_Array
          cmp  #255
          beq  Game_Over
          cmp  #40
          beq  Game_Over
          lda  Snake_Y_Array
          cmp  #255
          beq  Game_Over
          cmp  #25
          beq  Game_Over
          rts
 
:Print_Restart
          lda  Restart, x
          cmp  #00
          beq  End_Restart
          sta  $0478, x
          inx
          jmp  Print_Restart

:End_Restart
          rts
          
:Print_Over_Text
          ldx  #00
Over_Loop
          lda  Game_Over_Text, x
          cmp  #00
          beq  Return_From_Over
          sta  $0615, x
          inx
          jmp  Over_Loop
          
Return_From_Over
          rts
          
        
                   
:Score
          !SCR  "score = "
          !Byte  # 00
:Restart
          !Scr  "press space to return to title screen"
          !byte  # 00
          
:Game_Over_Text
          !Scr  "game over"
          !byte  # 00
                
          
* = $3000

:CHARS
!byte $18,$08,$08,$7e,$7e,$7e,$7e,$3c
!byte $18,$3c,$66,$7e,$66,$66,$66,$00
!byte $7c,$66,$66,$7c,$66,$66,$7c,$00
!byte $3c,$66,$60,$60,$60,$66,$3c,$00
!byte $78,$6c,$66,$66,$66,$6c,$78,$00
!byte $7e,$60,$60,$78,$60,$60,$7e,$00
!byte $7e,$60,$60,$78,$60,$60,$60,$00
!byte $3c,$66,$60,$6e,$66,$66,$3c,$00
!byte $66,$66,$66,$7e,$66,$66,$66,$00
!byte $3c,$18,$18,$18,$18,$18,$3c,$00
!byte $1e,$0c,$0c,$0c,$0c,$6c,$38,$00
!byte $66,$6c,$78,$70,$78,$6c,$66,$00
!byte $60,$60,$60,$60,$60,$60,$7e,$00
!byte $63,$77,$7f,$6b,$63,$63,$63,$00
!byte $66,$76,$7e,$7e,$6e,$66,$66,$00
!byte $3c,$66,$66,$66,$66,$66,$3c,$00
!byte $7c,$66,$66,$7c,$60,$60,$60,$00
!byte $3c,$66,$66,$66,$66,$3c,$0e,$00
!byte $7c,$66,$66,$7c,$78,$6c,$66,$00
!byte $3c,$66,$60,$3c,$06,$66,$3c,$00
!byte $7e,$18,$18,$18,$18,$18,$18,$00
!byte $66,$66,$66,$66,$66,$66,$3c,$00
!byte $66,$66,$66,$66,$66,$3c,$18,$00
!byte $63,$63,$63,$6b,$7f,$77,$63,$00
!byte $66,$66,$3c,$18,$3c,$66,$66,$00
!byte $66,$66,$66,$3c,$18,$18,$18,$00
!byte $7e,$06,$0c,$18,$30,$60,$7e,$00
!byte $3c,$30,$30,$30,$30,$30,$3c,$00
!byte $0c,$12,$30,$7c,$30,$62,$fc,$00
!byte $3c,$0c,$0c,$0c,$0c,$0c,$3c,$00
!byte $3c,$42,$81,$81,$81,$81,$42,$3c
!byte $00,$10,$30,$7f,$7f,$30,$10,$00
!byte $00,$00,$00,$00,$00,$00,$00,$00
!byte $18,$18,$18,$18,$00,$00,$18,$00
!byte $66,$66,$66,$00,$00,$00,$00,$00
!byte $66,$66,$ff,$66,$ff,$66,$66,$00
!byte $18,$3e,$60,$3c,$06,$7c,$18,$00
!byte $62,$66,$0c,$18,$30,$66,$46,$00
!byte $3c,$66,$3c,$38,$67,$66,$3f,$00
!byte $06,$0c,$18,$00,$00,$00,$00,$00
!byte $0c,$18,$30,$30,$30,$18,$0c,$00
!byte $30,$18,$0c,$0c,$0c,$18,$30,$00
!byte $00,$66,$3c,$ff,$3c,$66,$00,$00
!byte $00,$18,$18,$7e,$18,$18,$00,$00
!byte $00,$00,$00,$00,$00,$18,$18,$30
!byte $00,$00,$00,$7e,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$18,$18,$00
!byte $00,$03,$06,$0c,$18,$30,$60,$00
!byte $3c,$66,$6e,$76,$66,$66,$3c,$00
!byte $18,$18,$38,$18,$18,$18,$7e,$00
!byte $3c,$66,$06,$0c,$30,$60,$7e,$00
!byte $3c,$66,$06,$1c,$06,$66,$3c,$00
!byte $06,$0e,$1e,$66,$7f,$06,$06,$00
!byte $7e,$60,$7c,$06,$06,$66,$3c,$00
!byte $3c,$66,$60,$7c,$66,$66,$3c,$00
!byte $7e,$66,$0c,$18,$18,$18,$18,$00
!byte $3c,$66,$66,$3c,$66,$66,$3c,$00
!byte $3c,$66,$66,$3e,$06,$66,$3c,$00
!byte $00,$00,$18,$00,$00,$18,$00,$00
!byte $00,$00,$18,$00,$00,$18,$18,$30
!byte $0e,$18,$30,$60,$30,$18,$0e,$00
!byte $00,$00,$7e,$00,$7e,$00,$00,$00
!byte $70,$18,$0c,$06,$0c,$18,$70,$00
!byte $3c,$66,$06,$0c,$18,$00,$18,$00
!byte $00,$00,$00,$ff,$ff,$00,$00,$00
!byte $08,$1c,$3e,$7f,$7f,$1c,$3e,$00
!byte $18,$18,$18,$18,$18,$18,$18,$18
!byte $00,$00,$00,$ff,$ff,$00,$00,$00
!byte $00,$00,$ff,$ff,$00,$00,$00,$00
!byte $00,$ff,$ff,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$ff,$ff,$00,$00
!byte $30,$30,$30,$30,$30,$30,$30,$30
!byte $0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c
!byte $00,$00,$00,$e0,$f0,$38,$18,$18
!byte $18,$18,$1c,$0f,$07,$00,$00,$00
!byte $18,$18,$38,$f0,$e0,$00,$00,$00
!byte $c0,$c0,$c0,$c0,$c0,$c0,$ff,$ff
!byte $c0,$e0,$70,$38,$1c,$0e,$07,$03
!byte $03,$07,$0e,$1c,$38,$70,$e0,$c0
!byte $ff,$ff,$c0,$c0,$c0,$c0,$c0,$c0
!byte $ff,$ff,$03,$03,$03,$03,$03,$03
!byte $00,$3c,$7e,$7e,$7e,$7e,$3c,$00
!byte $00,$00,$00,$00,$00,$ff,$ff,$00
!byte $36,$7f,$7f,$7f,$3e,$1c,$08,$00
!byte $60,$60,$60,$60,$60,$60,$60,$60
!byte $00,$00,$00,$07,$0f,$1c,$18,$18
!byte $c3,$e7,$7e,$3c,$3c,$7e,$e7,$c3
!byte $00,$3c,$7e,$66,$66,$7e,$3c,$00
!byte $18,$18,$66,$66,$18,$18,$3c,$00
!byte $06,$06,$06,$06,$06,$06,$06,$06
!byte $08,$1c,$3e,$7f,$3e,$1c,$08,$00
!byte $18,$18,$18,$ff,$ff,$18,$18,$18
!byte $c0,$c0,$30,$30,$c0,$c0,$30,$30
!byte $18,$18,$18,$18,$18,$18,$18,$18
!byte $00,$00,$03,$3e,$76,$36,$36,$00
!byte $ff,$7f,$3f,$1f,$0f,$07,$03,$01
!byte $00,$00,$00,$00,$00,$00,$00,$00
!byte $f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0
!byte $00,$00,$00,$00,$ff,$ff,$ff,$ff
!byte $ff,$00,$00,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$00,$00,$ff
!byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
!byte $cc,$cc,$33,$33,$cc,$cc,$33,$33
!byte $03,$03,$03,$03,$03,$03,$03,$03
!byte $00,$00,$00,$00,$cc,$cc,$33,$33
!byte $ff,$fe,$fc,$f8,$f0,$e0,$c0,$80
!byte $03,$03,$03,$03,$03,$03,$03,$03
!byte $18,$18,$18,$1f,$1f,$18,$18,$18
!byte $00,$00,$00,$00,$0f,$0f,$0f,$0f
!byte $18,$18,$18,$1f,$1f,$00,$00,$00
!byte $00,$00,$00,$f8,$f8,$18,$18,$18
!byte $00,$00,$00,$00,$00,$00,$ff,$ff
!byte $00,$00,$00,$1f,$1f,$18,$18,$18
!byte $18,$18,$18,$ff,$ff,$00,$00,$00
!byte $00,$00,$00,$ff,$ff,$18,$18,$18
!byte $18,$18,$18,$f8,$f8,$18,$18,$18
!byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
!byte $e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0
!byte $07,$07,$07,$07,$07,$07,$07,$07
!byte $ff,$ff,$00,$00,$00,$00,$00,$00
!byte $ff,$ff,$ff,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$ff,$ff,$ff
!byte $03,$03,$03,$03,$03,$03,$ff,$ff
!byte $00,$00,$00,$00,$f0,$f0,$f0,$f0
!byte $0f,$0f,$0f,$0f,$00,$00,$00,$00
!byte $18,$18,$18,$f8,$f8,$00,$00,$00
!byte $f0,$f0,$f0,$f0,$00,$00,$00,$00
!byte $f0,$f0,$f0,$f0,$0f,$0f,$0f,$0f
!byte $c3,$99,$91,$91,$9f,$99,$c3,$ff
!byte $e7,$c3,$99,$81,$99,$99,$99,$ff
!byte $83,$99,$99,$83,$99,$99,$83,$ff
!byte $c3,$99,$9f,$9f,$9f,$99,$c3,$ff
!byte $87,$93,$99,$99,$99,$93,$87,$ff
!byte $81,$9f,$9f,$87,$9f,$9f,$81,$ff
!byte $81,$9f,$9f,$87,$9f,$9f,$9f,$ff
!byte $c3,$99,$9f,$91,$99,$99,$c3,$ff
!byte $99,$99,$99,$81,$99,$99,$99,$ff
!byte $c3,$e7,$e7,$e7,$e7,$e7,$c3,$ff
!byte $e1,$f3,$f3,$f3,$f3,$93,$c7,$ff
!byte $99,$93,$87,$8f,$87,$93,$99,$ff
!byte $9f,$9f,$9f,$9f,$9f,$9f,$81,$ff
!byte $9c,$88,$80,$94,$9c,$9c,$9c,$ff
!byte $99,$89,$81,$81,$91,$99,$99,$ff
!byte $c3,$99,$99,$99,$99,$99,$c3,$ff
!byte $83,$99,$99,$83,$9f,$9f,$9f,$ff
!byte $c3,$99,$99,$99,$99,$c3,$f1,$ff
!byte $83,$99,$99,$83,$87,$93,$99,$ff
!byte $c3,$99,$9f,$c3,$f9,$99,$c3,$ff
!byte $81,$e7,$e7,$e7,$e7,$e7,$e7,$ff
!byte $99,$99,$99,$99,$99,$99,$c3,$ff
!byte $99,$99,$99,$99,$99,$c3,$e7,$ff
!byte $9c,$9c,$9c,$94,$80,$88,$9c,$ff
!byte $99,$99,$c3,$e7,$c3,$99,$99,$ff
!byte $99,$99,$99,$c3,$e7,$e7,$e7,$ff
!byte $81,$f9,$f3,$e7,$cf,$9f,$81,$ff
!byte $c3,$cf,$cf,$cf,$cf,$cf,$c3,$ff
!byte $f3,$ed,$cf,$83,$cf,$9d,$03,$ff
!byte $c3,$f3,$f3,$f3,$f3,$f3,$c3,$ff
!byte $ff,$e7,$c3,$81,$e7,$e7,$e7,$e7
!byte $ff,$ef,$cf,$80,$80,$cf,$ef,$ff
!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte $e7,$e7,$e7,$e7,$ff,$ff,$e7,$ff
!byte $99,$99,$99,$ff,$ff,$ff,$ff,$ff
!byte $99,$99,$00,$99,$00,$99,$99,$ff
!byte $e7,$c1,$9f,$c3,$f9,$83,$e7,$ff
!byte $9d,$99,$f3,$e7,$cf,$99,$b9,$ff
!byte $c3,$99,$c3,$c7,$98,$99,$c0,$ff
!byte $f9,$f3,$e7,$ff,$ff,$ff,$ff,$ff
!byte $f3,$e7,$cf,$cf,$cf,$e7,$f3,$ff
!byte $cf,$e7,$f3,$f3,$f3,$e7,$cf,$ff
!byte $ff,$99,$c3,$00,$c3,$99,$ff,$ff
!byte $ff,$e7,$e7,$81,$e7,$e7,$ff,$ff
!byte $ff,$ff,$ff,$ff,$ff,$e7,$e7,$cf
!byte $ff,$ff,$ff,$81,$ff,$ff,$ff,$ff
!byte $ff,$ff,$ff,$ff,$ff,$e7,$e7,$ff
!byte $ff,$fc,$f9,$f3,$e7,$cf,$9f,$ff
!byte $c3,$99,$91,$89,$99,$99,$c3,$ff
!byte $e7,$e7,$c7,$e7,$e7,$e7,$81,$ff
!byte $c3,$99,$f9,$f3,$cf,$9f,$81,$ff
!byte $c3,$99,$f9,$e3,$f9,$99,$c3,$ff
!byte $f9,$f1,$e1,$99,$80,$f9,$f9,$ff
!byte $81,$9f,$83,$f9,$f9,$99,$c3,$ff
!byte $c3,$99,$9f,$83,$99,$99,$c3,$ff
!byte $81,$99,$f3,$e7,$e7,$e7,$e7,$ff
!byte $c3,$99,$99,$c3,$99,$99,$c3,$ff
!byte $c3,$99,$99,$c1,$f9,$99,$c3,$ff
!byte $ff,$ff,$e7,$ff,$ff,$e7,$ff,$ff
!byte $ff,$ff,$e7,$ff,$ff,$e7,$e7,$cf
!byte $f1,$e7,$cf,$9f,$cf,$e7,$f1,$ff
!byte $ff,$ff,$81,$ff,$81,$ff,$ff,$ff
!byte $8f,$e7,$f3,$f9,$f3,$e7,$8f,$ff
!byte $c3,$99,$f9,$f3,$e7,$ff,$e7,$ff
!byte $ff,$ff,$ff,$00,$00,$ff,$ff,$ff
!byte $f7,$e3,$c1,$80,$80,$e3,$c1,$ff
!byte $e7,$e7,$e7,$e7,$e7,$e7,$e7,$e7
!byte $ff,$ff,$ff,$00,$00,$ff,$ff,$ff
!byte $ff,$ff,$00,$00,$ff,$ff,$ff,$ff
!byte $ff,$00,$00,$ff,$ff,$ff,$ff,$ff
!byte $ff,$ff,$ff,$ff,$00,$00,$ff,$ff
!byte $cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf
!byte $f3,$f3,$f3,$f3,$f3,$f3,$f3,$f3
!byte $ff,$ff,$ff,$1f,$0f,$c7,$e7,$e7
!byte $e7,$e7,$e3,$f0,$f8,$ff,$ff,$ff
!byte $e7,$e7,$c7,$0f,$1f,$ff,$ff,$ff
!byte $3f,$3f,$3f,$3f,$3f,$3f,$00,$00
!byte $3f,$1f,$8f,$c7,$e3,$f1,$f8,$fc
!byte $fc,$f8,$f1,$e3,$c7,$8f,$1f,$3f
!byte $00,$00,$3f,$3f,$3f,$3f,$3f,$3f
!byte $00,$00,$fc,$fc,$fc,$fc,$fc,$fc
!byte $ff,$c3,$81,$81,$81,$81,$c3,$ff
!byte $ff,$ff,$ff,$ff,$ff,$00,$00,$ff
!byte $c9,$80,$80,$80,$c1,$e3,$f7,$ff
!byte $9f,$9f,$9f,$9f,$9f,$9f,$9f,$9f
!byte $ff,$ff,$ff,$f8,$f0,$e3,$e7,$e7
!byte $3c,$18,$81,$c3,$c3,$81,$18,$3c
!byte $ff,$c3,$81,$99,$99,$81,$c3,$ff
!byte $e7,$e7,$99,$99,$e7,$e7,$c3,$ff
!byte $f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9
!byte $f7,$e3,$c1,$80,$c1,$e3,$f7,$ff
!byte $e7,$e7,$e7,$00,$00,$e7,$e7,$e7
!byte $3f,$3f,$cf,$cf,$3f,$3f,$cf,$cf
!byte $e7,$e7,$e7,$e7,$e7,$e7,$e7,$e7
!byte $ff,$ff,$fc,$c1,$89,$c9,$c9,$ff
!byte $00,$80,$c0,$e0,$f0,$f8,$fc,$fe
!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
!byte $ff,$ff,$ff,$ff,$00,$00,$00,$00
!byte $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
!byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
!byte $33,$33,$cc,$cc,$33,$33,$cc,$cc
!byte $fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc
!byte $ff,$ff,$ff,$ff,$33,$33,$cc,$cc
!byte $00,$01,$03,$07,$0f,$1f,$3f,$7f
!byte $fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc
!byte $e7,$e7,$e7,$e0,$e0,$e7,$e7,$e7
!byte $ff,$ff,$ff,$ff,$f0,$f0,$f0,$f0
!byte $e7,$e7,$e7,$e0,$e0,$ff,$ff,$ff
!byte $ff,$ff,$ff,$07,$07,$e7,$e7,$e7
!byte $ff,$ff,$ff,$ff,$ff,$ff,$00,$00
!byte $ff,$ff,$ff,$e0,$e0,$e7,$e7,$e7
!byte $e7,$e7,$e7,$00,$00,$ff,$ff,$ff
!byte $ff,$ff,$ff,$00,$00,$e7,$e7,$e7
!byte $e7,$e7,$e7,$07,$07,$e7,$e7,$e7
!byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
!byte $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
!byte $f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8
!byte $00,$00,$ff,$ff,$ff,$ff,$ff,$ff
!byte $00,$00,$00,$ff,$ff,$ff,$ff,$ff
!byte $ff,$ff,$ff,$ff,$ff,$00,$00,$00
!byte $fc,$fc,$fc,$fc,$fc,$fc,$00,$00
!byte $ff,$ff,$ff,$ff,$0f,$0f,$0f,$0f
!byte $f0,$f0,$f0,$f0,$ff,$ff,$ff,$ff
!byte $e7,$e7,$e7,$07,$07,$ff,$ff,$ff
!byte $0f,$0f,$0f,$0f,$ff,$ff,$ff,$ff
!byte  $0f, $0f, $0f, $0f, $f0, $f0, $f0, $f0
 
* = $CA00
;screen char data
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$a0,$a0,$a0,$20,$a0,$a0,$a0,$20,$a0,$a0,$a0,$20,$20,$a0,$60,$a0,$20,$20,$20,$a0,$a0,$a0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$a0,$20,$20,$20,$a0,$20,$a0,$20,$a0,$20,$a0,$20,$20,$a0,$60,$a0,$20,$20,$20,$a0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$60,$a0,$a0,$a0,$20,$a0,$20,$a0,$20,$a0,$a0,$a0,$20,$20,$a0,$a0,$60,$20,$20,$20,$a0,$a0,$a0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$a0,$20,$a0,$20,$a0,$20,$a0,$20,$a0,$20,$20,$a0,$20,$a0,$20,$20,$20,$a0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$a0,$a0,$a0,$20,$a0,$20,$a0,$20,$a0,$20,$a0,$20,$20,$a0,$20,$a0,$20,$20,$20,$a0,$a0,$a0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$1e,$1e,$1e,$1e,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$1e,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$10,$12,$05,$13,$13,$20,$13,$10,$01,$03,$05,$20,$14,$0f,$20,$13,$14,$01,$12,$14,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
!byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
