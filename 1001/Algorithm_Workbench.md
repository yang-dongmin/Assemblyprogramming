# Review Question and Exercises

## Algorithm Workbench

1. three라는 이름의 doubleword 변수에서 상위 워드와 하위 워드를 서로 교환하는 MOV 명령어 시퀀스를 작성하세요.
* Write a sequence of MOV instructions that will exchange the upper and lower words in a doubleword variable named three.
* Answer:
```assembly
mov ax, WORD PTR three        ; 하위 워드를 AX에 저장
mov bx, WORD PTR three+2      ; 상위 워드를 BX에 저장
mov WORD PTR three, bx        ; 상위 워드 → 하위 위치
mov WORD PTR three+2, ax      ; 하위 워드 → 상위 위치

```




2. XCHG 명령어를 세 번 이하로 사용하여 4개의 8비트 레지스터 값의 순서를 A,B,C,D에서 B,C,D,A로 재배열하세요.
* Using the XCHG instruction no more than three times, reorder the values in four 8-bit registers from the order A,B,C,D to B,C,D,A.
* Answer:
```assembly
; AL = A, BL = B, CL = C, DL = D 라고 가정
xchg al,bl    ; B, A, C, D
xchg bl,cl    ; B, C, A, D
xchg cl,dl    ; B, C, D, A

```




3. 전송되는 메시지에는 종종 데이터 바이트와 합쳐 1인 비트의 개수가 짝수가 되도록 만드는 패리티 비트가 포함됩니다. AL 레지스터의 메시지 바이트가 01110101이라고 가정할 때, 산술 명령어와 Parity 플래그를 함께 사용하여 이 메시지 바이트가 짝수 패리티인지 홀수 패리티인지 판단하는 방법을 보여주세요.
* Transmitted messages often include a parity bit whose value is combined with a data byte to produce an even number of 1 bits. Suppose a message byte in the AL register contains 01110101. Show how you could use the Parity flag combined with an arithmetic instruction to determine if this message byte has even or odd parity.
* Answer:
```assembly
mov al,01110101b
add al,0          ; 값은 변하지 않고 플래그만 갱신됨
                  ; PF = 1 이면 짝수 패리티, PF = 0 이면 홀수 패리티

```


* **결과:** 01110101b에는 1인 비트가 5개(홀수) 있으므로 `PF = 0`이 되며, 홀수 패리티임을 알 수 있습니다. 따라서 짝수 패리티를 맞추려면 패리티 비트를 1로 설정해야 합니다.




4. 바이트 피연산자를 사용하여 두 음의 정수를 더하고 Overflow 플래그가 설정되도록 하는 코드를 작성하세요.
* Write code using byte operands that adds two negative integers and causes the Overflow flag to be set.
* Answer:
```assembly
mov al,-128       ; AL = 80h
add al,-1         ; AL = 7Fh (+127), OF = 1

```




5. 덧셈을 사용하여 Zero 플래그와 Carry 플래그를 동시에 설정하는 두 개의 명령어 시퀀스를 작성하세요.
* Write a sequence of two instructions that use addition to set the Zero and Carry flags at the same time.
* Answer:
```assembly
mov al,0FFh
add al,1          ; AL = 00h, ZF = 1, CF = 1

```




6. 뺄셈을 사용하여 Carry 플래그를 설정하는 두 개의 명령어 시퀀스를 작성하세요.
* Write a sequence of two instructions that set the Carry flag using subtraction.
* Answer:
```assembly
mov al,1
sub al,2          ; AL = FFh, CF = 1 (작은 부호 없는 수에서 큰 수를 뺌)

```




7. 다음 산술 표현식을 어셈블리 언어로 구현하세요: EAX = -val2 + 7 - val3 + val1. val1, val2, val3는 32비트 정수 변수라고 가정합니다.
* Implement the following arithmetic expression in assembly language: EAX = –val2 + 7 – val3 + val1. Assume that val1, val2, and val3 are 32-bit integer variables.
* Answer:
```assembly
mov eax,val2      ; EAX = val2
neg eax           ; EAX = -val2
add eax,7         ; EAX = -val2 + 7
sub eax,val3      ; EAX = -val2 + 7 - val3
add eax,val1      ; EAX = -val2 + 7 - val3 + val1

```




8. 스케일 팩터(scale factor)를 사용한 인덱스 주소 지정 방식으로 doubleword 배열을 순회하며 요소들의 합을 계산하는 루프를 작성하세요.
* Write a loop that iterates through a doubleword array and calculates the sum of its elements using a scale factor with indexed addressing.
* Answer:
```assembly
.data
array DWORD 10,20,30,40,50
.code
mov eax,0                     ; 합계 = 0
mov esi,0                     ; 인덱스 = 0
mov ecx,LENGTHOF array        ; 루프 카운터
L1:
    add eax,array[esi*TYPE array]   ; 스케일 팩터(4) 사용
    inc esi
    loop L1
; EAX = 150

```




9. 다음 표현식을 어셈블리 언어로 구현하세요: AX = (val2 + BX) - val4. val2와 val4는 16비트 정수 변수라고 가정합니다.
* Implement the following expression in assembly language: AX = (val2 + BX) – val4. Assume that val2 and val4 are 16-bit integer variables.
* Answer:
```assembly
mov ax,val2       ; AX = val2
add ax,bx         ; AX = val2 + BX
sub ax,val4       ; AX = (val2 + BX) - val4

```




10. Carry 플래그와 Overflow 플래그를 동시에 설정하는 두 개의 명령어 시퀀스를 작성하세요.
* Write a sequence of two instructions that set both the Carry and Overflow flags at the same time.
* Answer:
```assembly
mov al,80h
add al,80h        ; AL = 00h, CF = 1, OF = 1 ((-128) + (-128) = -256)

```




11. INC와 DEC 명령어를 실행한 후 Zero 플래그를 사용하여 부호 없는 오버플로를 나타내는 방법을 보여주는 명령어 시퀀스를 작성하세요.
* Write a sequence of instructions showing how the Zero flag could be used to indicate unsigned overflow after executing INC and DEC instructions.
* Answer:
```assembly
; INC와 DEC는 Carry 플래그에 영향을 주지 않으므로 Zero 플래그로 판단
mov al,0FFh
inc al            ; AL = 00h, ZF = 1 → 부호 없는 오버플로 발생 (FFh → 00h)

mov bl,1
dec bl            ; BL = 00h, ZF = 1 → 0에 도달했으므로
                  ; 다음 DEC 실행 시 언더플로(00h → FFh)가 발생함을 알 수 있음

```


* **설명:** INC/DEC는 CF를 변경하지 않으므로, 결과가 0이 되었는지(ZF = 1)를 확인하여 부호 없는 값의 경계(랩어라운드)를 감지할 수 있습니다.




* 12~18번 문제에는 다음 데이터 정의를 사용하세요.
* Use the following data definitions for Questions 12–18:
```assembly
.data
myBytes BYTE 10h,20h,30h,40h
myWords WORD 3 DUP(?),2000h
myString BYTE "ABCDE"

```




12. myBytes가 짝수 주소에 정렬되도록 주어진 데이터에 지시어를 삽입하세요.
* Insert a directive in the given data that aligns myBytes to an even-numbered address.
* Answer:
```assembly
.data
ALIGN 2
myBytes BYTE 10h,20h,30h,40h

```




13. 다음 각 명령어가 실행된 후 EAX의 값은 무엇인가요?
* What will be the value of EAX after each of the following instructions execute?
```assembly
mov eax,TYPE myBytes        ; a.
mov eax,LENGTHOF myBytes    ; b.
mov eax,SIZEOF myBytes      ; c.
mov eax,TYPE myWords        ; d.
mov eax,LENGTHOF myWords    ; e.
mov eax,SIZEOF myWords      ; f.
mov eax,SIZEOF myString     ; g.

```
* Answer:
* **a.** `1`
* **b.** `4`
* **c.** `4`
* **d.** `2`
* **e.** `4`
* **f.** `8`
* **g.** `5`




14. myBytes의 처음 두 바이트를 DX 레지스터로 이동하는 단일 명령어를 작성하세요. 결과 값은 2010h가 되어야 합니다.
* Write a single instruction that moves the first two bytes in myBytes to the DX register. The resulting value will be 2010h.
* Answer:
```assembly
mov dx, WORD PTR myBytes      ; DX = 2010h (리틀 엔디안)

```




15. myWords의 두 번째 바이트를 AL 레지스터로 이동하는 명령어를 작성하세요.
* Write an instruction that moves the second byte in myWords to the AL register.
* Answer:
```assembly
mov al, BYTE PTR myWords+1

```




16. myBytes의 네 바이트 전체를 EAX 레지스터로 이동하는 명령어를 작성하세요.
* Write an instruction that moves all four bytes in myBytes to the EAX register.
* Answer:
```assembly
mov eax, DWORD PTR myBytes    ; EAX = 40302010h

```




17. myWords를 32비트 레지스터로 직접 이동할 수 있도록 주어진 데이터에 LABEL 지시어를 삽입하세요.
* Insert a LABEL directive in the given data that permits myWords to be moved directly to a 32-bit register.
* Answer:
```assembly
.data
myBytes BYTE 10h,20h,30h,40h
myWordsD LABEL DWORD
myWords WORD 3 DUP(?),2000h
myString BYTE "ABCDE"
.code
mov eax,myWordsD

```




18. myBytes를 16비트 레지스터로 직접 이동할 수 있도록 주어진 데이터에 LABEL 지시어를 삽입하세요.
* Insert a LABEL directive in the given data that permits myBytes to be moved directly to a 16-bit register.
* Answer:
```assembly
.data
myBytesW LABEL WORD
myBytes BYTE 10h,20h,30h,40h
myWords WORD 3 DUP(?),2000h
myString BYTE "ABCDE"
.code
mov ax,myBytesW               ; AX = 2010h

```
