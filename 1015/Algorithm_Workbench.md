# Review Question and Exercises

## Algorithm Workbench

1. AL에 들어 있는 ASCII 숫자를 대응하는 2진수 값으로 변환하는 단일 명령어를 작성하세요. AL에 이미 2진수 값(00h ~ 09h)이 들어 있다면 변경하지 않아야 합니다.
* Write a single instruction that converts an ASCII digit in AL to its corresponding binary value. If AL already contains a binary value (00h to 09h), leave it unchanged.
* Answer:
```assembly
and al,0Fh        ; 상위 4비트를 지움

```


* **설명:** ASCII 숫자 '0'~'9'는 30h~39h이므로 상위 4비트(0011)를 지우면 00h~09h가 됩니다. 이미 00h~09h인 값은 상위 4비트가 0이므로 바뀌지 않습니다.




2. 32비트 메모리 피연산자의 패리티를 계산하는 명령어들을 작성하세요. 힌트: 이 절에서 소개한 공식 B0 XOR B1 XOR B2 XOR B3를 사용하세요.
* Write instructions that calculate the parity of a 32-bit memory operand. Hint: Use the formula presented earlier in this section: B0 XOR B1 XOR B2 XOR B3.
* Answer:
```assembly
.data
memVal DWORD 12345678h
.code
mov al, BYTE PTR memVal         ; B0
xor al, BYTE PTR memVal+1       ; B0 XOR B1
xor al, BYTE PTR memVal+2       ; B0 XOR B1 XOR B2
xor al, BYTE PTR memVal+3       ; B0 XOR B1 XOR B2 XOR B3
                                ; PF = 1 이면 짝수 패리티, PF = 0 이면 홀수 패리티

```


* **설명:** Parity 플래그는 결과의 **하위 바이트**만 검사하므로, 네 바이트를 모두 XOR한 결과의 패리티가 32비트 전체의 패리티와 같습니다. (12345678h는 1인 비트가 13개 → 홀수 → PF = 0)




3. SetX와 SetY라는 두 비트 맵 집합이 주어졌을 때, SetX의 원소이지만 SetY의 원소는 아닌 것들을 나타내는 비트 문자열을 EAX에 만드는 명령어 시퀀스를 작성하세요.
* Given two bit-mapped sets named SetX and SetY, write a sequence of instructions that generate a bit string in EAX that represents members in SetX that are not members of SetY.
* Answer:
```assembly
mov eax,SetY
not eax           ; SetY의 여집합
and eax,SetX      ; SetX ∩ (SetY의 여집합) = SetX - SetY

```




4. DX의 부호 없는 정수가 CX의 정수보다 작거나 같으면 L1 레이블로 점프하는 명령어를 작성하세요.
* Write instructions that jump to label L1 when the unsigned integer in DX is less than or equal to the integer in CX.
* Answer:
```assembly
cmp dx,cx
jbe L1            ; 부호 없는 비교: DX <= CX

```




5. AX의 부호 있는 정수가 CX의 정수보다 크면 L2 레이블로 점프하는 명령어를 작성하세요.
* Write instructions that jump to label L2 when the signed integer in AX is greater than the integer in CX.
* Answer:
```assembly
cmp ax,cx
jg  L2            ; 부호 있는 비교: AX > CX

```




6. 먼저 AL의 비트 0과 비트 1을 지우는 명령어를 작성하세요. 그 다음 destination 피연산자가 0이면 L3 레이블로, 그렇지 않으면 L4 레이블로 점프해야 합니다.
* Write instructions that first clear bits 0 and 1 in AL. Then, if the destination operand is equal to zero, the code should jump to label L3. Otherwise, it should jump to label L4.
* Answer:
```assembly
and al,11111100b  ; 비트 0, 1 지우기
jz  L3            ; 결과가 0이면 L3
jmp L4            ; 아니면 L4

```




7. 다음 의사 코드를 어셈블리 언어로 구현하세요. val1과 X는 32비트 변수라고 가정합니다. (단락 평가 사용)
* Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that val1 and X are 32-bit variables.
```
if( val1 > ecx ) AND ( ecx > edx )
    X = 1
else
    X = 2;
```
* Answer:
```assembly
    cmp val1,ecx
    jbe L1            ; val1 <= ecx 이면 거짓 → else
    cmp ecx,edx
    jbe L1            ; ecx <= edx 이면 거짓 → else
    mov X,1           ; 둘 다 참
    jmp next
L1: mov X,2
next:

```


* **설명:** AND는 첫 번째 조건이 거짓이면 두 번째 조건을 검사하지 않고 바로 else로 갑니다. (부호 없는 정수로 가정. 부호 있는 정수라면 `jbe` 대신 `jle` 사용)




8. 다음 의사 코드를 어셈블리 언어로 구현하세요. X는 32비트 변수라고 가정합니다. (단락 평가 사용)
* Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that X is a 32-bit variable.
```
if( ebx > ecx ) OR ( ebx > val1 )
    X = 1
else
    X = 2
```
* Answer:
```assembly
    cmp ebx,ecx
    ja  L1            ; 첫 번째 조건이 참이면 바로 then
    cmp ebx,val1
    ja  L1            ; 두 번째 조건이 참이면 then
    mov X,2           ; 둘 다 거짓
    jmp next
L1: mov X,1
next:

```


* **설명:** OR는 첫 번째 조건이 참이면 두 번째 조건을 검사하지 않고 바로 then으로 갑니다.




9. 다음 의사 코드를 어셈블리 언어로 구현하세요. X는 32비트 변수라고 가정합니다. (단락 평가 사용)
* Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that X is a 32-bit variable.
```
if( ebx > ecx AND ebx > edx ) OR ( edx > eax )
    X = 1
else
    X = 2
```
* Answer:
```assembly
    cmp ebx,ecx
    jbe L2            ; ebx <= ecx → AND 부분 거짓, OR의 오른쪽 검사
    cmp ebx,edx
    ja  L1            ; AND 부분 참 → then
L2: cmp edx,eax
    jbe L3            ; edx <= eax → 전체 거짓
L1: mov X,1
    jmp next
L3: mov X,2
next:

```




10. 다음 의사 코드를 어셈블리 언어로 구현하세요. A, B, N은 32비트 부호 있는 정수라고 가정합니다. (단락 평가 사용)
* Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that A, B, and N are 32-bit signed integers.
```
while N > 0
    if N != 3 AND (N < A OR N > B)
        N = N – 2
    else
        N = N – 1
end while
```
* Answer:
```assembly
    mov eax,N
beginwhile:
    cmp eax,0
    jle endwhile          ; N <= 0 이면 루프 종료
    cmp eax,3
    je  elsePart          ; N == 3 이면 AND 전체가 거짓
    cmp eax,A
    jl  thenPart          ; N < A 이면 OR 참 → then
    cmp eax,B
    jle elsePart          ; N <= B 이면 OR 거짓 → else
thenPart:
    sub eax,2             ; N = N - 2
    jmp beginwhile
elsePart:
    dec eax               ; N = N - 1
    jmp beginwhile
endwhile:
    mov N,eax

```


* **설명:** 부호 있는 정수이므로 `jl`, `jle` 등 부호 있는 비교 점프를 사용합니다.
