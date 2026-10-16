# Review Question and Exercises

## Short Answer

1. 다음 명령어들이 실행된 후 BX의 값은 무엇인가요?
* What will be the value of BX after the following instructions execute?
```assembly
mov  bx,0FFFFh
and  bx,6Bh

```
* Answer: `BX = 006Bh` (FFFFh와 AND하면 6Bh의 비트가 그대로 남습니다.)




2. 다음 명령어들이 실행된 후 BX의 값은 무엇인가요?
* What will be the value of BX after the following instructions execute?
```assembly
mov  bx,91BAh
and  bx,92h

```
* Answer: `BX = 0092h`
* 상위 바이트: `91h AND 00h = 00h`
* 하위 바이트: `10111010b (BAh) AND 10010010b (92h) = 10010010b (92h)`




3. 다음 명령어들이 실행된 후 BX의 값은 무엇인가요?
* What will be the value of BX after the following instructions execute?
```assembly
mov  bx,0649Bh
or   bx,3Ah

```
* Answer: `BX = 64BBh`
* 하위 바이트: `10011011b (9Bh) OR 00111010b (3Ah) = 10111011b (BBh)`, 상위 바이트 64h는 그대로 유지됩니다.




4. 다음 명령어들이 실행된 후 BX의 값은 무엇인가요?
* What will be the value of BX after the following instructions execute?
```assembly
mov  bx,029D6h
xor  bx,8181h

```
* Answer: `BX = A857h`
* 상위 바이트: `00101001b (29h) XOR 10000001b (81h) = 10101000b (A8h)`
* 하위 바이트: `11010110b (D6h) XOR 10000001b (81h) = 01010111b (57h)`




5. 다음 명령어들이 실행된 후 EBX의 값은 무엇인가요?
* What will be the value of EBX after the following instructions execute?
```assembly
mov  ebx,0AFAF649Bh
or   ebx,3A219604h

```
* Answer: `EBX = BFAFF69Fh`
* `AFh OR 3Ah = BFh`, `AFh OR 21h = AFh`, `64h OR 96h = F6h`, `9Bh OR 04h = 9Fh`




6. 다음 명령어들이 실행된 후 RBX의 값은 무엇인가요?
* What will be the value of RBX after the following instructions execute?
```assembly
mov  rbx,0AFAF649Bh
xor  rbx,0FFFFFFFFh

```
* Answer: `RBX = FFFFFFFF50509B64h`
* `mov rbx,0AFAF649Bh` 후 `RBX = 00000000AFAF649Bh`
* 64비트 XOR의 즉시값은 32비트이고 **64비트로 부호 확장**되므로, `0FFFFFFFFh`는 `FFFFFFFFFFFFFFFFh`가 됩니다. 따라서 64비트 전체가 반전됩니다.
* (상위 32비트를 0으로 생각하고 하위 32비트만 반전하면 `0000000050509B64h`가 되지만, 실제 CPU 동작은 위와 같습니다. 19번과 같은 원리입니다.)




7. 다음 명령어 시퀀스에서 표시된 위치의 AL 값을 2진수로 나타내세요.
* In the following instruction sequence, show the resulting value of AL where indicated, in binary:
```assembly
mov  al,01101111b
and  al,00101101b     ; a.
mov  al,6Dh
and  al,4Ah           ; b.
mov  al,00001111b
or   al,61h           ; c.
mov  al,94h
xor  al,37h           ; d.

```
* Answer:
* **a.** `AL = 00101101b`
* **b.** `AL = 01001000b` (01101101b AND 01001010b)
* **c.** `AL = 01101111b` (00001111b OR 01100001b)
* **d.** `AL = 10100011b` (10010100b XOR 00110111b)




8. 다음 명령어 시퀀스에서 표시된 위치의 AL 값을 16진수로 나타내세요.
* In the following instruction sequence, show the resulting value of AL where indicated, in hexadecimal:
```assembly
mov  al,7Ah
not  al               ; a.
mov  al,3Dh
and  al,74h           ; b.
mov  al,9Bh
or   al,35h           ; c.
mov  al,72h
xor  al,0DCh          ; d.

```
* Answer:
* **a.** `AL = 85h` (01111010b의 모든 비트를 반전 → 10000101b)
* **b.** `AL = 34h` (00111101b AND 01110100b = 00110100b)
* **c.** `AL = BFh` (10011011b OR 00110101b = 10111111b)
* **d.** `AL = AEh` (01110010b XOR 11011100b = 10101110b)




9. 다음 명령어 시퀀스에서 표시된 위치의 Carry, Zero, Sign 플래그 값을 나타내세요.
* In the following instruction sequence, show the values of the Carry, Zero, and Sign flags where indicated:
```assembly
mov  al,00001111b
test al,00000010b     ; a. CF=   ZF=   SF=
mov  al,00000110b
cmp  al,00000101b     ; b. CF=   ZF=   SF=
mov  al,00000101b
cmp  al,00000111b     ; c. CF=   ZF=   SF=

```
* Answer:
* **a.** `CF = 0, ZF = 0, SF = 0` (AND 결과 00000010b ≠ 0, TEST는 항상 CF를 지움)
* **b.** `CF = 0, ZF = 0, SF = 0` (6 - 5 = 1)
* **c.** `CF = 1, ZF = 0, SF = 1` (5 - 7 = -2 = 11111110b, 작은 수에서 큰 수를 빼므로 빌림 발생)




10. ECX의 내용에 따라 분기하는 조건 점프 명령어는 무엇인가요?
* Which conditional jump instruction executes a branch based on the contents of ECX?
* Answer: `JECXZ` (ECX = 0이면 점프. 16비트는 JCXZ, 64비트는 JRCXZ)




11. JA와 JNBE는 Zero 플래그와 Carry 플래그에 어떤 영향을 받나요?
* How are JA and JNBE affected by the Zero and Carry flags?
* Answer: **CF = 0 이고 ZF = 0** 일 때만 점프합니다. (destination이 source보다 크다는 뜻이며, 둘 중 하나라도 1이면 점프하지 않습니다.)




12. 다음 코드가 실행된 후 EDX의 최종 값은 무엇인가요?
* What will be the final value in EDX after this code executes?
```assembly
        mov  edx,1
        mov  eax,7FFFh
        cmp  eax,8000h
        jl   L1
        mov  edx,0
L1:

```
* Answer: `EDX = 1` (32비트에서 7FFFh와 8000h는 모두 양수이고 7FFFh < 8000h이므로 JL이 점프합니다.)




13. 다음 코드가 실행된 후 EDX의 최종 값은 무엇인가요?
* What will be the final value in EDX after this code executes?
```assembly
        mov  edx,1
        mov  eax,7FFFh
        cmp  eax,8000h
        jb   L1
        mov  edx,0
L1:

```
* Answer: `EDX = 1` (부호 없는 비교에서도 7FFFh < 8000h이므로 JB가 점프합니다.)




14. 다음 코드가 실행된 후 EDX의 최종 값은 무엇인가요?
* What will be the final value in EDX after this code executes?
```assembly
        mov  edx,1
        mov  eax,7FFFh
        cmp  eax,0FFFF8000h
        jl   L2
        mov  edx,0
L2:

```
* Answer: `EDX = 0` (부호 있는 비교에서 0FFFF8000h는 -32768이므로 7FFFh(+32767)가 더 큽니다. JL이 점프하지 않습니다.)




15. (참/거짓): 다음 코드는 Target 레이블로 점프한다.
* (True/False): The following code will jump to the label named Target.
```assembly
mov  eax,-30
cmp  eax,-50
jg   Target

```
* Answer: True (부호 있는 비교에서 -30 > -50)


16. (참/거짓): 다음 코드는 Target 레이블로 점프한다.
* (True/False): The following code will jump to the label named Target.
```assembly
mov  eax,-42
cmp  eax,26
ja   Target

```
* Answer: True (JA는 부호 없는 비교이므로 -42 = FFFFFFD6h가 26보다 큰 값으로 취급됩니다.)




17. 다음 명령어들이 실행된 후 RBX의 값은 무엇인가요?
* What will be the value of RBX after the following instructions execute?
```assembly
mov  rbx,0FFFFFFFFFFFFFFFFh
and  rbx,80h

```
* Answer: `RBX = 0000000000000080h`




18. 다음 명령어들이 실행된 후 RBX의 값은 무엇인가요?
* What will be the value of RBX after the following instructions execute?
```assembly
mov  rbx,0FFFFFFFFFFFFFFFFh
and  rbx,808080h

```
* Answer: `RBX = 0000000000808080h`




19. 다음 명령어들이 실행된 후 RBX의 값은 무엇인가요?
* What will be the value of RBX after the following instructions execute?
```assembly
mov  rbx,0FFFFFFFFFFFFFFFFh
and  rbx,80808080h

```
* Answer: `RBX = FFFFFFFF80808080h`
* 32비트 즉시값 `80808080h`는 최상위 비트가 1이므로 64비트로 **부호 확장**되어 `FFFFFFFF80808080h`가 됩니다. 따라서 상위 32비트는 지워지지 않습니다.
