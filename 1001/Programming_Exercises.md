# Review Question and Exercises

## Programming Exercises

1. 빅 엔디안을 리틀 엔디안으로 변환 (Converting from Big Endian to Little Endian)
* Write a program that uses the variables below and MOV instructions to copy the value from bigEndian to littleEndian, reversing the order of the bytes. The number's 32-bit value is understood to be 12345678 hexadecimal.
* **해석:** 아래 변수들과 MOV 명령어를 사용하여 bigEndian의 값을 littleEndian으로 복사하되, 바이트 순서를 뒤집는 프로그램을 작성하세요. 이 숫자의 32비트 값은 16진수 12345678로 간주합니다.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
bigEndian    BYTE 12h,34h,56h,78h
littleEndian DWORD ?

.code
main proc
    ; bigEndian의 바이트를 역순으로 littleEndian에 복사
    mov al, bigEndian+3
    mov BYTE PTR littleEndian, al      ; 78h
    mov al, bigEndian+2
    mov BYTE PTR littleEndian+1, al    ; 56h
    mov al, bigEndian+1
    mov BYTE PTR littleEndian+2, al    ; 34h
    mov al, bigEndian
    mov BYTE PTR littleEndian+3, al    ; 12h

    mov eax, littleEndian              ; EAX = 12345678h

    invoke ExitProcess, 0
main endp
end main

```




2. 배열 값 쌍 교환 (Exchanging Pairs of Array Values)
* Write a program with a loop and indexed addressing that exchanges every pair of values in an array with an even number of elements. Therefore, item i will exchange with item i+1, and item i+2 will exchange with item i+3, and so on.
* **해석:** 루프와 인덱스 주소 지정 방식을 사용하여 짝수 개의 요소를 가진 배열에서 모든 값의 쌍을 교환하는 프로그램을 작성하세요. 즉, i번째 항목은 i+1번째 항목과, i+2번째 항목은 i+3번째 항목과 교환되는 식입니다.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
array DWORD 1,2,3,4,5,6,7,8

.code
main proc
    mov esi, 0                         ; 인덱스 = 0
    mov ecx, LENGTHOF array / 2        ; 쌍의 개수만큼 반복

L1:
    mov eax, array[esi*TYPE array]           ; EAX = array[i]
    xchg eax, array[esi*TYPE array + 4]      ; EAX <-> array[i+1]
    mov array[esi*TYPE array], eax           ; array[i] = 기존 array[i+1]
    add esi, 2                               ; 다음 쌍으로 이동
    loop L1
    ; 결과: 2,1,4,3,6,5,8,7

    invoke ExitProcess, 0
main endp
end main

```




3. 배열 값 사이의 간격 합계 (Summing the Gaps between Array Values)
* Write a program with a loop and indexed addressing that calculates the sum of all the gaps between successive array elements. The array elements are doublewords, sequenced in nondecreasing order. So, for example, the array {0, 2, 5, 9, 10} has gaps of 2, 3, 4, and 1, whose sum equals 10.
* **해석:** 루프와 인덱스 주소 지정 방식을 사용하여 연속된 배열 요소들 사이의 모든 간격의 합을 계산하는 프로그램을 작성하세요. 배열 요소는 doubleword이며 감소하지 않는 순서(오름차순)로 정렬되어 있습니다. 예를 들어 배열 {0, 2, 5, 9, 10}의 간격은 2, 3, 4, 1이며 그 합은 10입니다.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
array DWORD 0,2,5,9,10

.code
main proc
    mov eax, 0                         ; 간격의 합 = 0
    mov esi, 1                         ; 두 번째 요소부터 시작
    mov ecx, LENGTHOF array - 1        ; 간격의 개수만큼 반복

L1:
    mov edx, array[esi*TYPE array]           ; EDX = array[i]
    sub edx, array[esi*TYPE array - 4]       ; EDX = array[i] - array[i-1]
    add eax, edx                             ; 합계에 간격을 더함
    inc esi
    loop L1
    ; EAX = 10

    invoke ExitProcess, 0
main endp
end main

```




4. Word 배열을 DoubleWord 배열로 복사 (Copying a Word Array to a DoubleWord array)
* Write a program that uses a loop to copy all the elements from an unsigned Word (16-bit) array into an unsigned doubleword (32-bit) array.
* **해석:** 루프를 사용하여 부호 없는 Word(16비트) 배열의 모든 요소를 부호 없는 doubleword(32비트) 배열로 복사하는 프로그램을 작성하세요.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
wordArray  WORD  1000h, 2000h, 3000h, 0FFFFh
dwordArray DWORD LENGTHOF wordArray DUP(0)

.code
main proc
    mov esi, 0                         ; 인덱스 = 0
    mov ecx, LENGTHOF wordArray        ; 요소 개수만큼 반복

L1:
    movzx eax, wordArray[esi*TYPE wordArray]    ; 16비트 값을 0으로 확장
    mov dwordArray[esi*TYPE dwordArray], eax    ; 32비트 배열에 저장
    inc esi
    loop L1

    invoke ExitProcess, 0
main endp
end main

```




5. 피보나치 수 (Fibonacci Numbers)
* Write a program that uses a loop to calculate the first seven values of the Fibonacci number sequence, described by the following formula: Fib(1) = 1, Fib(2) = 1, Fib(n) = Fib(n – 1) + Fib(n – 2).
* **해석:** 루프를 사용하여 다음 공식으로 정의되는 피보나치 수열의 처음 7개 값을 계산하는 프로그램을 작성하세요: Fib(1) = 1, Fib(2) = 1, Fib(n) = Fib(n – 1) + Fib(n – 2).
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
fib DWORD 7 DUP(0)

.code
main proc
    mov fib, 1                         ; Fib(1) = 1
    mov fib+4, 1                       ; Fib(2) = 1
    mov esi, 2                         ; 세 번째 요소부터 계산
    mov ecx, LENGTHOF fib - 2          ; 나머지 5개 계산

L1:
    mov eax, fib[esi*TYPE fib - 4]     ; Fib(n-1)
    add eax, fib[esi*TYPE fib - 8]     ; + Fib(n-2)
    mov fib[esi*TYPE fib], eax         ; Fib(n) 저장
    inc esi
    loop L1
    ; fib = 1, 1, 2, 3, 5, 8, 13

    invoke ExitProcess, 0
main endp
end main

```




6. 배열 뒤집기 (Reverse an Array)
* Use a loop with indirect or indexed addressing to reverse the elements of an integer array in place. Do not copy the elements to any other array. Use the SIZEOF, TYPE, and LENGTHOF operators to make the program as flexible as possible if the array size and type should be changed in the future.
* **해석:** 간접 또는 인덱스 주소 지정 방식을 사용하는 루프로 정수 배열의 요소를 제자리에서(in place) 뒤집으세요. 요소를 다른 배열로 복사하지 마세요. 향후 배열의 크기와 타입이 변경되더라도 프로그램이 최대한 유연하게 동작하도록 SIZEOF, TYPE, LENGTHOF 연산자를 사용하세요.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
array DWORD 1,2,3,4,5,6,7,8,9,10

.code
main proc
    mov esi, OFFSET array                              ; 첫 번째 요소 주소
    mov edi, OFFSET array + SIZEOF array - TYPE array  ; 마지막 요소 주소
    mov ecx, LENGTHOF array / 2                        ; 교환 횟수

L1:
    mov eax, [esi]                     ; 앞쪽 요소
    mov ebx, [edi]                     ; 뒤쪽 요소
    mov [esi], ebx                     ; 서로 교환
    mov [edi], eax
    add esi, TYPE array                ; 앞 포인터는 다음 요소로
    sub edi, TYPE array                ; 뒤 포인터는 이전 요소로
    loop L1
    ; 결과: 10,9,8,7,6,5,4,3,2,1

    invoke ExitProcess, 0
main endp
end main

```




7. 문자열을 역순으로 복사 (Copy a String in Reverse Order)
* Write a program with a loop and indirect addressing that copies a string from source to target, reversing the character order in the process. Use the following variables:
```assembly
source BYTE "This is the source string",0
target BYTE SIZEOF source DUP('#')

```
* **해석:** 루프와 간접 주소 지정 방식을 사용하여 source의 문자열을 target으로 복사하되, 그 과정에서 문자 순서를 뒤집는 프로그램을 작성하세요. 위의 변수들을 사용하세요.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
source BYTE "This is the source string",0
target BYTE SIZEOF source DUP('#')

.code
main proc
    mov esi, OFFSET source + SIZEOF source - 2   ; 널 문자 바로 앞(마지막 문자)
    mov edi, OFFSET target                       ; target의 시작 주소
    mov ecx, SIZEOF source - 1                   ; 널 문자를 제외한 문자 수

L1:
    mov al, [esi]                      ; source에서 문자 읽기 (뒤에서부터)
    mov [edi], al                      ; target에 문자 쓰기 (앞에서부터)
    dec esi
    inc edi
    loop L1

    mov BYTE PTR [edi], 0              ; target 끝에 널 문자 추가
    ; target = "gnirts ecruos eht si sihT",0

    invoke ExitProcess, 0
main endp
end main

```




8. 배열 요소 이동 (Shifting the Elements in an Array)
* Using a loop and indexed addressing, write code that rotates the members of a 32-bit integer array forward one position. The value at the end of the array must wrap around to the first position. For example, the array [10,20,30,40] would be transformed into [40,10,20,30].
* **해석:** 루프와 인덱스 주소 지정 방식을 사용하여 32비트 정수 배열의 요소들을 앞으로 한 칸씩 회전시키는 코드를 작성하세요. 배열의 마지막 값은 첫 번째 위치로 이동해야 합니다. 예를 들어 배열 [10,20,30,40]은 [40,10,20,30]으로 변환됩니다.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
array DWORD 10,20,30,40

.code
main proc
    mov eax, array[(LENGTHOF array - 1) * TYPE array]   ; 마지막 값 저장 (40)
    mov esi, LENGTHOF array - 1                         ; 마지막 인덱스부터 시작
    mov ecx, LENGTHOF array - 1                         ; 이동 횟수

L1:
    mov edx, array[esi*TYPE array - 4]     ; array[i-1]
    mov array[esi*TYPE array], edx         ; array[i] = array[i-1]
    dec esi
    loop L1

    mov array, eax                         ; 첫 번째 위치에 마지막 값 저장
    ; 결과: 40,10,20,30

    invoke ExitProcess, 0
main endp
end main

```
