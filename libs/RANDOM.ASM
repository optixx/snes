;Pseudo-Random Number Generator for SNES
;(C) 2001 Realtime Simulations and Roleplaying Games
;Coding by Grog

;There are numerous algorithms for generating psuedo-random numbers; I chose
; this one because it is fast and very easy to implement on a 65816:
;   R1, R2, R3, and R4 are 8-bit unsigned integers
;   R1 is the current random number, R2-R4 are the 2nd through 4th oldest
;   BYTE Random(DWORD seed=0){
;     static BYTE R1,R2,R3,R4;
;     if(seed != 0){
;       R1=seed>>24; R2=seed>>16; R3=seed>>8; R4=seed;
;     }
;     R4=R3; R3=R2; R2=R1;
;     if(R2>R3)
;       R1=R3+R4;
;     else
;       R1=R2+R4;
;     return R1;
;   }
;
;Note that the seed value should be as random as possible and cannot be zero
;This sequence starts to repeat after somewhere between 1.5 and 2 million
;iterations, according to my testing.  There is also an unfortunate bias
;towards odd numbers that I couldn't get out of it without complicating things
;more than I liked.  The bias isn't bad; there's about the odds of an odd num
;are about 60%.  This algorithm is plenty good for a game's needs, but is
;definately NOT scientific quality.  Note that this technique also needs 4
;bytes of RAM, preferably in direct page.

RandomBytes EQU $500            ;arbitrary RAM address for the Rand data
R1 EQU RandomBytes + 0
R2 EQU RandomBytes + 1
R3 EQU RandomBytes + 2
R4 EQU RandomBytes + 3


;RandomSeed -- seed the random number generator
;In:  X==Seed value (16-bit) low
;     Y==Seed value (16-bit) high
;Out: none
;Modifies: R1, R2, R3, R4, flags

RandomSeed:
  .index 16             ;Assume 16-bit index registers
  STX R1
  STY R3
  RTS


;Random -- return a pseudorandom number (8-bit)
;In: none
;Out: A==random number (8-bit)
;Modifies: R1, R2, R3, R4, A, Flags

Random:
  .mem 8                ;Assume 8-bit accumulator
  LDA R3
  STA R4                ;R4=R3
  LDA R2
  STA R3                ;R3=R2
  LDA R1
  STA R2                ;R2=R1
  CMP R3
  BMI R3_Greater        ;If R3>R2 Then Goto R3_Greater
  LDA R3
  CLC
  ADC R4
  STA R1                ;R1=R3+R4 MOD 256
  RTS                   ;Return R1
R3_Greater:
  CLC
  ADC R4                
  STA R1                ;R1=R2+R4 MOD 256
  RTS                   ;Return R1
