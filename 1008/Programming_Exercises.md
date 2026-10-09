# Review Question and Exercises

## Programming Exercises

* When you write programs to solve the programming exercises, use multiple procedures when possible. Follow the style and naming conventions used in this book, unless instructed otherwise by your instructor. Use explanatory comments in your programs at the beginning of each procedure and next to nontrivial statements.
* **해석:** 프로그래밍 연습 문제를 풀 때는 가능하면 여러 개의 프로시저를 사용하세요. 강사의 별도 지시가 없다면 이 책의 스타일과 명명 규칙을 따르세요. 각 프로시저의 시작 부분과 간단하지 않은 문장 옆에는 설명 주석을 다세요.




1. 텍스트 색상 그리기 (Draw Text Colors)
* Write a program that displays the same string in four different colors, using a loop. Call the SetTextColor procedure from the book's link library. Any colors may be chosen, but you may find it easiest to change the foreground color.
* **해석:** 루프를 사용하여 같은 문자열을 네 가지 다른 색상으로 출력하는 프로그램을 작성하세요. 책의 링크 라이브러리에 있는 SetTextColor 프로시저를 호출하세요. 색상은 아무것이나 선택해도 되지만, 전경색(글자색)을 바꾸는 것이 가장 쉬울 것입니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
message BYTE "Assembly Language is fun!",0
colors  DWORD yellow, lightGreen, lightCyan, lightRed

.code
main PROC
    mov esi, 0                         ; 색상 배열 인덱스
    mov ecx, LENGTHOF colors           ; 4번 반복

L1:
    mov eax, colors[esi*TYPE colors]   ; 전경색 (배경은 black)
    call SetTextColor
    call ShowMessage
    inc esi
    loop L1

    mov eax, lightGray + (black * 16)  ; 기본 색상으로 복원
    call SetTextColor
    exit
main ENDP

;-----------------------------------------------------
; ShowMessage
;
; Displays the message string followed by a newline.
; Receives: nothing
; Returns:  nothing
;-----------------------------------------------------
ShowMessage PROC USES edx
    mov edx, OFFSET message
    call WriteString
    call Crlf
    ret
ShowMessage ENDP
END main

```




2. 배열 항목 연결 (Linking Array Items)
* Suppose you are given three data items that indicate a starting index in a list, an array of characters, and an array of link index. You are to write a program that traverses the links and locates the characters in their correct sequence. For each character you locate, copy it to a new array. Suppose you used the following sample data, and assumed the arrays use zero-based indexes:
```
start = 1
chars:  H A C E B D F G
links:  0 4 5 6 2 3 7 0
```
* Then the values copied (in order) to the output array would be A,B,C,D,E,F,G,H. Declare the character array as type BYTE, and to make the problem more interesting, declare the links array type DWORD.
* **해석:** 리스트의 시작 인덱스, 문자 배열, 링크 인덱스 배열이라는 세 가지 데이터가 주어진다고 가정하세요. 링크를 따라가며 문자들을 올바른 순서대로 찾아내는 프로그램을 작성해야 합니다. 찾은 각 문자는 새 배열에 복사하세요. 위의 예시 데이터를 사용하고 배열이 0부터 시작하는 인덱스를 쓴다고 가정하면, 출력 배열에 (순서대로) 복사되는 값은 A,B,C,D,E,F,G,H가 됩니다. 문자 배열은 BYTE 타입으로 선언하고, 문제를 더 흥미롭게 만들기 위해 links 배열은 DWORD 타입으로 선언하세요.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
start  DWORD 1
chars  BYTE  'H','A','C','E','B','D','F','G'
links  DWORD 0,4,5,6,2,3,7,0
output BYTE  LENGTHOF chars DUP(0)

.code
main proc
    mov esi, start                     ; ESI = 현재 인덱스 (시작 = 1)
    mov edi, 0                         ; EDI = output 인덱스
    mov ecx, LENGTHOF chars            ; 문자 개수만큼 반복

L1:
    mov al, chars[esi]                 ; 현재 위치의 문자
    mov output[edi], al                ; output에 복사
    mov esi, links[esi*TYPE links]     ; 링크를 따라 다음 인덱스로 이동
    inc edi
    loop L1
    ; output = 'A','B','C','D','E','F','G','H'

    invoke ExitProcess, 0
main endp
end main

```




3. 간단한 덧셈 (1) (Simple Addition (1))
* Write a program that clears the screen, locates the cursor near the middle of the screen, prompts the user for two integers, adds the integers, and displays their sum.
* **해석:** 화면을 지우고, 커서를 화면 중앙 근처에 위치시킨 뒤, 사용자에게 두 정수를 입력받아 더하고 그 합을 출력하는 프로그램을 작성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
prompt1 BYTE "Enter the first integer:  ",0
prompt2 BYTE "Enter the second integer: ",0
msgSum  BYTE "The sum is: ",0

.code
main PROC
    call AddTwoIntegers
    exit
main ENDP

;-----------------------------------------------------
; AddTwoIntegers
;
; Clears the screen, prompts the user for two integers
; near the middle of the screen, and displays their sum.
; Receives: nothing
; Returns:  nothing
;-----------------------------------------------------
AddTwoIntegers PROC USES eax ebx edx
    call Clrscr

    mov dh, 10                         ; 행(row)
    mov dl, 25                         ; 열(column)
    call Gotoxy
    mov edx, OFFSET prompt1
    call WriteString
    call ReadInt                       ; EAX = 첫 번째 정수
    mov ebx, eax

    mov dh, 11
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET prompt2
    call WriteString
    call ReadInt                       ; EAX = 두 번째 정수
    add eax, ebx                       ; EAX = 합계

    mov dh, 13
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgSum
    call WriteString
    call WriteInt                      ; 합계 출력
    call Crlf
    ret
AddTwoIntegers ENDP
END main

```




4. 간단한 덧셈 (2) (Simple Addition (2))
* Use the solution program from the preceding exercise as a starting point. Let this new program repeat the same steps three times, using a loop. Clear the screen after each loop iteration.
* **해석:** 앞 문제의 풀이 프로그램을 출발점으로 사용하세요. 이 새 프로그램은 루프를 사용하여 같은 단계를 세 번 반복해야 합니다. 루프가 한 번 반복될 때마다 화면을 지우세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
prompt1 BYTE "Enter the first integer:  ",0
prompt2 BYTE "Enter the second integer: ",0
msgSum  BYTE "The sum is: ",0

.code
main PROC
    mov ecx, 3                         ; 3번 반복

L1:
    call AddTwoIntegers
    call WaitMsg                       ; 결과를 확인할 수 있도록 대기
    call Clrscr                        ; 반복이 끝날 때마다 화면 지우기
    loop L1

    exit
main ENDP

;-----------------------------------------------------
; AddTwoIntegers
;
; Clears the screen, prompts the user for two integers
; near the middle of the screen, and displays their sum.
; Receives: nothing
; Returns:  nothing
;-----------------------------------------------------
AddTwoIntegers PROC USES eax ebx edx
    call Clrscr

    mov dh, 10                         ; 행(row)
    mov dl, 25                         ; 열(column)
    call Gotoxy
    mov edx, OFFSET prompt1
    call WriteString
    call ReadInt                       ; EAX = 첫 번째 정수
    mov ebx, eax

    mov dh, 11
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET prompt2
    call WriteString
    call ReadInt                       ; EAX = 두 번째 정수
    add eax, ebx                       ; EAX = 합계

    mov dh, 13
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgSum
    call WriteString
    call WriteInt                      ; 합계 출력
    call Crlf
    ret
AddTwoIntegers ENDP
END main

```




5. BetterRandomRange 프로시저 (BetterRandomRange Procedure)
* The RandomRange procedure from the Irvine32 library generates a pseudorandom integer between 0 and N – 1. Your task is to create an improved version that generates an integer between M and N – 1. Let the caller pass M in EBX and N in EAX. If we call the procedure BetterRandomRange, the following code is a sample test:
```assembly
mov ebx,-300        ; lower bound
mov eax,100         ; upper bound
call BetterRandomRange

```
* Write a short test program that calls BetterRandomRange from a loop that repeats 50 times. Display each randomly generated value.
* **해석:** Irvine32 라이브러리의 RandomRange 프로시저는 0부터 N – 1 사이의 의사 난수 정수를 생성합니다. M부터 N – 1 사이의 정수를 생성하는 개선된 버전을 만드세요. 호출자는 M을 EBX로, N을 EAX로 전달합니다. 프로시저 이름을 BetterRandomRange라고 하면 위 코드가 테스트 예시입니다. 50번 반복하는 루프에서 BetterRandomRange를 호출하는 짧은 테스트 프로그램을 작성하고, 생성된 각 난수 값을 출력하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.code
main PROC
    call Randomize                     ; 난수 시드 초기화
    mov ecx, 50                        ; 50번 반복

L1:
    mov ebx, -300                      ; 하한 (M)
    mov eax, 100                       ; 상한 (N)
    call BetterRandomRange
    call WriteInt                      ; 생성된 값 출력
    call Crlf
    loop L1

    exit
main ENDP

;-----------------------------------------------------
; BetterRandomRange
;
; Generates a pseudorandom integer between M and N-1.
; Receives: EBX = M (lower bound), EAX = N (upper bound)
; Returns:  EAX = random integer in the range [M, N-1]
;-----------------------------------------------------
BetterRandomRange PROC
    sub eax, ebx                       ; EAX = N - M (범위의 크기)
    call RandomRange                   ; EAX = 0 ~ (N - M - 1)
    add eax, ebx                       ; EAX = M ~ (N - 1)
    ret
BetterRandomRange ENDP
END main

```




6. 무작위 문자열 (Random Strings)
* Create a procedure that generates a random string of length L, containing all capital letters. When calling the procedure, pass the value of L in EAX, and pass a pointer to an array of byte that will hold the random string. Write a test program that calls your procedure 20 times and displays the strings in the console window.
* **해석:** 모두 대문자로 이루어진 길이 L의 무작위 문자열을 생성하는 프로시저를 만드세요. 프로시저를 호출할 때 L 값은 EAX로 전달하고, 무작위 문자열을 저장할 바이트 배열의 포인터도 함께 전달하세요. 프로시저를 20번 호출하고 콘솔 창에 문자열들을 출력하는 테스트 프로그램을 작성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

STR_LENGTH = 10

.data
buffer BYTE STR_LENGTH + 1 DUP(0)      ; 문자열 + 널 문자

.code
main PROC
    call Randomize                     ; 난수 시드 초기화
    mov ecx, 20                        ; 20번 반복

L1:
    mov eax, STR_LENGTH                ; EAX = 문자열 길이 L
    mov esi, OFFSET buffer             ; ESI = 버퍼 주소
    call RandomString
    mov edx, OFFSET buffer
    call WriteString
    call Crlf
    loop L1

    exit
main ENDP

;-----------------------------------------------------
; RandomString
;
; Generates a random string of capital letters.
; Receives: EAX = length of the string (L)
;           ESI = pointer to the byte array
; Returns:  the array is filled with L random capital
;           letters followed by a null byte
;-----------------------------------------------------
RandomString PROC USES eax ecx esi
    mov ecx, eax                       ; 루프 카운터 = L

L1:
    mov eax, 26                        ; 0 ~ 25 범위의 난수
    call RandomRange
    add al, 'A'                        ; 'A' ~ 'Z'로 변환
    mov [esi], al
    inc esi
    loop L1

    mov BYTE PTR [esi], 0              ; 문자열 끝에 널 문자 추가
    ret
RandomString ENDP
END main

```




7. 무작위 화면 위치 (Random Screen Locations)
* Write a program that displays a single character at 100 random screen locations, using a timing delay of 100 milliseconds. Hint: Use the GetMaxXY procedure to determine the current size of the console window.
* **해석:** 100밀리초의 시간 지연을 두면서 하나의 문자를 무작위 화면 위치 100곳에 출력하는 프로그램을 작성하세요. 힌트: GetMaxXY 프로시저를 사용하여 현재 콘솔 창의 크기를 알아내세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
maxRows BYTE ?
maxCols BYTE ?

.code
main PROC
    call Randomize
    call GetMaxXY                      ; AX = 행 수, DX = 열 수
    mov maxRows, al
    mov maxCols, dl
    call Clrscr

    mov ecx, 100                       ; 100번 반복
L1:
    call ShowRandomChar
    mov eax, 100                       ; 100밀리초 지연
    call Delay
    loop L1

    mov dh, 0                          ; 커서를 왼쪽 위로 이동
    mov dl, 0
    call Gotoxy
    exit
main ENDP

;-----------------------------------------------------
; ShowRandomChar
;
; Displays a single character at a random screen location.
; Receives: maxRows, maxCols = console window size
; Returns:  nothing
;-----------------------------------------------------
ShowRandomChar PROC USES eax edx
    movzx eax, maxRows
    call RandomRange                   ; 0 ~ (행 수 - 1)
    mov dh, al                         ; DH = 행
    movzx eax, maxCols
    call RandomRange                   ; 0 ~ (열 수 - 1)
    mov dl, al                         ; DL = 열
    call Gotoxy

    mov al, '*'
    call WriteChar
    ret
ShowRandomChar ENDP
END main

```




8. 색상 행렬 (Color Matrix)
* Write a program that displays a single character in all possible combinations of foreground and background colors (16 × 16 = 256). The colors are numbered from 0 to 15, so you can use a nested loop to generate all possible combinations.
* **해석:** 전경색과 배경색의 가능한 모든 조합(16 × 16 = 256)으로 하나의 문자를 출력하는 프로그램을 작성하세요. 색상은 0부터 15까지 번호가 매겨져 있으므로, 중첩 루프를 사용하여 가능한 모든 조합을 생성할 수 있습니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
color DWORD 0                          ; 색상 속성 = 배경색 * 16 + 전경색

.code
main PROC
    mov ecx, 16                        ; 바깥 루프: 배경색 16가지

L1:
    push ecx                           ; 바깥 루프 카운터 저장
    mov ecx, 16                        ; 안쪽 루프: 전경색 16가지

L2:
    call ShowColorChar
    inc color                          ; 다음 전경색 (16번 증가하면 다음 배경색)
    loop L2

    call Crlf
    pop ecx                            ; 바깥 루프 카운터 복원
    loop L1

    mov eax, lightGray + (black * 16)  ; 기본 색상으로 복원
    call SetTextColor
    exit
main ENDP

;-----------------------------------------------------
; ShowColorChar
;
; Displays a single character using the current color.
; Receives: color = text color attribute
; Returns:  nothing
;-----------------------------------------------------
ShowColorChar PROC USES eax
    mov eax, color
    call SetTextColor
    mov al, 'X'
    call WriteChar
    ret
ShowColorChar ENDP
END main

```


* **설명:** 색상 속성 값은 `배경색 * 16 + 전경색`이므로, 0부터 255까지 1씩 증가시키면 안쪽 루프 16번마다 배경색이 하나씩 바뀌어 모든 조합이 출력됩니다.




9. 재귀 프로시저 (Recursive Procedure)
* Direct recursion is the term we use when a procedure calls itself. Of course, you never want to let a procedure keep calling itself forever, because the runtime stack would fill up. Instead, you must limit the recursion in some way. Write a program that calls a recursive procedure. Inside this procedure, add 1 to a counter so you can verify the number of times it executes. Run your program with a debugger, and at the end of the program, check the counter's value. Put a number in ECX that specifies the number of times you want to allow the recursion to continue. Using only the LOOP instruction (and no other conditional statements from later chapters), find a way for the recursive procedure to call itself a fixed number of times.
* **해석:** 직접 재귀(direct recursion)는 프로시저가 자기 자신을 호출하는 것을 말합니다. 물론 런타임 스택이 가득 차게 되므로 프로시저가 자신을 영원히 호출하게 두어서는 안 되며, 어떤 방식으로든 재귀를 제한해야 합니다. 재귀 프로시저를 호출하는 프로그램을 작성하세요. 이 프로시저 안에서 카운터에 1을 더해 실행 횟수를 확인할 수 있도록 하세요. 디버거로 프로그램을 실행하고 프로그램이 끝날 때 카운터 값을 확인하세요. ECX에 재귀를 계속할 횟수를 넣으세요. LOOP 명령어만 사용하여(이후 장에서 배우는 다른 조건문 없이) 재귀 프로시저가 정해진 횟수만큼 자신을 호출하도록 하는 방법을 찾으세요.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
counter DWORD 0

.code
main proc
    mov ecx, 10                        ; 재귀 허용 횟수
    call Recurse
    ; counter = 10

    invoke ExitProcess, 0
main endp

;-----------------------------------------------------
; Recurse
;
; Calls itself recursively, adding 1 to counter each time.
; Receives: ECX = number of times to execute
; Returns:  counter = number of times executed
;-----------------------------------------------------
Recurse proc
    inc counter                        ; 실행 횟수 증가
    loop L1                            ; ECX 감소, 0이 아니면 L1로 이동
    ret                                ; ECX = 0이면 재귀 종료

L1:
    call Recurse                       ; 자기 자신을 호출
    ret
Recurse endp
end main

```


* **설명:** LOOP는 ECX를 1 감소시킨 뒤 0이 아닐 때만 점프하므로, ECX가 0이 될 때까지만 재귀 호출이 일어납니다. 따라서 Recurse는 처음 ECX 값만큼 실행됩니다.




10. 피보나치 생성기 (Fibonacci Generator)
* Write a procedure that produces N values in the Fibonacci number series and stores them in an array of doubleword. Input parameters should be a pointer to an array of doubleword, a counter of the number of values to generate. Write a test program that calls your procedure, passing N = 47. The first value in the array will be 1, and the last value will be 2,971,215,073. Use the Visual Studio debugger to open and inspect the array contents.
* **해석:** 피보나치 수열의 값 N개를 생성하여 doubleword 배열에 저장하는 프로시저를 작성하세요. 입력 매개변수는 doubleword 배열의 포인터와 생성할 값의 개수를 나타내는 카운터입니다. N = 47을 전달하여 프로시저를 호출하는 테스트 프로그램을 작성하세요. 배열의 첫 번째 값은 1이고 마지막 값은 2,971,215,073이 됩니다. Visual Studio 디버거로 배열 내용을 열어 확인하세요.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

FIB_COUNT = 47

.data
fibArray DWORD FIB_COUNT DUP(?)

.code
main proc
    mov esi, OFFSET fibArray           ; ESI = 배열 주소
    mov ecx, FIB_COUNT                 ; ECX = 생성할 개수 (N = 47)
    call FibGenerator
    ; fibArray = 1, 1, 2, 3, 5, 8, ..., 2971215073 (B11924E1h)

    invoke ExitProcess, 0
main endp

;-----------------------------------------------------
; FibGenerator
;
; Generates N values of the Fibonacci series.
; Receives: ESI = pointer to an array of doublewords
;           ECX = number of values to generate (N)
; Returns:  the array is filled with Fibonacci numbers
;-----------------------------------------------------
FibGenerator proc USES eax ebx ecx edx esi
    mov eax, 1                         ; EAX = Fib(n)
    mov ebx, 0                         ; EBX = Fib(n-1)

L1:
    mov [esi], eax                     ; 현재 값 저장
    mov edx, eax                       ; EDX = 현재 값 임시 저장
    add eax, ebx                       ; EAX = Fib(n) + Fib(n-1) = Fib(n+1)
    mov ebx, edx                       ; EBX = 이전 Fib(n)
    add esi, TYPE DWORD                ; 다음 요소로 이동
    loop L1
    ret
FibGenerator endp
end main

```




11. K의 배수 찾기 (Finding Multiples of K)
* In a byte array of size N, write a procedure that finds all multiples of K that are less than N. Initialize the array to all zeros at the beginning of the program, and then whenever a multiple is found, set the corresponding array element to 1. Your procedure must save and restore any registers it modifies. Call your procedure twice, with K = 2, and again with K = 3. Let N equal to 50. Run your program in the debugger and verify that the array values were set correctly. Note: This procedure can be a useful tool when finding prime integers. An efficient algorithm for finding prime numbers is known as the Sieve of Eratosthenes. You will be able to implement this algorithm when conditional statements are covered in Chapter 6.
* **해석:** 크기가 N인 바이트 배열에서 N보다 작은 K의 배수를 모두 찾는 프로시저를 작성하세요. 프로그램 시작 시 배열을 모두 0으로 초기화하고, 배수를 찾을 때마다 해당 배열 요소를 1로 설정하세요. 프로시저는 자신이 수정하는 모든 레지스터를 저장하고 복원해야 합니다. 프로시저를 K = 2로 한 번, K = 3으로 다시 한 번, 총 두 번 호출하세요. N은 50으로 합니다. 디버거로 프로그램을 실행하여 배열 값이 올바르게 설정되었는지 확인하세요. 참고: 이 프로시저는 소수를 찾을 때 유용한 도구가 될 수 있습니다. 소수를 찾는 효율적인 알고리즘으로 에라토스테네스의 체가 있으며, 6장에서 조건문을 배우면 이 알고리즘을 구현할 수 있습니다.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

N = 50

.data
array BYTE N DUP(?)

.code
main proc
    ; 프로그램 시작 시 배열을 0으로 초기화
    mov esi, 0
    mov ecx, N
L1:
    mov array[esi], 0
    inc esi
    loop L1

    mov esi, OFFSET array              ; ESI = 배열 주소
    mov ebx, 2                         ; K = 2
    mov ecx, (N - 1) / 2               ; N보다 작은 2의 배수 개수 = 24
    call FindMultiples                 ; array[2], array[4], ..., array[48] = 1

    mov ebx, 3                         ; K = 3
    mov ecx, (N - 1) / 3               ; N보다 작은 3의 배수 개수 = 16
    call FindMultiples                 ; array[3], array[6], ..., array[48] = 1

    invoke ExitProcess, 0
main endp

;-----------------------------------------------------
; FindMultiples
;
; Marks all multiples of K that are less than N.
; Receives: ESI = pointer to a byte array of size N
;           EBX = K
;           ECX = number of multiples of K less than N
; Returns:  array[K], array[2K], ... are set to 1
;-----------------------------------------------------
FindMultiples proc USES eax ecx
    mov eax, ebx                       ; 첫 번째 배수 = K

L1:
    mov BYTE PTR [esi + eax], 1        ; 배수 위치를 1로 설정
    add eax, ebx                       ; 다음 배수
    loop L1
    ret
FindMultiples endp
end main

```


* **설명:** 5장까지는 조건 분기와 DIV를 배우지 않았으므로, 반복 횟수 `(N - 1) / K`를 어셈블러 상수식으로 계산하여 ECX로 전달했습니다. 프로시저는 USES로 EAX, ECX를 저장/복원하며, ESI와 EBX는 읽기만 하므로 수정하지 않습니다.
