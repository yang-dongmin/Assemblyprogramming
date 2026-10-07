# Review Question and Exercises

## Short Answer

1. (a)와 (b)로 표시된 각 줄이 실행된 후 EDX의 값은 무엇인가요?
* What will be the value in EDX after each of the lines marked (a) and (b) execute?
```assembly
.data
one WORD 8002h
two WORD 4321h
.code
mov edx,21348041h
movsx edx,one       ; (a)
movsx edx,two       ; (b)

```
* Answer:
* **(a)** `EDX = FFFF8002h` (8002h의 최상위 비트가 1이므로 부호 확장 시 상위 16비트가 1로 채워집니다.)
* **(b)** `EDX = 00004321h` (4321h의 최상위 비트가 0이므로 상위 16비트가 0으로 채워집니다.)




2. 다음 줄들이 실행된 후 EAX의 값은 무엇인가요?
* What will be the value in EAX after the following lines execute?
```assembly
mov eax,1002FFFFh
inc ax

```
* Answer: `EAX = 10020000h` (AX = FFFFh에 1을 더하면 0000h가 되며, 16비트 연산이므로 캐리가 상위 16비트로 전달되지 않습니다.)




3. 다음 줄들이 실행된 후 EAX의 값은 무엇인가요?
* What will be the value in EAX after the following lines execute?
```assembly
mov eax,30020000h
dec ax

```
* Answer: `EAX = 3002FFFFh` (AX = 0000h에서 1을 빼면 FFFFh가 되며, 상위 16비트는 영향을 받지 않습니다.)




4. 다음 줄들이 실행된 후 EAX의 값은 무엇인가요?
* What will be the value in EAX after the following lines execute?
```assembly
mov eax,1002FFFFh
neg ax

```
* Answer: `EAX = 10020001h` (AX = FFFFh(-1)의 2의 보수는 0001h(+1)입니다.)




5. 다음 줄들이 실행된 후 Parity 플래그의 값은 무엇인가요?
* What will be the value of the Parity flag after the following lines execute?
```assembly
mov al,1
add al,3

```
* Answer: `PF = 0` (결과 AL = 4 = 00000100b로 1인 비트의 개수가 1개(홀수)이므로 Parity 플래그가 클리어됩니다.)




6. 다음 줄들이 실행된 후 EAX와 Sign 플래그의 값은 무엇인가요?
* What will be the value of EAX and the Sign flag after the following lines execute?
```assembly
mov eax,5
sub eax,6

```
* Answer: `EAX = FFFFFFFFh (-1)`, `SF = 1` (결과가 음수이므로 Sign 플래그가 설정됩니다.)




7. 다음 코드에서 AL의 값은 부호 있는 바이트로 의도되었습니다. 최종 AL 값이 유효한 부호 있는 범위 안에 있는지 판단하는 데 Overflow 플래그가 도움이 되는지, 혹은 도움이 되지 않는지 설명하세요.
* In the following code, the value in AL is intended to be a signed byte. Explain how the Overflow flag helps, or does not help you, to determine whether the final value in AL falls within a valid signed range.
```assembly
mov al,-1
add al,130

```
* Answer:
* **결과:** `AL = 81h (-127)`, `OF = 0`
* **설명:** 130은 부호 있는 바이트의 범위(-128 ~ +127)를 벗어나므로 어셈블러는 이를 82h로 저장하며, CPU는 이 값을 -126으로 해석합니다. 따라서 CPU 입장에서는 (-1) + (-126) = -127 연산이 되어 오버플로가 발생하지 않습니다(OF = 0). 그러나 의도한 결과인 -1 + 130 = 129는 부호 있는 바이트 범위를 벗어나는 값입니다. 즉, 피연산자 자체가 이미 유효 범위를 벗어났기 때문에 **Overflow 플래그는 이 경우 도움이 되지 않습니다.**




8. 다음 명령어가 실행된 후 RAX에는 어떤 값이 들어 있나요?
* What value will RAX contain after the following instruction executes?
```assembly
mov rax,44445555h

```
* Answer: `RAX = 0000000044445555h` (32비트 상수를 64비트 레지스터로 이동하면 상위 32비트는 0으로 클리어됩니다.)




9. 다음 명령어들이 실행된 후 RAX에는 어떤 값이 들어 있나요?
* What value will RAX contain after the following instructions execute?
```assembly
.data
dwordVal DWORD 84326732h
.code
mov rax,0FFFFFFFF00000000h
mov rax,dwordVal

```
* Answer:
* `mov rax,dwordVal`은 64비트 레지스터(RAX)와 32비트 메모리 피연산자(DWORD)의 크기가 일치하지 않으므로 **어셈블 오류(operand size mismatch)** 가 발생합니다.
* 만약 `mov eax,dwordVal`로 작성한다면, 32비트 메모리 피연산자를 EAX로 이동할 때 RAX의 상위 32비트가 클리어되므로 `RAX = 0000000084326732h`가 됩니다.




10. 다음 명령어들이 실행된 후 EAX에는 어떤 값이 들어 있나요?
* What value will EAX contain after the following instructions execute?
```assembly
.data
dVal DWORD 12345678h
.code
mov ax,3
mov WORD PTR dVal+2,ax
mov eax,dVal

```
* Answer: `EAX = 00035678h` (dVal의 상위 워드(1234h)가 0003h로 덮어써집니다.)




11. 다음 명령어들이 실행된 후 EAX에는 무엇이 들어 있나요?
* What will EAX contain after the following instructions execute?
```assembly
.data
dVal DWORD ?
.code
mov dVal,12345678h
mov ax,WORD PTR dVal+2
add ax,3
mov WORD PTR dVal,ax
mov eax,dVal

```
* Answer: `EAX = 12341237h` (상위 워드 1234h에 3을 더한 1237h가 하위 워드에 저장됩니다.)




12. (예/아니오): 양의 정수에 음의 정수를 더할 때 Overflow 플래그가 설정될 수 있나요?
* (Yes/No): Is it possible to set the Overflow flag if you add a positive integer to a negative integer?
* Answer: No (부호가 다른 두 수를 더하면 결과는 항상 두 피연산자 사이의 값이 되므로 범위를 벗어날 수 없습니다.)


13. (예/아니오): 음의 정수에 음의 정수를 더해서 양수 결과가 나오면 Overflow 플래그가 설정되나요?
* (Yes/No): Will the Overflow flag be set if you add a negative integer to a negative integer and produce a positive result?
* Answer: Yes (두 음수의 합이 양수가 되는 것은 부호 있는 오버플로를 의미합니다.)


14. (예/아니오): NEG 명령어가 Overflow 플래그를 설정할 수 있나요?
* (Yes/No): Is it possible for the NEG instruction to set the Overflow flag?
* Answer: Yes (예: AL = -128(80h)에 NEG를 수행하면 +128은 부호 있는 바이트로 표현할 수 없으므로 결과는 다시 80h가 되고 OF = 1이 됩니다.)


15. (예/아니오): Sign 플래그와 Zero 플래그가 동시에 설정될 수 있나요?
* (Yes/No): Is it possible for both the Sign and Zero flags to be set at the same time?
* Answer: No (결과가 0이면 최상위 비트도 0이므로 Sign 플래그는 설정될 수 없습니다.)


* 16~19번 문제에는 다음 변수 정의를 사용하세요.
* Use the following variable definitions for Questions 16–19:
```assembly
.data
var1 SBYTE -4,-2,3,1
var2 WORD 1000h,2000h,3000h,4000h
var3 SWORD -16,-42
var4 DWORD 1,2,3,4,5

```




16. 다음 각 명령어가 유효한지 여부를 말하세요.
* For each of the following statements, state whether or not the instruction is valid:
```assembly
a. mov ax,var1
b. mov ax,var2
c. mov eax,var3
d. mov var2,var3
e. movzx ax,var2
f. movzx var2,al
g. mov ds,ax
h. mov ds,1000h

```
* Answer:
* **a.** 유효하지 않음 (16비트 레지스터와 8비트 변수의 크기가 다름)
* **b.** 유효함
* **c.** 유효하지 않음 (32비트 레지스터와 16비트 변수의 크기가 다름)
* **d.** 유효하지 않음 (메모리 → 메모리 직접 이동 불가)
* **e.** 유효하지 않음 (MOVZX의 소스는 목적지보다 작아야 함)
* **f.** 유효하지 않음 (MOVZX의 목적지는 반드시 레지스터여야 함)
* **g.** 유효함
* **h.** 유효하지 않음 (세그먼트 레지스터에 즉시값을 직접 이동할 수 없음)




17. 다음 각 명령어가 순서대로 실행된 후 목적지 피연산자의 16진수 값은 무엇인가요?
* What will be the hexadecimal value of the destination operand after each of the following instructions execute in sequence?
```assembly
mov al,var1          ; a.
mov ah,[var1+3]      ; b.

```
* Answer:
* **a.** `AL = FCh` (-4)
* **b.** `AH = 01h` (var1의 네 번째 요소 1)




18. 다음 각 명령어가 순서대로 실행된 후 목적지 피연산자의 값은 무엇인가요?
* What will be the value of the destination operand after each of the following instructions execute in sequence?
```assembly
mov ax,var2          ; a.
mov ax,[var2+4]      ; b.
mov ax,var3          ; c.
mov ax,[var3-2]      ; d.

```
* Answer:
* **a.** `AX = 1000h`
* **b.** `AX = 3000h` (var2의 세 번째 요소, 4바이트 오프셋)
* **c.** `AX = FFF0h` (-16)
* **d.** `AX = 4000h` (var3 바로 앞 2바이트는 var2의 마지막 요소)




19. 다음 각 명령어가 순서대로 실행된 후 목적지 피연산자의 값은 무엇인가요?
* What will be the value of the destination operand after each of the following instructions execute in sequence?
```assembly
mov    edx,var4      ; a.
movzx  edx,var2      ; b.
mov    edx,[var4+4]  ; c.
movsx  edx,var1      ; d.

```
* Answer:
* **a.** `EDX = 00000001h`
* **b.** `EDX = 00001000h`
* **c.** `EDX = 00000002h` (var4의 두 번째 요소)
* **d.** `EDX = FFFFFFFCh` (-4를 부호 확장)
