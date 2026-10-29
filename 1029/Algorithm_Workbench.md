# Review Question and Exercises

## Algorithm Workbench

1. AX를 EAX로 부호 확장하는 시프트 명령어 시퀀스를 작성하세요. 즉, AX의 부호 비트를 EAX의 상위 16비트에 복사해야 합니다. CWD 명령어는 사용하지 마세요.
* Write a sequence of shift instructions that cause AX to be sign-extended into EAX. In other words, the sign bit of AX is copied into the upper 16 bits of EAX. Do not use the CWD instruction.
* Answer:
```assembly
shl eax,16        ; AX를 EAX의 상위 16비트로 이동
sar eax,16        ; 부호 비트를 복사하며 다시 하위로 이동

```


* **설명:** 예를 들어 `AX = FF80h(-128)`이면 `SHL` 후 `EAX = FF800000h`, `SAR` 후 `EAX = FFFFFF80h`가 됩니다. SAR은 빈 자리를 부호 비트로 채우기 때문에 부호 확장이 됩니다.




2. 명령어 집합에 회전 명령어가 없다고 가정합니다. SHR과 조건 점프 명령어를 사용하여 AL 레지스터의 내용을 오른쪽으로 1비트 회전하는 방법을 보이세요.
* Suppose the instruction set contained no rotate instructions. Show how you would use SHR and a conditional jump instruction to rotate the contents of the AL register 1 bit to the right.
* Answer:
```assembly
    shr al,1          ; 최하위 비트가 CF로 이동, 최상위 비트는 0
    jnc next          ; CF = 0 이면 그대로
    or  al,80h        ; CF = 1 이면 최상위 비트를 1로 설정
next:

```


* **설명:** ROR은 밀려난 최하위 비트를 최상위 비트로 옮기므로, CF가 1일 때만 비트 7을 1로 설정하면 같은 결과가 됩니다.




3. EAX의 내용에 16을 곱하는 논리 시프트 명령어를 작성하세요.
* Write a logical shift instruction that multiplies the contents of EAX by 16.
* Answer:
```assembly
shl eax,4         ; 2⁴ = 16

```




4. EBX를 4로 나누는 논리 시프트 명령어를 작성하세요.
* Write a logical shift instruction that divides EBX by 4.
* Answer:
```assembly
shr ebx,2         ; 2² = 4

```




5. DL 레지스터의 상위 절반과 하위 절반을 교환하는 단일 회전 명령어를 작성하세요.
* Write a single rotate instruction that exchanges the high and low halves of the DL register.
* Answer:
```assembly
rol dl,4          ; 4비트 회전 (ror dl,4 도 같은 결과)

```




6. AX 레지스터의 최상위 비트를 DX의 최하위 비트 자리로 시프트하고, DX를 왼쪽으로 1비트 시프트하는 단일 SHLD 명령어를 작성하세요.
* Write a single SHLD instruction that shifts the highest bit of the AX register into the lowest bit position of DX and shifts DX one bit to the left.
* Answer:
```assembly
shld dx,ax,1

```


* **설명:** SHLD는 destination(DX)을 왼쪽으로 시프트하고 빈 자리를 source(AX)의 최상위 비트로 채웁니다. AX는 바뀌지 않습니다.




7. 메모리의 세 바이트를 오른쪽으로 1비트 시프트하는 명령어 시퀀스를 작성하세요. 다음 테스트 데이터를 사용하세요.
* Write a sequence of instructions that shift three memory bytes to the right by 1 bit position. Use the following test data:
```assembly
byteArray BYTE 81h,20h,33h

```
* Answer:
```assembly
.data
byteArray BYTE 81h,20h,33h
.code
shr byteArray+2,1     ; 최상위 바이트, 최하위 비트가 CF로
rcr byteArray+1,1     ; 중간 바이트, CF를 최상위 비트로 받음
rcr byteArray,1       ; 최하위 바이트, CF를 최상위 비트로 받음
                      ; byteArray = 40h, 90h, 19h

```


* **설명:** 리틀 엔디언이므로 `byteArray+2`가 최상위 바이트입니다. 최상위 바이트부터 시프트하고, 밀려난 비트를 RCR로 다음 바이트에 넘겨줍니다.

| 바이트 | 시작값 | 결과 |
| --- | --- | --- |
| byteArray+2 | 33h (00110011) | 19h (00011001), CF = 1 |
| byteArray+1 | 20h (00100000) | 90h (10010000), CF = 0 |
| byteArray | 81h (10000001) | 40h (01000000), CF = 1 |




8. 메모리의 세 워드를 왼쪽으로 1비트 시프트하는 명령어 시퀀스를 작성하세요. 다음 테스트 데이터를 사용하세요.
* Write a sequence of instructions that shift three memory words to the left by 1 bit position. Use the following test data:
```assembly
wordArray WORD 810Dh, 0C064h,93ABh

```
* Answer:
```assembly
.data
wordArray WORD 810Dh,0C064h,93ABh
.code
shl wordArray,1       ; 최하위 워드, 최상위 비트가 CF로
rcl wordArray+2,1     ; 중간 워드, CF를 최하위 비트로 받음
rcl wordArray+4,1     ; 최상위 워드, CF를 최하위 비트로 받음
                      ; wordArray = 021Ah, 80C9h, 2757h

```


* **설명:** 왼쪽 시프트는 반대로 **최하위 워드부터** 시프트하고, 밀려난 비트를 RCL로 다음(상위) 워드에 넘겨줍니다.

| 워드 | 시작값 | 결과 |
| --- | --- | --- |
| wordArray | 810Dh | 021Ah, CF = 1 |
| wordArray+2 | C064h | 80C9h, CF = 1 |
| wordArray+4 | 93ABh | 2757h, CF = 1 |




9. 5에 3을 곱하고 그 결과를 16비트 변수 val1에 저장하는 명령어를 작성하세요.
* Write instructions that multiply 5 by 3 and store the result in a 16-bit variable val1.
* Answer:
```assembly
.data
val1 WORD ?
.code
mov ax,5
mov bx,3
mul bx            ; DX:AX = 15
mov val1,ax       ; val1 = 15

```




10. 276을 10으로 나누고 그 결과를 16비트 변수 val1에 저장하는 명령어를 작성하세요.
* Write instructions that divide 276 by 10 and store the result in a 16-bit variable val1.
* Answer:
```assembly
.data
val1 WORD ?
.code
mov dx,0          ; 피제수 상위 지우기
mov ax,276        ; 피제수 하위
mov bx,10         ; 제수
div bx            ; AX = 27 (몫), DX = 6 (나머지)
mov val1,ax       ; val1 = 27

```


* **설명:** 276은 8비트(AL)에 들어가지 않으므로 16비트 나눗셈을 사용합니다. 나누기 전에 DX를 반드시 0으로 지워야 합니다.




11. 32비트 부호 없는 피연산자를 사용하여 다음 C++ 식을 어셈블리 언어로 구현하세요.
* Implement the following C++ expression in assembly language, using 32-bit unsigned operands:
```
val1 = (val2 * val3) / (val4 - 3)
```
* Answer:
```assembly
mov eax,val2
mul val3          ; EDX:EAX = val2 * val3
mov ebx,val4
sub ebx,3         ; EBX = val4 - 3
div ebx           ; EAX = (val2 * val3) / (val4 - 3)
mov val1,eax

```


* **설명:** MUL의 64비트 곱(EDX:EAX)이 그대로 DIV의 피제수가 되므로 EDX를 따로 지울 필요가 없습니다.




12. 32비트 부호 있는 피연산자를 사용하여 다음 C++ 식을 어셈블리 언어로 구현하세요.
* Implement the following C++ expression in assembly language, using 32-bit signed operands:
```
val1 = (val2 / val3) * (val1 + val2)
```
* Answer:
```assembly
mov  eax,val2
cdq               ; EAX를 EDX로 부호 확장
idiv val3         ; EAX = val2 / val3
mov  ebx,val1
add  ebx,val2     ; EBX = val1 + val2
imul ebx          ; EDX:EAX = EAX * EBX
mov  val1,eax     ; 결과가 32비트 안에 들어간다고 가정

```


* **설명:** 부호 있는 나눗셈 전에는 `CDQ`로 피제수를 부호 확장해야 합니다. val1이 곱셈에 사용되므로 결과를 저장하기 전에 먼저 읽어야 합니다.




13. 부호 없는 8비트 이진 값을 10진수 형식으로 출력하는 프로시저를 작성하세요. 이진 값은 AL로 전달합니다. 입력 범위는 10진수 0 ~ 99로 제한됩니다. 책의 링크 라이브러리에서 호출할 수 있는 프로시저는 WriteChar뿐입니다. 프로시저는 약 8개의 명령어로 구성되어야 합니다.
* Write a procedure that displays an unsigned 8-bit binary value in decimal format. Pass the binary value in AL. The input range is limited to 0 to 99, decimal. The only procedure you can call from the book's link library is WriteChar. The procedure should contain approximately eight instructions. Here is a sample call:
```assembly
mov  al,65            ; range limit: 0 to 99
call showDecimal8

```
* Answer:
```assembly
;-----------------------------------------------------
; showDecimal8
;
; Displays an unsigned 8-bit value (0 ~ 99) in decimal.
; Receives: AL = binary value
; Returns:  nothing
;-----------------------------------------------------
showDecimal8 PROC
    push eax
    aam               ; AH = AL / 10 (십의 자리), AL = AL % 10 (일의 자리)
    or   ax,3030h     ; 두 자리를 ASCII로 변환
    push eax          ; 일의 자리 보관
    mov  al,ah
    call WriteChar    ; 십의 자리 출력
    pop  eax
    call WriteChar    ; 일의 자리 출력
    pop  eax
    ret
showDecimal8 ENDP

```


* **설명:** `AAM`은 AL을 10으로 나눠 몫을 AH, 나머지를 AL에 넣어 줍니다. `AL = 65`이면 `AX = 0605h` → `3635h` → `'6'`, `'5'` 출력. (0 ~ 9는 `"05"`처럼 앞에 0이 붙어 출력됩니다.)




14. 도전 과제: 알 수 없는 ASCII 10진수 두 개를 더한 결과로 AX = 0072h이고 Auxiliary Carry 플래그가 설정되었다고 가정합니다. Intel 64 and IA-32 Instruction Set Reference를 참고하여 AAA 명령어가 어떤 결과를 만드는지 구하고 설명하세요.
* Challenge: Suppose AX contains 0072h and the Auxiliary Carry flag is set as a result of adding two unknown ASCII decimal digits. Use the Intel 64 and IA-32 Instruction Set Reference to determine what output the AAA instruction would produce. Explain your answer.
* Answer: `AX = 0108h, AF = 1, CF = 1`
* Intel 매뉴얼의 AAA 동작:
```
IF ((AL AND 0FH) > 9) OR (AF = 1)
    THEN
        AX ← AX + 106H;
        AF ← 1;
        CF ← 1;
    ELSE
        AF ← 0;
        CF ← 0;
FI;
AL ← AL AND 0FH;
```
* **설명:** `AL AND 0Fh = 2`로 9보다 크지 않지만 **AF = 1**이므로 조정이 일어납니다.
* `AX = 0072h + 0106h = 0178h` → `AL = 78h AND 0Fh = 08h` → `AX = 0108h`
* 실제로 `'9' + '9' = 39h + 39h = 72h`이고, 하위 니블 `9 + 9 = 18`이 15를 넘어 AF가 설정된 경우입니다. 결과 `0108h`는 언팩 10진수 **18**로 올바른 답입니다.




15. 도전 과제: SUB, MOV, AND 명령어만 사용하여 x = n mod y를 계산하는 방법을 보이세요. n과 y의 값은 주어지며, n은 임의의 32비트 부호 없는 정수이고 y는 2의 거듭제곱이라고 가정합니다.
* Challenge: Using only SUB, MOV, and AND instructions, show how to calculate x = n mod y, assuming that you are given the values of n and y. You can assume that n is any 32-bit unsigned integer, and y is a power of 2.
* Answer:
```assembly
mov eax,y
sub eax,1         ; EAX = y - 1 (하위 비트 마스크)
mov ebx,n
and ebx,eax       ; EBX = n AND (y - 1) = n mod y
mov x,ebx

```


* **설명:** y가 2ᵏ이면 `y - 1`은 하위 k비트가 모두 1인 마스크가 됩니다. 2ᵏ으로 나눈 나머지는 n의 하위 k비트와 같으므로 AND로 구할 수 있습니다. (예: `n = 29, y = 8` → `11101b AND 00111b = 101b = 5`)




16. 도전 과제: SAR, ADD, XOR 명령어만 사용하여(조건 점프 없이) EAX 레지스터에 있는 부호 있는 정수의 절댓값을 계산하는 코드를 작성하세요. 힌트: 수에 1을 더하고 1의 보수를 취하면 부호를 바꿀 수 있습니다. 또한 정수를 모두 1인 값과 XOR하면 비트가 반전되고, 모두 0인 값과 XOR하면 정수가 바뀌지 않습니다.
* Challenge: Using only SAR, ADD, and XOR instructions (but no conditional jumps), write code that calculates the absolute value of the signed integer in the EAX register. Hints: A number can be negated by adding 1 to it and then forming its one's complement. Also, if you XOR an integer with all 1s, its 1s are reversed. On the other hand, if you XOR an integer with all zeros, the integer is unchanged.
* Answer:
```assembly
mov edx,eax       ; EAX 복사
sar edx,31        ; 양수면 EDX = 00000000h, 음수면 EDX = FFFFFFFFh (-1)
add eax,edx       ; 양수면 그대로, 음수면 EAX - 1
xor eax,edx       ; 양수면 그대로, 음수면 비트 반전 → -EAX

```


* **설명:** 2의 보수에서 `-x = NOT(x) + 1 = NOT(x - 1)` 입니다. (힌트의 "1을 더하고 1의 보수"는 순서를 바꾼 같은 원리이며, ADD와 XOR만으로 구현하려면 "1을 빼고(-1을 더하고) 반전"하는 순서를 사용합니다.) `SAR edx,31`로 부호 비트를 32비트 전체에 퍼뜨리면 양수일 때는 0(아무 변화 없음), 음수일 때는 -1(1을 빼고 비트 반전)이 되어 조건 점프 없이 절댓값을 구할 수 있습니다. (예: `EAX = -5 = FFFFFFFBh` → `+(-1)` → `FFFFFFFAh` → `XOR FFFFFFFFh` → `00000005h`)
* (MOV를 쓰지 않아야 한다면 첫 줄 대신 `xor edx,edx` / `add edx,eax`를 사용해도 됩니다.)
