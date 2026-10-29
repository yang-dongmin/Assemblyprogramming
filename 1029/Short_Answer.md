# Review Question and Exercises

## Short Answer

1. 다음 코드에서 각 시프트/회전 명령어가 실행된 후 AL의 값을 나타내세요.
* In the following code sequence, show the value of AL after each shift or rotate instruction has executed:
```assembly
mov al,0D4h
shr al,1          ; a.
mov al,0D4h
sar al,1          ; b.
mov al,0D4h
sar al,4          ; c.
mov al,0D4h
rol al,1          ; d.

```
* Answer: (`D4h = 11010100b`)
* **a.** `AL = 6Ah` (01101010b, 빈 최상위 비트를 0으로 채움, CF = 0)
* **b.** `AL = EAh` (11101010b, 부호 비트 1을 복사해서 채움, CF = 0)
* **c.** `AL = FDh` (11111101b, 부호 비트 1이 4번 복사됨, CF = 0)
* **d.** `AL = A9h` (10101001b, 최상위 비트 1이 최하위 비트와 CF로 이동, CF = 1)




2. 다음 코드에서 각 시프트/회전 명령어가 실행된 후 AL의 값을 나타내세요.
* In the following code sequence, show the value of AL after each shift or rotate instruction has executed:
```assembly
mov al,0D4h
ror al,3          ; a.
mov al,0D4h
rol al,7          ; b.
stc
mov al,0D4h
rcl al,1          ; c.
stc
mov al,0D4h
rcr al,3          ; d.

```
* Answer: (`D4h = 11010100b`)
* **a.** `AL = 9Ah` (10011010b, 하위 3비트 `100`이 상위로 이동)
* **b.** `AL = 6Ah` (01101010b, 8비트에서 왼쪽 7번 회전 = 오른쪽 1번 회전)
* **c.** `AL = A9h` (10101001b, CF(1)가 최하위 비트로 들어가고 최상위 비트 1이 CF로, CF = 1)
* **d.** `AL = 3Ah` (00111010b, CF = 1)
* d 과정: CF를 포함한 9비트 `1 | 11010100`을 오른쪽으로 3번 회전

| 단계 | CF | AL |
| --- | --- | --- |
| 시작 | 1 | 11010100 |
| 1회 | 0 | 11101010 |
| 2회 | 0 | 01110101 |
| 3회 | 1 | 00111010 |




3. 다음 연산이 실행된 후 AX와 DX의 내용은 무엇인가요?
* What will be the contents of AX and DX after the following operation?
```assembly
mov dx,0
mov ax,222h
mov cx,100h
mul cx

```
* Answer: `DX = 0002h, AX = 2200h`
* `222h * 100h = 00022200h` → 상위 워드는 DX, 하위 워드는 AX에 저장됩니다. (DX ≠ 0 이므로 CF = 1)




4. 다음 연산이 실행된 후 AX의 내용은 무엇인가요?
* What will be the contents of AX after the following operation?
```assembly
mov ax,63h
mov bl,10h
div bl

```
* Answer: `AX = 0306h`
* `63h / 10h` = 99 / 16 → 몫 `AL = 06h`, 나머지 `AH = 03h`




5. 다음 연산이 실행된 후 EAX와 EDX의 내용은 무엇인가요?
* What will be the contents of EAX and EDX after the following operation?
```assembly
mov eax,123400h
mov edx,0
mov ebx,10h
div ebx

```
* Answer: `EAX = 00012340h, EDX = 00000000h`
* 16(10h)으로 나누는 것은 16진수 한 자리를 오른쪽으로 미는 것과 같으므로 몫은 `12340h`, 나머지는 `0`입니다.




6. 다음 연산이 실행된 후 AX와 DX의 내용은 무엇인가요?
* What will be the contents of AX and DX after the following operation?
```assembly
mov ax,4000h
mov dx,500h
mov bx,10h
div bx

```
* Answer: **나눗셈 오버플로(divide overflow)가 발생합니다.**
* 피제수 `DX:AX = 05004000h`, `05004000h / 10h = 00500400h`
* 몫 `500400h`는 16비트 AX에 들어갈 수 없으므로 프로세서 예외가 발생하여 프로그램이 중단됩니다. AX, DX의 값은 정해지지 않습니다.




7. 다음 명령어들이 실행된 후 BX의 내용은 무엇인가요?
* What will be the contents of BX after the following instructions execute?
```assembly
mov bx,5
stc
mov ax,60h
adc bx,ax

```
* Answer: `BX = 0066h`
* `ADC`는 `BX = BX + AX + CF = 5 + 60h + 1 = 66h` (MOV는 CF를 바꾸지 않으므로 CF = 1 유지)




8. 다음 코드를 64비트 모드에서 실행했을 때의 결과를 설명하세요.
* Describe the output when the following code executes in 64-bit mode:
```assembly
.data
dividend_hi  QWORD 00000108h
dividend_lo  QWORD 33300020h
divisor      QWORD 00000100h
.code
mov  rdx,dividend_hi
mov  rax,dividend_lo
div  divisor

```
* Answer: **나눗셈 오버플로(divide overflow) 예외가 발생합니다.**
* 피제수 `RDX:RAX = 0000000000000108 0000000033300020h`
* 몫 = `10800000000333000h` (17자리 16진수) → 64비트 RAX에 들어갈 수 없습니다.
* 일반적으로 **피제수의 상위 절반(RDX) ≥ 제수**이면 몫이 넘칩니다. 여기서는 `108h ≥ 100h`입니다.
* 참고: `dividend_hi`가 `08h`였다면 `RAX = 0800000000333000h`(몫), `RDX = 0000000000000020h`(나머지)가 됩니다.




9. 다음 프로그램은 val1에서 val2를 빼야 합니다. 모든 논리 오류를 찾아 수정하세요. (CLC는 Carry 플래그를 지웁니다)
* The following program is supposed to subtract val2 from val1. Find and correct all logic errors (CLC clears the Carry flag):
```assembly
.data
val1   QWORD 20403004362047A1h
val2   QWORD 055210304A2630B2h
result QWORD 0
.code
mov  cx,8                   ; loop counter
mov  esi,val1               ; set index to start
mov  edi,val2
clc                         ; clear Carry flag
top:
mov  al,BYTE PTR[esi]       ; get first number
sbb  al,BYTE PTR[edi]       ; subtract second
mov  BYTE PTR[esi],al       ; store the result
dec  esi
dec  edi
loop top

```
* Answer:
* **오류 1:** `mov cx,8` → 32비트 모드의 `LOOP`는 **ECX**를 사용하므로 ECX의 상위 16비트가 쓰레기 값이면 반복 횟수가 틀어집니다. → `mov ecx,8`
* **오류 2:** `mov esi,val1` / `mov edi,val2` → 변수의 **값**을 넣고 있습니다. 주소가 필요하므로 `OFFSET`을 사용해야 합니다. (게다가 val1은 QWORD라서 32비트 레지스터에 MOV할 수도 없습니다.)
* **오류 3:** `dec esi` / `dec edi` → x86은 리틀 엔디언이라 **최하위 바이트가 가장 낮은 주소**에 있습니다. 시작 주소에서 출발해 `inc`로 증가해야 합니다. (INC/DEC는 CF에 영향을 주지 않으므로 SBB의 borrow는 그대로 유지됩니다.)
* **오류 4:** 결과를 val1 자리에 저장하여 val1을 덮어쓰고, `result` 변수는 사용하지 않습니다. → 결과는 `result`에 저장해야 합니다.
* 수정한 코드:
```assembly
.data
val1   QWORD 20403004362047A1h
val2   QWORD 055210304A2630B2h
result QWORD 0
.code
    mov  ecx,8                      ; 루프 카운터 (8바이트)
    mov  esi,OFFSET val1            ; 최하위 바이트 주소부터 시작
    mov  edi,OFFSET val2
    mov  ebx,OFFSET result
    clc                             ; Carry 플래그 지우기
top:
    mov  al,BYTE PTR [esi]          ; 첫 번째 수의 바이트
    sbb  al,BYTE PTR [edi]          ; 두 번째 수의 바이트와 borrow를 뺌
    mov  BYTE PTR [ebx],al          ; result에 저장
    inc  esi                        ; INC는 CF를 바꾸지 않음
    inc  edi
    inc  ebx
    loop top                        ; result = 1AEE1FD3EBFA16EFh

```




10. 다음 명령어들을 64비트 모드에서 실행한 후 RAX의 16진수 값은 무엇인가요?
* What will be the hexadecimal contents of RAX after the following instructions execute in 64-bit mode?
```assembly
.data
multiplicand QWORD 0001020304050000h
.code
imul rax,multiplicand, 4

```
* Answer: `RAX = 0004080C10140000h`
* 3 피연산자 IMUL: `RAX = multiplicand * 4` → 각 바이트가 4배가 됩니다. (`01→04, 02→08, 03→0C, 04→10, 05→14`) 결과가 64비트 안에 들어가므로 OF = CF = 0
