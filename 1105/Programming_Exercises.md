# Review Question and Exercises

## Programming Exercises

1. FindLargest 프로시저 (FindLargest Procedure)
* Create a procedure named FindLargest that receives two parameters: a pointer to a signed doubleword array, and a count of the array's length. The procedure must return the value of the largest array member in EAX. Use the PROC directive with a parameter list when declaring the procedure. Preserve all registers (except EAX) that are modified by the procedure. Write a test program that calls FindLargest and passes three different arrays of different lengths. Be sure to include negative values in your arrays. Create a PROTO declaration for FindLargest.
* **해석:** 부호 있는 doubleword 배열의 포인터와 배열 길이, 두 파라미터를 받는 FindLargest 프로시저를 만드세요. 프로시저는 배열에서 가장 큰 값을 EAX로 반환해야 합니다. 프로시저를 선언할 때 파라미터 목록이 있는 PROC 지시어를 사용하고, 프로시저가 변경하는 모든 레지스터(EAX 제외)를 보존하세요. 길이가 서로 다른 세 배열을 FindLargest에 전달하는 테스트 프로그램을 작성하고, 배열에는 반드시 음수를 포함하세요. FindLargest의 PROTO 선언도 작성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

FindLargest PROTO,
    pArray:PTR SDWORD,
    arrCount:DWORD

.data
array1 SDWORD -5, 12, 7, -30, 3
array2 SDWORD -100, -20, -3, -50
array3 SDWORD 25, -1, 80, 0, 79, -200, 64, 15

.code
main PROC
    INVOKE FindLargest, ADDR array1, LENGTHOF array1
    call WriteInt                      ; +12
    call Crlf

    INVOKE FindLargest, ADDR array2, LENGTHOF array2
    call WriteInt                      ; -3
    call Crlf

    INVOKE FindLargest, ADDR array3, LENGTHOF array3
    call WriteInt                      ; +80
    call Crlf

    exit
main ENDP

;-----------------------------------------------------
; FindLargest
;
; Finds the largest value in a signed doubleword array.
; Receives: pArray   = pointer to the array
;           arrCount = number of elements
; Returns:  EAX = largest value
;-----------------------------------------------------
FindLargest PROC USES ecx esi,
    pArray:PTR SDWORD,
    arrCount:DWORD

    mov esi, pArray
    mov ecx, arrCount
    mov eax, 80000000h                 ; 가장 작은 부호 있는 32비트 값
    jecxz done                         ; 원소가 없으면 종료

L1:
    cmp [esi], eax                     ; 현재 원소 > 최댓값?
    jle next                           ; 부호 있는 비교
    mov eax, [esi]                     ; 최댓값 갱신
next:
    add esi, TYPE SDWORD               ; 다음 원소
    loop L1

done:
    ret
FindLargest ENDP
END main

```


* **설명:** 최댓값의 초기값을 부호 있는 32비트의 최솟값(`80000000h` = -2,147,483,648)으로 두면 음수만 있는 배열도 올바르게 처리됩니다. 부호 있는 정수이므로 `JLE`(signed) 비교를 사용합니다. `USES ecx esi`로 변경한 레지스터를 보존합니다.
* **실행 결과:**
```
+12
-3
+80
```




2. 체스판 (Chess Board)
* Write a program that draws an 8 × 8 chess board, with alternating gray and white squares. You can use the SetTextColor and Gotoxy procedures from the Irvine32 library. Avoid the use of global variables, and use declared parameters in all procedures. Use short procedures that are focused on a single task.
* **해석:** 회색과 흰색 칸이 번갈아 나오는 8 × 8 체스판을 그리는 프로그램을 작성하세요. Irvine32 라이브러리의 SetTextColor와 Gotoxy 프로시저를 사용할 수 있습니다. 전역 변수를 사용하지 말고, 모든 프로시저에서 선언된 파라미터를 사용하세요. 한 가지 작업에 집중하는 짧은 프로시저들로 구성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

SQ_W = 4                               ; 칸 하나의 너비 (문자 수)
SQ_H = 2                               ; 칸 하나의 높이 (줄 수)

DrawBoard  PROTO, sqColor:DWORD
DrawSquare PROTO, row:DWORD, col:DWORD, bgColor:DWORD

.code
main PROC
    call Clrscr
    INVOKE DrawBoard, gray             ; 회색/흰색 체스판

    mov eax, lightGray + (black * 16)  ; 기본 색으로 복원
    call SetTextColor
    mov dh, 8 * SQ_H + 1               ; 체스판 아래로 커서 이동
    mov dl, 0
    call Gotoxy
    exit
main ENDP

;-----------------------------------------------------
; DrawBoard
;
; Draws an 8 x 8 board. (row + col) 이 짝수인 칸은
; 흰색, 홀수인 칸은 sqColor로 칠한다.
; Receives: sqColor = color of the colored squares
; Returns:  nothing
;-----------------------------------------------------
DrawBoard PROC USES eax esi edi,
    sqColor:DWORD

    mov esi, 0                         ; row = 0
rowLoop:
    mov edi, 0                         ; col = 0
colLoop:
    mov eax, esi
    add eax, edi
    test eax, 1                        ; (row + col) 홀수?
    jz  whiteSq
    INVOKE DrawSquare, esi, edi, sqColor
    jmp nextCol
whiteSq:
    INVOKE DrawSquare, esi, edi, white
nextCol:
    inc edi
    cmp edi, 8
    jb  colLoop
    inc esi
    cmp esi, 8
    jb  rowLoop
    ret
DrawBoard ENDP

;-----------------------------------------------------
; DrawSquare
;
; Draws one square at (row, col) with the given
; background color.
; Receives: row, col = square position (0 ~ 7)
;           bgColor  = background color
; Returns:  nothing
;-----------------------------------------------------
DrawSquare PROC USES eax ebx ecx edx,
    row:DWORD,
    col:DWORD,
    bgColor:DWORD

    mov eax, bgColor
    shl eax, 4                         ; 배경색 * 16, 글자색 = black(0)
    call SetTextColor

    mov ebx, 0                         ; 칸 안의 줄 번호
lineLoop:
    mov eax, row
    imul eax, SQ_H
    add eax, ebx
    mov dh, al                         ; 화면 행 = row * SQ_H + 줄 번호
    mov eax, col
    imul eax, SQ_W
    mov dl, al                         ; 화면 열 = col * SQ_W
    call Gotoxy

    mov ecx, SQ_W
    mov al, ' '
charLoop:
    call WriteChar                     ; 배경색이 칠해진 공백 출력
    loop charLoop

    inc ebx
    cmp ebx, SQ_H
    jb  lineLoop
    ret
DrawSquare ENDP
END main

```


* **설명:** 전역 변수 없이 모든 값을 파라미터로 전달합니다. `DrawBoard`는 칸의 색을 결정하고, `DrawSquare`는 칸 하나를 그리는 일만 합니다. 콘솔 문자는 세로로 길쭉하므로 칸을 `4 × 2` 문자로 그리면 정사각형에 가깝게 보입니다. 공백 문자를 출력하면 배경색만 보이므로 칸이 색으로 채워집니다.
* **실행 결과:**
```
████    ████    ████    ████            ← 흰색(█)과 회색(공백) 칸이 번갈아 나타남
████    ████    ████    ████
    ████    ████    ████    ████
    ████    ████    ████    ████
...  (총 8행)
```




3. 색이 바뀌는 체스판 (Chess Board with Alternating Colors)
* This exercise extends Exercise 2. Every 500 milliseconds, change the color of the colored squares and redisplay the board. Continue until you have shown the board 16 times, using all possible 4-bit background colors. (The white squares remain white throughout.)
* **해석:** 연습 문제 2를 확장합니다. 500밀리초마다 색이 있는 칸의 색을 바꾸고 체스판을 다시 그리세요. 가능한 모든 4비트 배경색을 사용하여 체스판을 16번 표시할 때까지 계속하세요. (흰색 칸은 계속 흰색으로 유지합니다.)
* Answer:
```assembly
INCLUDE Irvine32.inc

SQ_W = 4
SQ_H = 2

DrawBoard  PROTO, sqColor:DWORD
DrawSquare PROTO, row:DWORD, col:DWORD, bgColor:DWORD

.code
main PROC
    call Clrscr
    mov ecx, 16                        ; 16번 반복
    mov ebx, 0                         ; 배경색 0 ~ 15

L1:
    INVOKE DrawBoard, ebx              ; 현재 색으로 체스판 그리기
    mov eax, 500
    call Delay                         ; 500ms 대기
    inc ebx                            ; 다음 색
    loop L1

    mov eax, lightGray + (black * 16)  ; 기본 색으로 복원
    call SetTextColor
    mov dh, 8 * SQ_H + 1
    mov dl, 0
    call Gotoxy
    exit
main ENDP

; DrawBoard, DrawSquare 는 연습 문제 2와 동일
DrawBoard PROC USES eax esi edi,
    sqColor:DWORD

    mov esi, 0
rowLoop:
    mov edi, 0
colLoop:
    mov eax, esi
    add eax, edi
    test eax, 1
    jz  whiteSq
    INVOKE DrawSquare, esi, edi, sqColor
    jmp nextCol
whiteSq:
    INVOKE DrawSquare, esi, edi, white
nextCol:
    inc edi
    cmp edi, 8
    jb  colLoop
    inc esi
    cmp esi, 8
    jb  rowLoop
    ret
DrawBoard ENDP

DrawSquare PROC USES eax ebx ecx edx,
    row:DWORD,
    col:DWORD,
    bgColor:DWORD

    mov eax, bgColor
    shl eax, 4
    call SetTextColor

    mov ebx, 0
lineLoop:
    mov eax, row
    imul eax, SQ_H
    add eax, ebx
    mov dh, al
    mov eax, col
    imul eax, SQ_W
    mov dl, al
    call Gotoxy

    mov ecx, SQ_W
    mov al, ' '
charLoop:
    call WriteChar
    loop charLoop

    inc ebx
    cmp ebx, SQ_H
    jb  lineLoop
    ret
DrawSquare ENDP
END main

```


* **설명:** 4비트 배경색은 0(black) ~ 15(white)의 16가지입니다. EBX를 0부터 15까지 증가시키며 `DrawBoard`에 색을 전달하고, Irvine32의 `Delay`(EAX = 밀리초)로 500ms씩 기다립니다. `DrawBoard`와 `DrawSquare`는 USES로 레지스터를 보존하므로 루프의 ECX, EBX가 유지됩니다. 마지막 색(15)은 white이므로 마지막 화면은 전체가 흰색으로 보입니다.
* **실행 결과:** 같은 위치에 체스판이 다시 그려지면서 색이 있는 칸이 0.5초마다 black → blue → green → cyan → red → magenta → brown → lightGray → gray → lightBlue → ... → white 순서로 바뀝니다.




4. FindThrees 프로시저 (FindThrees Procedure)
* Create a procedure named FindThrees that returns 1 if an array has three consecutive values of 3 somewhere in the array. Otherwise, return 0. The procedure's input parameter list contains a pointer to the array and the array's size. Use the PROC directive with a parameter list when declaring the procedure. Preserve all registers (except EAX) that are modified by the procedure. Write a test program that calls FindThrees several times with different arrays.
* **해석:** 배열 어딘가에 3이 세 번 연속으로 나오면 1을, 그렇지 않으면 0을 반환하는 FindThrees 프로시저를 만드세요. 입력 파라미터는 배열의 포인터와 배열의 크기입니다. 파라미터 목록이 있는 PROC 지시어를 사용하고, 변경하는 모든 레지스터(EAX 제외)를 보존하세요. 서로 다른 배열로 FindThrees를 여러 번 호출하는 테스트 프로그램을 작성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

FindThrees PROTO,
    pArray:PTR DWORD,
    arrCount:DWORD

.data
test1 DWORD 1, 3, 3, 3, 5              ; 1 (중간에 연속)
test2 DWORD 3, 3, 1, 3, 3              ; 0 (두 번씩만 연속)
test3 DWORD 4, 5, 3, 3, 3              ; 1 (끝에 연속)
test4 DWORD 3, 3                       ; 0 (원소 부족)

.code
main PROC
    INVOKE FindThrees, ADDR test1, LENGTHOF test1
    call WriteDec
    call Crlf

    INVOKE FindThrees, ADDR test2, LENGTHOF test2
    call WriteDec
    call Crlf

    INVOKE FindThrees, ADDR test3, LENGTHOF test3
    call WriteDec
    call Crlf

    INVOKE FindThrees, ADDR test4, LENGTHOF test4
    call WriteDec
    call Crlf

    exit
main ENDP

;-----------------------------------------------------
; FindThrees
;
; Checks whether the array contains three consecutive 3s.
; Receives: pArray   = pointer to the array
;           arrCount = number of elements
; Returns:  EAX = 1 if found, otherwise 0
;-----------------------------------------------------
FindThrees PROC USES ecx edx esi,
    pArray:PTR DWORD,
    arrCount:DWORD

    mov esi, pArray
    mov ecx, arrCount
    mov edx, 0                         ; 연속된 3의 개수
    mov eax, 0                         ; 기본 반환값 = 0
    jecxz done

L1:
    cmp DWORD PTR [esi], 3
    jne reset
    inc edx                            ; 3이면 연속 개수 증가
    cmp edx, 3
    je  found                          ; 3개 연속이면 찾음
    jmp next
reset:
    mov edx, 0                         ; 3이 아니면 다시 0부터
next:
    add esi, TYPE DWORD
    loop L1
    jmp done

found:
    mov eax, 1
done:
    ret
FindThrees ENDP
END main

```


* **설명:** EDX에 "지금까지 연속된 3의 개수"를 세다가 3이 아닌 값을 만나면 0으로 초기화합니다. 개수가 3이 되는 순간 1을 반환합니다.
* **실행 결과:**
```
1
0
1
0
```




5. DifferentInputs 프로시저 (DifferentInputs Procedure)
* Write a procedure named DifferentInputs that returns EAX = 1 if the values of its three input parameters are all different; otherwise, return with EAX = 0. Use the PROC directive with a parameter list when declaring the procedure. Create a PROTO declaration for your procedure, and call it five times from a test program that passes different inputs.
* **해석:** 세 입력 파라미터의 값이 모두 다르면 EAX = 1을, 그렇지 않으면 EAX = 0을 반환하는 DifferentInputs 프로시저를 작성하세요. 파라미터 목록이 있는 PROC 지시어를 사용하고, PROTO 선언을 만든 뒤 테스트 프로그램에서 서로 다른 입력으로 다섯 번 호출하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

DifferentInputs PROTO,
    val1:DWORD, val2:DWORD, val3:DWORD

.code
main PROC
    INVOKE DifferentInputs, 1, 2, 3    ; 1
    call WriteDec
    call Crlf

    INVOKE DifferentInputs, 1, 1, 2    ; 0 (val1 = val2)
    call WriteDec
    call Crlf

    INVOKE DifferentInputs, 5, 6, 5    ; 0 (val1 = val3)
    call WriteDec
    call Crlf

    INVOKE DifferentInputs, 7, 8, 8    ; 0 (val2 = val3)
    call WriteDec
    call Crlf

    INVOKE DifferentInputs, -1, 0, 1   ; 1
    call WriteDec
    call Crlf

    exit
main ENDP

;-----------------------------------------------------
; DifferentInputs
;
; Checks whether three values are all different.
; Receives: val1, val2, val3
; Returns:  EAX = 1 if all different, otherwise 0
;-----------------------------------------------------
DifferentInputs PROC,
    val1:DWORD, val2:DWORD, val3:DWORD

    mov eax, val1
    cmp eax, val2
    je  same                           ; val1 = val2
    cmp eax, val3
    je  same                           ; val1 = val3
    mov eax, val2
    cmp eax, val3
    je  same                           ; val2 = val3

    mov eax, 1                         ; 모두 다름
    jmp done
same:
    mov eax, 0
done:
    ret
DifferentInputs ENDP
END main

```


* **설명:** 세 값 중 같은 쌍은 (val1, val2), (val1, val3), (val2, val3) 세 가지뿐이므로 세 번 비교하면 됩니다. EAX 외의 레지스터는 사용하지 않으므로 USES가 필요 없습니다.
* **실행 결과:**
```
1
0
0
0
1
```




6. 정수 교환 (Exchanging Integers)
* Create an array of randomly ordered integers. Using the Swap procedure from Section 8.4.6 as a tool, write a loop that exchanges each consecutive pair of integers in the array.
* **해석:** 무작위 순서의 정수 배열을 만드세요. 8.4.6절의 Swap 프로시저를 도구로 사용하여 배열의 연속된 정수 쌍을 각각 교환하는 루프를 작성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

Swap         PROTO, pValX:PTR DWORD, pValY:PTR DWORD
FillRandom   PROTO, pArray:PTR DWORD, arrCount:DWORD
ShowArray    PROTO, pArray:PTR DWORD, arrCount:DWORD

ARRAY_SIZE = 10                        ; 짝수 개

.data
array DWORD ARRAY_SIZE DUP(?)

.code
main PROC
    call Randomize                     ; 난수 시드 초기화
    INVOKE FillRandom, ADDR array, ARRAY_SIZE
    INVOKE ShowArray,  ADDR array, ARRAY_SIZE   ; 교환 전

    ; 연속된 쌍 (0,1), (2,3), (4,5) ... 교환
    mov esi, OFFSET array
    mov ecx, ARRAY_SIZE / 2            ; 쌍의 개수
L1:
    lea edi, [esi + TYPE DWORD]        ; 쌍의 두 번째 원소 주소
    INVOKE Swap, esi, edi
    add esi, 2 * TYPE DWORD            ; 다음 쌍
    loop L1

    INVOKE ShowArray,  ADDR array, ARRAY_SIZE   ; 교환 후
    exit
main ENDP

;-----------------------------------------------------
; FillRandom
; Fills an array with random integers (0 ~ 99).
;-----------------------------------------------------
FillRandom PROC USES eax ecx esi,
    pArray:PTR DWORD,
    arrCount:DWORD

    mov esi, pArray
    mov ecx, arrCount
L1:
    mov eax, 100
    call RandomRange                   ; EAX = 0 ~ 99
    mov [esi], eax
    add esi, TYPE DWORD
    loop L1
    ret
FillRandom ENDP

;-----------------------------------------------------
; ShowArray
; Displays an array of unsigned integers on one line.
;-----------------------------------------------------
ShowArray PROC USES eax ecx esi,
    pArray:PTR DWORD,
    arrCount:DWORD

    mov esi, pArray
    mov ecx, arrCount
L1:
    mov eax, [esi]
    call WriteDec
    mov al, ' '
    call WriteChar
    add esi, TYPE DWORD
    loop L1
    call Crlf
    ret
ShowArray ENDP

;-----------------------------------------------------
; Swap (Section 8.4.6)
; Exchange the values of two 32-bit integers
;-----------------------------------------------------
Swap PROC USES eax esi edi,
    pValX:PTR DWORD,                   ; pointer to first integer
    pValY:PTR DWORD                    ; pointer to second integer

    mov esi, pValX                     ; get pointers
    mov edi, pValY
    mov eax, [esi]                     ; get first integer
    xchg eax, [edi]                    ; exchange with second
    mov [esi], eax                     ; replace first integer
    ret                                ; PROC generates RET 8 here
Swap ENDP
END main

```


* **설명:** ADDR은 어셈블 시점 상수만 받을 수 있어 `ADDR [esi+4]` 같은 표현은 쓸 수 없습니다. 그래서 `LEA`로 두 번째 원소의 주소를 EDI에 구한 뒤 레지스터를 그대로 INVOKE의 인자로 전달합니다. Swap은 USES로 EAX, ESI, EDI를 보존하므로 루프의 ESI, ECX는 유지됩니다.
* **실행 결과:** (난수이므로 실행할 때마다 다름)
```
42 7 93 15 60 28 3 81 55 19
7 42 15 93 28 60 81 3 19 55
```




7. 최대공약수 (Greatest Common Divisor)
* Write a recursive implementation of Euclid's algorithm for finding the greatest common divisor (GCD) of two integers. Descriptions of this algorithm are available in algebra books and on the Web. Write a test program that calls your GCD procedure five times, using the following pairs of integers: (5,20), (24,18), (11,7), (432,226), (26,13). After each procedure call, display the GCD.
* **해석:** 두 정수의 최대공약수(GCD)를 구하는 유클리드 알고리즘을 재귀로 구현하세요. 다음 정수 쌍 (5,20), (24,18), (11,7), (432,226), (26,13)으로 GCD 프로시저를 다섯 번 호출하고, 매번 GCD를 출력하는 테스트 프로그램을 작성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

GCD PROTO, valA:DWORD, valB:DWORD

.data
pairs DWORD 5,20, 24,18, 11,7, 432,226, 26,13
NUM_PAIRS = ($ - pairs) / (2 * TYPE DWORD)
str1  BYTE "GCD(",0
str2  BYTE ", ",0
str3  BYTE ") = ",0

.code
main PROC
    mov esi, OFFSET pairs
    mov ecx, NUM_PAIRS

L1:
    mov edx, OFFSET str1               ; "GCD("
    call WriteString
    mov eax, [esi]
    call WriteDec                      ; a
    mov edx, OFFSET str2               ; ", "
    call WriteString
    mov eax, [esi + 4]
    call WriteDec                      ; b
    mov edx, OFFSET str3               ; ") = "
    call WriteString

    INVOKE GCD, DWORD PTR [esi], DWORD PTR [esi + 4]
    call WriteDec                      ; 결과 출력
    call Crlf

    add esi, 2 * TYPE DWORD            ; 다음 쌍
    loop L1
    exit
main ENDP

;-----------------------------------------------------
; GCD
;
; Recursive Euclid's algorithm.
;   GCD(a, 0) = a
;   GCD(a, b) = GCD(b, a mod b)
; Receives: valA, valB = unsigned integers
; Returns:  EAX = greatest common divisor
;-----------------------------------------------------
GCD PROC USES ebx edx,
    valA:DWORD,
    valB:DWORD

    mov eax, valA
    mov ebx, valB
    cmp ebx, 0                         ; b = 0 이면
    je  done                           ; GCD = a (EAX)

    mov edx, 0
    div ebx                            ; EDX = a mod b
    INVOKE GCD, ebx, edx               ; GCD(b, a mod b)

done:
    ret
GCD ENDP
END main

```


* **설명:** 종료 조건은 `b = 0`이며 이때 a가 최대공약수입니다. 그렇지 않으면 `DIV`로 `a mod b`를 구해 `GCD(b, a mod b)`를 재귀 호출합니다. 결과는 가장 안쪽 호출에서 EAX에 담겨 그대로 위로 반환되고, 각 단계는 `USES ebx edx`로 자신의 레지스터를 복원합니다. (5, 20)처럼 a < b인 경우 `5 mod 20 = 5`이므로 첫 재귀에서 `GCD(20, 5)`로 자연스럽게 순서가 바뀝니다.

| 호출 | a mod b 과정 | 결과 |
| --- | --- | --- |
| GCD(5, 20) | (20, 5) → (5, 0) | 5 |
| GCD(24, 18) | (18, 6) → (6, 0) | 6 |
| GCD(11, 7) | (7, 4) → (4, 3) → (3, 1) → (1, 0) | 1 |
| GCD(432, 226) | (226, 206) → (206, 20) → (20, 6) → (6, 2) → (2, 0) | 2 |
| GCD(26, 13) | (13, 0) | 13 |

* **실행 결과:**
```
GCD(5, 20) = 5
GCD(24, 18) = 6
GCD(11, 7) = 1
GCD(432, 226) = 2
GCD(26, 13) = 13
```




8. 일치하는 원소 개수 세기 (Counting Matching Elements)
* Write a procedure named CountMatches that receives points to two arrays of signed doublewords, and a third parameter that indicates the length of the two arrays. For each element xᵢ in the first array, if the corresponding yᵢ in the second array is equal, increment a count. At the end, return a count of the number of matching array elements in EAX. Write a test program that calls your procedure and passes pointers to two different pairs of arrays. Use the INVOKE statement to call your procedure and pass stack parameters. Create a PROTO declaration for CountMatches. Save and restore any registers (other than EAX) changed by your procedure.
* **해석:** 부호 있는 doubleword 배열 두 개의 포인터와, 두 배열의 길이를 나타내는 세 번째 파라미터를 받는 CountMatches 프로시저를 작성하세요. 첫 번째 배열의 각 원소 xᵢ에 대해, 두 번째 배열의 대응 원소 yᵢ와 같으면 개수를 증가시킵니다. 마지막에 일치하는 원소의 개수를 EAX로 반환하세요. 서로 다른 두 쌍의 배열 포인터를 전달하는 테스트 프로그램을 작성하고, INVOKE 문으로 스택 파라미터를 전달하세요. CountMatches의 PROTO 선언을 만들고, 프로시저가 변경하는 레지스터(EAX 제외)는 저장 후 복원하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

CountMatches PROTO,
    pArr1:PTR SDWORD,
    pArr2:PTR SDWORD,
    arrCount:DWORD

.data
x1 SDWORD  1,  2,  3,  4,  5,  6
y1 SDWORD  1,  0,  3,  7,  5, -6       ; 일치: 1, 3, 5 → 3개

x2 SDWORD -10,  20, -30, 40, 0
y2 SDWORD -10, -20, -30, 40, 0         ; 일치: -10, -30, 40, 0 → 4개

.code
main PROC
    INVOKE CountMatches, ADDR x1, ADDR y1, LENGTHOF x1
    call WriteDec
    call Crlf

    INVOKE CountMatches, ADDR x2, ADDR y2, LENGTHOF x2
    call WriteDec
    call Crlf

    exit
main ENDP

;-----------------------------------------------------
; CountMatches
;
; Counts the elements where x[i] = y[i].
; Receives: pArr1, pArr2 = pointers to the arrays
;           arrCount     = length of the arrays
; Returns:  EAX = number of matching elements
;-----------------------------------------------------
CountMatches PROC USES ebx ecx esi edi,
    pArr1:PTR SDWORD,
    pArr2:PTR SDWORD,
    arrCount:DWORD

    mov esi, pArr1
    mov edi, pArr2
    mov ecx, arrCount
    mov eax, 0                         ; count = 0
    jecxz done

L1:
    mov ebx, [esi]
    cmp ebx, [edi]                     ; x[i] = y[i]?
    jne next
    inc eax                            ; 일치하면 count++
next:
    add esi, TYPE SDWORD
    add edi, TYPE SDWORD
    loop L1

done:
    ret
CountMatches ENDP
END main

```


* **설명:** 메모리 대 메모리 비교는 할 수 없으므로 x[i]를 EBX로 옮긴 뒤 y[i]와 비교합니다. ESI와 EDI를 같은 크기(4바이트)만큼 함께 증가시켜 같은 인덱스의 원소를 비교합니다.
* **실행 결과:**
```
3
4
```




9. 거의 일치하는 원소 개수 세기 (Counting Nearly Matching Elements)
* Write a procedure named CountNearMatches that receives pointers to two arrays of signed doublewords, a parameter that indicates the length of the two arrays, and a parameter that indicates the maximum allowed difference (called diff) between any two matching elements. For each element xᵢ in the first array, if the difference between it and the corresponding yᵢ in the second array is less than or equal to diff, increment a count. At the end, return a count of the number of nearly matching array elements in EAX. Write a test program that calls CountNearMatches and passes pointers to two different pairs of arrays. Use the INVOKE statement to call your procedure and pass stack parameters. Create a PROTO declaration for CountMatches. Save and restore any registers (other than EAX) changed by your procedure.
* **해석:** 부호 있는 doubleword 배열 두 개의 포인터, 두 배열의 길이, 그리고 일치로 인정할 최대 차이(diff)를 파라미터로 받는 CountNearMatches 프로시저를 작성하세요. 첫 번째 배열의 각 원소 xᵢ와 두 번째 배열의 대응 원소 yᵢ의 차이가 diff 이하이면 개수를 증가시킵니다. 마지막에 거의 일치하는 원소의 개수를 EAX로 반환하세요. 서로 다른 두 쌍의 배열 포인터를 전달하는 테스트 프로그램을 작성하고, INVOKE 문으로 스택 파라미터를 전달하세요. PROTO 선언을 만들고 (교재의 "CountMatches"는 CountNearMatches의 오타), 변경하는 레지스터(EAX 제외)는 저장 후 복원하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

CountNearMatches PROTO,
    pArr1:PTR SDWORD,
    pArr2:PTR SDWORD,
    arrCount:DWORD,
    diff:DWORD

.data
x1 SDWORD 10, 20, 30, 40, 50
y1 SDWORD 12, 25, 29, 40, 44           ; 차이: 2, 5, 1, 0, 6

x2 SDWORD -5, 100, -20,  7
y2 SDWORD  5,  95, -25, -7             ; 차이: 10, 5, 5, 14

.code
main PROC
    INVOKE CountNearMatches, ADDR x1, ADDR y1, LENGTHOF x1, 2
    call WriteDec                      ; 3 (2, 1, 0)
    call Crlf

    INVOKE CountNearMatches, ADDR x2, ADDR y2, LENGTHOF x2, 5
    call WriteDec                      ; 2 (5, 5)
    call Crlf

    exit
main ENDP

;-----------------------------------------------------
; CountNearMatches
;
; Counts the elements where |x[i] - y[i]| <= diff.
; Receives: pArr1, pArr2 = pointers to the arrays
;           arrCount     = length of the arrays
;           diff         = maximum allowed difference
; Returns:  EAX = number of nearly matching elements
;-----------------------------------------------------
CountNearMatches PROC USES ebx ecx esi edi,
    pArr1:PTR SDWORD,
    pArr2:PTR SDWORD,
    arrCount:DWORD,
    diff:DWORD

    mov esi, pArr1
    mov edi, pArr2
    mov ecx, arrCount
    mov eax, 0                         ; count = 0
    jecxz done

L1:
    mov ebx, [esi]
    sub ebx, [edi]                     ; EBX = x[i] - y[i]
    jns positive                       ; 0 이상이면 그대로
    neg ebx                            ; 음수면 부호 반전 → 절댓값
positive:
    cmp ebx, diff
    jg  next                           ; |x - y| > diff 이면 건너뜀
    inc eax                            ; count++
next:
    add esi, TYPE SDWORD
    add edi, TYPE SDWORD
    loop L1

done:
    ret
CountNearMatches ENDP
END main

```


* **설명:** `SUB`로 차이를 구한 뒤 결과가 음수(SF = 1)이면 `NEG`로 절댓값을 만들고, diff와 부호 있는 비교(`JG`)를 합니다. (두 값의 차이가 32비트 부호 있는 범위를 넘을 만큼 크면 오버플로가 발생하므로, 테스트 값은 그 범위 안에서 사용합니다.)
* **실행 결과:**
```
3
2
```




10. 프로시저 파라미터 출력 (Show Procedure Parameters)
* Write a procedure named ShowParams that displays the address and hexadecimal value of the 32-bit parameters on the runtime stack of the procedure that called it. The parameters are to be displayed in order from the lowest address to the highest. Input to the procedure will be a single integer that indicates the number of parameters to display. For example, suppose the following statement in main calls MySample, passing three arguments:
```assembly
INVOKE MySample, 1234h, 5000h, 6543h

```
* Next, inside MySample, you should be able to call ShowParams, passing the number of parameters you want to display:
```assembly
MySample PROC first:DWORD, second:DWORD, third:DWORD
paramCount = 3
call ShowParams, paramCount

```
* ShowParams should display output in the following format:
```
Stack parameters:
---------------------------
Address 0012FF80 = 00001234
Address 0012FF84 = 00005000
Address 0012FF88 = 00006543
```
* **해석:** 자신을 호출한 프로시저의 런타임 스택에 있는 32비트 파라미터들의 주소와 16진수 값을 출력하는 ShowParams 프로시저를 작성하세요. 파라미터는 낮은 주소부터 높은 주소 순서로 출력합니다. 입력은 출력할 파라미터 개수를 나타내는 정수 하나입니다. 예를 들어 main에서 위처럼 세 인자로 MySample을 호출하면, MySample 안에서 출력할 파라미터 개수를 전달하여 ShowParams를 호출할 수 있어야 합니다. ShowParams는 위와 같은 형식으로 출력해야 합니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

MySample   PROTO, first:DWORD, second:DWORD, third:DWORD
ShowParams PROTO, paramCount:DWORD

.code
main PROC
    INVOKE MySample, 1234h, 5000h, 6543h
    exit
main ENDP

;-----------------------------------------------------
; MySample
; Calls ShowParams to display its own stack parameters.
;-----------------------------------------------------
MySample PROC,
    first:DWORD,
    second:DWORD,
    third:DWORD

    paramCount = 3
    INVOKE ShowParams, paramCount
    ret
MySample ENDP

;-----------------------------------------------------
; ShowParams
;
; Displays the addresses and values of the caller's
; 32-bit stack parameters, from lowest to highest address.
; Receives: paramCount = number of parameters to display
; Returns:  nothing
;-----------------------------------------------------
ShowParams PROC USES eax ebx ecx edx esi,
    paramCount:DWORD

.data
heading  BYTE "Stack parameters:",0dh,0ah
         BYTE "---------------------------",0dh,0ah,0
addrStr  BYTE "Address ",0
equalStr BYTE " = ",0
.code
    mov edx, OFFSET heading
    call WriteString

    mov ebx, [ebp]                     ; 호출자(MySample)의 EBP
    lea esi, [ebx + 8]                 ; 호출자의 첫 번째 파라미터 주소
    mov ecx, paramCount
    jecxz done

L1:
    mov edx, OFFSET addrStr            ; "Address "
    call WriteString
    mov eax, esi
    call WriteHex                      ; 파라미터 주소
    mov edx, OFFSET equalStr           ; " = "
    call WriteString
    mov eax, [esi]
    call WriteHex                      ; 파라미터 값
    call Crlf
    add esi, TYPE DWORD                ; 다음(더 높은) 주소
    loop L1

done:
    ret
ShowParams ENDP
END main

```


* **설명:** 파라미터가 있는 PROC은 진입 시 `push ebp / mov ebp, esp`를 생성하므로, ShowParams 안에서 `[ebp]`에는 **호출자(MySample)의 EBP**가 저장되어 있습니다. 호출자의 EBP를 기준으로 `[EBP + 4]`는 MySample의 복귀 주소, `[EBP + 8]`부터가 MySample의 파라미터입니다. 마지막 인자부터 push하므로 첫 번째 파라미터(1234h)가 가장 낮은 주소에 있어, 주소를 4씩 증가시키면 낮은 주소부터 순서대로 출력됩니다. (교재의 `call ShowParams, paramCount`는 INVOKE 형식을 의미하므로 `INVOKE ShowParams, paramCount`로 작성했습니다.)

```
             ┌────────────────┐
             │     6543h      │  [MySample EBP + 16]
             ├────────────────┤
             │     5000h      │  [MySample EBP + 12]
             ├────────────────┤
             │     1234h      │  [MySample EBP + 8]   ← ESI 시작 위치
             ├────────────────┤
             │ return address │  (main으로 복귀)
             ├────────────────┤
MySample EBP │  main's EBP    │
             ├────────────────┤
             │       3        │  ShowParams의 paramCount
             ├────────────────┤
             │ return address │  (MySample로 복귀)
             ├────────────────┤
             │ MySample's EBP │  ← ShowParams의 EBP  ([ebp] = MySample EBP)
             └────────────────┘
```

* **실행 결과:** (주소는 실행 환경에 따라 다름)
```
Stack parameters:
---------------------------
Address 0012FF80 = 00001234
Address 0012FF84 = 00005000
Address 0012FF88 = 00006543
```
