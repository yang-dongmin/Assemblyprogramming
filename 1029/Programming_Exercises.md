# Review Question and Exercises

## Programming Exercises

1. ASCII 10진수 출력 (Display ASCII Decimal)
* Write a procedure named WriteScaled that outputs a decimal ASCII number with an implied decimal point. Suppose the following number were defined as follows, where DECIMAL_OFFSET indicates that the decimal point must be inserted five positions from the right side of the number:
```assembly
DECIMAL_OFFSET = 5
.data
decimal_one BYTE "100123456789765"

```
* WriteScaled would display the number like this: `1001234567.89765`
* When calling WriteScaled, pass the number's offset in EDX, the number length in ECX, and the decimal offset in EBX. Write a test program that passes three numbers of different sizes to the WriteScaled procedure.
* **해석:** 소수점이 암묵적으로 정해진 ASCII 10진수를 출력하는 WriteScaled 프로시저를 작성하세요. 위의 DECIMAL_OFFSET은 수의 오른쪽에서 5번째 위치에 소수점을 넣어야 한다는 뜻이며, WriteScaled는 이 수를 `1001234567.89765`처럼 출력합니다. WriteScaled를 호출할 때 수의 오프셋은 EDX, 수의 길이는 ECX, 소수점 오프셋은 EBX로 전달하세요. 크기가 서로 다른 세 수를 WriteScaled에 전달하는 테스트 프로그램을 작성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
decimal_one   BYTE "100123456789765"   ; 1001234567.89765
decimal_two   BYTE "31415926"          ; 3.1415926
decimal_three BYTE "12345"             ; 123.45

.code
main PROC
    mov edx, OFFSET decimal_one
    mov ecx, SIZEOF decimal_one
    mov ebx, 5                         ; 오른쪽에서 5자리
    call WriteScaled
    call Crlf

    mov edx, OFFSET decimal_two
    mov ecx, SIZEOF decimal_two
    mov ebx, 7                         ; 오른쪽에서 7자리
    call WriteScaled
    call Crlf

    mov edx, OFFSET decimal_three
    mov ecx, SIZEOF decimal_three
    mov ebx, 2                         ; 오른쪽에서 2자리
    call WriteScaled
    call Crlf

    exit
main ENDP

;-----------------------------------------------------
; WriteScaled
;
; Displays an ASCII decimal number with an implied
; decimal point.
; Receives: EDX = offset of the number
;           ECX = length of the number
;           EBX = decimal offset (from the right side)
; Returns:  nothing
;-----------------------------------------------------
WriteScaled PROC USES eax ecx esi
    mov esi, edx                       ; ESI = 현재 문자 위치
    sub ecx, ebx                       ; ECX = 정수 부분의 자릿수
    jecxz point                        ; 정수 부분이 없으면 건너뜀

L1:
    mov al, [esi]                      ; 정수 부분 출력
    call WriteChar
    inc esi
    loop L1

point:
    mov al, '.'                        ; 소수점 출력
    call WriteChar

    mov ecx, ebx                       ; ECX = 소수 부분의 자릿수
    jecxz quit
L2:
    mov al, [esi]                      ; 소수 부분 출력
    call WriteChar
    inc esi
    loop L2

quit:
    ret
WriteScaled ENDP
END main

```


* **실행 결과:**
```
1001234567.89765
3.1415926
123.45
```




2. 확장 뺄셈 프로시저 (Extended Subtraction Procedure)
* Create a procedure named Extended_Sub that subtracts two binary integers of arbitrary size. The storage size of the two integers must be the same, and their size must be a multiple of 32 bits. Write a test program that passes several pairs of integers, each at least 10 bytes long.
* **해석:** 임의 크기의 두 이진 정수를 빼는 Extended_Sub 프로시저를 만드세요. 두 정수의 저장 크기는 같아야 하며 크기는 32비트의 배수여야 합니다. 각각 최소 10바이트 길이인 정수 쌍 여러 개를 전달하는 테스트 프로그램을 작성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
; 리틀 엔디언: 최하위 doubleword가 먼저 나옴
op1a DWORD 00000001h, 00000000h, 00000005h               ; 12바이트
op2a DWORD 00000002h, 00000000h, 00000001h

op1b DWORD 00000000h, 00000000h, 00000000h, 00000001h    ; 16바이트
op2b DWORD 00000001h, 00000000h, 00000000h, 00000000h

op1c DWORD 89ABCDEFh, 01234567h, 00000000h, 12345678h    ; 16바이트
op2c DWORD 11111111h, 11111111h, 00000000h, 02345678h

result DWORD 4 DUP(?)

.code
main PROC
    mov esi, OFFSET op1a               ; ESI = 피감수
    mov edi, OFFSET op2a               ; EDI = 감수
    mov ebx, OFFSET result             ; EBX = 결과
    mov ecx, LENGTHOF op1a             ; ECX = doubleword 개수
    call Extended_Sub
    mov esi, OFFSET result
    call DisplayLarge                  ; 00000003 FFFFFFFF FFFFFFFF

    mov esi, OFFSET op1b
    mov edi, OFFSET op2b
    mov ebx, OFFSET result
    mov ecx, LENGTHOF op1b
    call Extended_Sub
    mov esi, OFFSET result
    call DisplayLarge                  ; 00000000 FFFFFFFF FFFFFFFF FFFFFFFF

    mov esi, OFFSET op1c
    mov edi, OFFSET op2c
    mov ebx, OFFSET result
    mov ecx, LENGTHOF op1c
    call Extended_Sub
    mov esi, OFFSET result
    call DisplayLarge                  ; 0FFFFFFF FFFFFFFF F0123456 789ABCDE

    exit
main ENDP

;-----------------------------------------------------
; Extended_Sub
;
; Subtracts two integers of arbitrary size (multiple
; of 32 bits): [EBX] = [ESI] - [EDI]
; Receives: ESI = pointer to the first integer
;           EDI = pointer to the second integer
;           EBX = pointer to the result
;           ECX = number of doublewords
; Returns:  nothing
;-----------------------------------------------------
Extended_Sub PROC USES eax ebx ecx esi edi
    clc                                ; 처음에는 borrow 없음

L1:
    mov eax, [esi]
    sbb eax, [edi]                     ; borrow를 포함하여 뺄셈
    pushfd                             ; Carry 플래그 저장
    mov [ebx], eax                     ; 결과 저장
    add esi, TYPE DWORD                ; ADD는 CF를 바꾸므로
    add edi, TYPE DWORD                ;   앞뒤로 플래그를
    add ebx, TYPE DWORD                ;   저장/복원
    popfd                              ; Carry 플래그 복원
    loop L1

    ret
Extended_Sub ENDP

;-----------------------------------------------------
; DisplayLarge
;
; Displays a large integer in hexadecimal, starting
; from the most significant doubleword.
; Receives: ESI = pointer to the integer
;           ECX = number of doublewords
; Returns:  nothing
;-----------------------------------------------------
DisplayLarge PROC USES eax ecx esi
    lea esi, [esi + ecx*4 - 4]         ; 최상위 doubleword부터

L1:
    mov eax, [esi]
    call WriteHex
    mov al, ' '
    call WriteChar
    sub esi, TYPE DWORD
    loop L1

    call Crlf
    ret
DisplayLarge ENDP
END main

```


* **설명:** 각 doubleword를 `SBB`로 빼면서 borrow(CF)를 다음 doubleword로 넘깁니다. 포인터를 증가시키는 `ADD`가 CF를 바꾸므로 `PUSHFD / POPFD`로 플래그를 보존했습니다.
* **실행 결과:**
```
00000003 FFFFFFFF FFFFFFFF
00000000 FFFFFFFF FFFFFFFF FFFFFFFF
0FFFFFFF FFFFFFFF F0123456 789ABCDE
```




3. 팩 10진수 변환 (Packed Decimal Conversion)
* Write a procedure named PackedToAsc that converts a 4-byte packed decimal integer to a string of ASCII decimal digits. Pass the packed integer and the address of a buffer holding the ASCII digits to the procedure. Write a short test program that passes at least 5 packed decimal integers to your procedure.
* **해석:** 4바이트 팩 10진 정수를 ASCII 10진 숫자 문자열로 변환하는 PackedToAsc 프로시저를 작성하세요. 팩 정수와 ASCII 숫자를 저장할 버퍼의 주소를 프로시저에 전달하세요. 최소 5개의 팩 10진 정수를 프로시저에 전달하는 짧은 테스트 프로그램을 작성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
packedVals DWORD 12345678h, 00000099h, 87654321h, 20251029h, 99999999h
buffer     BYTE 9 DUP(0)               ; 8자리 + null

.code
main PROC
    mov edi, OFFSET packedVals
    mov ecx, LENGTHOF packedVals

L1:
    mov eax, [edi]                     ; EAX = 팩 10진 정수
    mov esi, OFFSET buffer             ; ESI = 버퍼 주소
    call PackedToAsc
    mov edx, OFFSET buffer
    call WriteString                   ; 변환된 문자열 출력
    call Crlf
    add edi, TYPE DWORD                ; 다음 정수
    loop L1

    exit
main ENDP

;-----------------------------------------------------
; PackedToAsc
;
; Converts a 4-byte packed decimal integer to a string
; of ASCII decimal digits.
; Receives: EAX = packed decimal integer
;           ESI = pointer to a buffer (at least 9 bytes)
; Returns:  buffer filled with 8 ASCII digits + null
;-----------------------------------------------------
PackedToAsc PROC USES eax ebx ecx esi
    mov ecx, 8                         ; 8자리 (4바이트 * 2)

L1:
    rol eax, 4                         ; 최상위 니블을 최하위로 회전
    mov bl, al
    and bl, 0Fh                        ; 니블 하나만 남김
    or  bl, 30h                        ; ASCII로 변환
    mov [esi], bl                      ; 버퍼에 저장
    inc esi
    loop L1

    mov BYTE PTR [esi], 0              ; 문자열 끝 null
    ret
PackedToAsc ENDP
END main

```


* **설명:** 팩 10진수는 한 니블(4비트)에 한 자리씩 들어 있습니다. `ROL eax,4`를 반복하면 최상위 자리부터 차례로 AL의 하위 니블에 오므로, 이를 `30h`와 OR해 ASCII 문자로 바꿉니다.
* **실행 결과:**
```
12345678
00000099
87654321
20251029
99999999
```




4. 회전 연산을 이용한 암호화 (Encryption Using Rotate Operations)
* Write a procedure that performs simple encryption by rotating each plaintext byte a varying number of positions in different directions. For example, in the following array that represents the encryption key, a negative value indicates a rotation to the left and a positive value indicates a rotation to the right. The integer in each position indicates the magnitude of the rotation:
```assembly
key BYTE -2, 4, 1, 0, -3, 5, 2, -4, -4, 6

```
* Your procedure should loop through a plaintext message and align the key to the first 10 bytes of the message. Rotate each plaintext byte by the amount indicated by its matching key array value. Then, align the key to the next 10 bytes of the message and repeat the process. Write a program that tests your encryption procedure by calling it twice, with different data sets.
* **해석:** 평문의 각 바이트를 서로 다른 방향, 서로 다른 횟수만큼 회전시켜 간단한 암호화를 수행하는 프로시저를 작성하세요. 위의 암호화 키 배열에서 음수는 왼쪽 회전, 양수는 오른쪽 회전을 뜻하고, 각 값의 크기는 회전 횟수를 뜻합니다. 프로시저는 평문을 순회하면서 키를 메시지의 처음 10바이트에 맞추고, 각 바이트를 대응하는 키 값만큼 회전시킵니다. 그 다음 키를 다음 10바이트에 맞추어 같은 과정을 반복합니다. 서로 다른 데이터로 암호화 프로시저를 두 번 호출하는 테스트 프로그램을 작성하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

ENCRYPT = 0
DECRYPT = 1

.data
key BYTE -2, 4, 1, 0, -3, 5, 2, -4, -4, 6
KEY_SIZE = ($ - key)

msg1 BYTE "This is a plaintext message for rotate encryption.",0
msg2 BYTE "Assembly Language 7.10 Programming Exercises",0

.code
main PROC
    ; 첫 번째 메시지
    mov esi, OFFSET msg1
    mov ecx, (SIZEOF msg1) - 1         ; null 제외
    call DisplayCipher

    ; 두 번째 메시지
    mov esi, OFFSET msg2
    mov ecx, (SIZEOF msg2) - 1
    call DisplayCipher

    exit
main ENDP

;-----------------------------------------------------
; DisplayCipher
;
; Displays a message, encrypts it, displays it,
; decrypts it, and displays it again.
; Receives: ESI = pointer to the message
;           ECX = length of the message
; Returns:  nothing
;-----------------------------------------------------
DisplayCipher PROC USES ebx edx
    mov edx, esi
    call WriteString                   ; 평문
    call Crlf

    mov bl, ENCRYPT
    call RotateCipher
    call WriteString                   ; 암호문
    call Crlf

    mov bl, DECRYPT
    call RotateCipher
    call WriteString                   ; 복호화된 평문
    call Crlf
    call Crlf
    ret
DisplayCipher ENDP

;-----------------------------------------------------
; RotateCipher
;
; Encrypts or decrypts a message by rotating each byte
; according to the key array.
; Receives: ESI = pointer to the message
;           ECX = length of the message
;           BL  = ENCRYPT (0) or DECRYPT (1)
; Returns:  nothing
;-----------------------------------------------------
RotateCipher PROC USES eax ecx esi edi
    mov edi, 0                         ; 키 인덱스

L1:
    push ecx                           ; 루프 카운터 저장 (CL을 회전 횟수로 사용)
    mov cl, key[edi]                   ; CL = 회전 방향 및 횟수
    cmp bl, ENCRYPT
    je  L2
    neg cl                             ; 복호화: 반대 방향으로 회전
L2:
    cmp cl, 0
    jl  RotLeft                        ; 음수 → 왼쪽 회전
    ror BYTE PTR [esi], cl             ; 양수 → 오른쪽 회전
    jmp L3
RotLeft:
    neg cl                             ; 회전 횟수를 양수로
    rol BYTE PTR [esi], cl
L3:
    pop ecx                            ; 루프 카운터 복원
    inc esi                            ; 다음 바이트
    inc edi                            ; 다음 키
    cmp edi, KEY_SIZE
    jb  L4
    mov edi, 0                         ; 키를 다음 10바이트에 다시 맞춤
L4:
    loop L1

    ret
RotateCipher ENDP
END main

```


* **설명:** 키 인덱스(EDI)가 10이 되면 0으로 되돌려 키를 다음 10바이트에 다시 맞춥니다. 회전은 비트를 잃지 않으므로, 같은 키로 **반대 방향** 회전하면 원래 평문으로 복호화됩니다. 0이 아닌 바이트는 회전해도 0이 되지 않으므로 암호문도 null 종료 문자열로 출력할 수 있습니다.




5. 소수 (Prime Numbers)
* Write a program that generates all prime numbers between 2 and 1000, using the Sieve of Eratosthenes method. You can find many articles that describe the method for finding primes in this manner on the Internet. Display all the prime values.
* **해석:** 에라토스테네스의 체(Sieve of Eratosthenes) 방법을 사용하여 2부터 1000 사이의 모든 소수를 구하는 프로그램을 작성하세요. 인터넷에서 이 방법을 설명하는 글을 많이 찾을 수 있습니다. 모든 소수를 출력하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

N = 1000

.data
sieve BYTE (N + 1) DUP(0)              ; 0 = 소수 후보, 1 = 합성수

.code
main PROC
    ; 체 만들기
    mov esi, 2                         ; i = 2

outer:
    mov eax, esi
    mul esi                            ; EAX = i * i
    cmp eax, N
    ja  display                        ; i * i > N 이면 체 완성
    cmp sieve[esi], 0
    jne nextI                          ; 이미 지워진 수는 건너뜀
    mov edi, eax                       ; j = i * i 부터

inner:
    cmp edi, N
    ja  nextI
    mov sieve[edi], 1                  ; i의 배수 지우기
    add edi, esi                       ; j += i
    jmp inner

nextI:
    inc esi
    jmp outer

    ; 소수 출력
display:
    mov esi, 2

L1:
    cmp sieve[esi], 0
    jne next                           ; 합성수는 건너뜀
    mov eax, esi
    call WriteDec                      ; 소수 출력
    mov al, ' '
    call WriteChar
next:
    inc esi
    cmp esi, N
    jbe L1

    call Crlf
    exit
main ENDP
END main

```


* **설명:** 2부터 시작하여 지워지지 않은 수 i를 만나면 i의 배수를 모두 지웁니다. i보다 작은 배수(2i, 3i, ...)는 이미 더 작은 소수에서 지워졌으므로 `i * i`부터 지우면 되고, `i * i > N`이면 체가 완성됩니다. 2 ~ 1000 사이의 소수는 모두 168개입니다.
* **실행 결과:**
```
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 ... 977 983 991 997
```




6. 최대공약수 (Greatest Common Divisor (GCD))
* The greatest common divisor (GCD) of two integers is the largest integer that will evenly divide both integers. The GCD algorithm involves integer division in a loop, described by the following pseudocode:
```
int GCD(int x, int y)
{
    x = abs(x)          // absolute value
    y = abs(y)
    do {
        int n = x % y
        x = y
        y = n
    } while (y > 0)
    return x
}
```
* Implement this function in assembly language and write a test program that calls the function several times, passing it different values. Display all results on the screen.
* **해석:** 두 정수의 최대공약수(GCD)는 두 정수를 모두 나누어떨어지게 하는 가장 큰 정수입니다. GCD 알고리즘은 위 의사 코드처럼 루프 안에서 정수 나눗셈을 사용합니다. 이 함수를 어셈블리 언어로 구현하고, 서로 다른 값을 전달하여 함수를 여러 번 호출하는 테스트 프로그램을 작성하세요. 모든 결과를 화면에 출력하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
xVals SDWORD 5, 24, 11, 432, 26, -48
yVals SDWORD 20, 18, 7, 226, 13, 36

str1 BYTE "GCD(",0
str2 BYTE ", ",0
str3 BYTE ") = ",0

.code
main PROC
    mov esi, 0                         ; 인덱스
    mov ecx, LENGTHOF xVals

L1:
    mov edx, OFFSET str1               ; "GCD("
    call WriteString
    mov eax, xVals[esi*4]
    call WriteInt                      ; x
    mov edx, OFFSET str2               ; ", "
    call WriteString
    mov eax, yVals[esi*4]
    call WriteInt                      ; y
    mov edx, OFFSET str3               ; ") = "
    call WriteString

    mov eax, xVals[esi*4]              ; EAX = x
    mov ebx, yVals[esi*4]              ; EBX = y
    call GCD                           ; EAX = GCD(x, y)
    call WriteDec
    call Crlf

    inc esi
    loop L1

    exit
main ENDP

;-----------------------------------------------------
; GCD
;
; Calculates the greatest common divisor of two
; integers.
; Receives: EAX = x, EBX = y (signed integers)
; Returns:  EAX = GCD(x, y)
;-----------------------------------------------------
GCD PROC USES ebx edx
    cmp eax, 0                         ; x = abs(x)
    jge L1
    neg eax
L1:
    cmp ebx, 0                         ; y = abs(y)
    jge L2
    neg ebx
L2:
    cmp ebx, 0                         ; y = 0 이면 0으로 나누기 방지
    je  quit

L3:
    mov edx, 0                         ; 피제수 상위 지우기
    div ebx                            ; EDX = n = x % y
    mov eax, ebx                       ; x = y
    mov ebx, edx                       ; y = n
    cmp ebx, 0
    ja  L3                             ; while (y > 0)

quit:
    ret
GCD ENDP
END main

```


* **설명:** 절댓값을 구한 뒤에는 x, y가 모두 양수이므로 부호 없는 `DIV`를 사용합니다. 의사 코드는 do-while이라 y가 0이면 0으로 나누게 되므로, 루프 전에 y = 0인지 검사했습니다.
* **실행 결과:**
```
GCD(+5, +20) = 5
GCD(+24, +18) = 6
GCD(+11, +7) = 1
GCD(+432, +226) = 2
GCD(+26, +13) = 13
GCD(-48, +36) = 12
```




7. 비트 단위 곱셈 (Bitwise Multiplication)
* Write a procedure named BitwiseMultiply that multiplies any unsigned 32-bit integer by EAX, using only shifting and addition. Pass the integer to the procedure in the EBX register, and return the product in the EAX register. Write a short test program that calls the procedure and displays the product. (We will assume that the product is never larger than 32 bits.) This is a fairly challenging program to write. One possible approach is to use a loop to shift the multiplier to the right, keeping track of the number of shifts that occur before the Carry flag is set. The resulting shift count can then be applied to the SHL instruction, using the multiplicand as the destination operand. Then, the same process must be repeated until you find the last 1 bit in the multiplier.
* **해석:** 시프트와 덧셈만 사용하여 임의의 32비트 부호 없는 정수에 EAX를 곱하는 BitwiseMultiply 프로시저를 작성하세요. 정수는 EBX로 전달하고 곱은 EAX로 반환합니다. 프로시저를 호출하고 곱을 출력하는 짧은 테스트 프로그램을 작성하세요. (곱은 32비트를 넘지 않는다고 가정합니다.) 꽤 어려운 문제입니다. 한 가지 방법은 루프에서 승수를 오른쪽으로 시프트하면서 Carry 플래그가 설정되기 전까지의 시프트 횟수를 세는 것입니다. 그 횟수만큼 피승수를 SHL로 시프트하고, 승수의 마지막 1비트를 찾을 때까지 이 과정을 반복합니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
multiplicands DWORD 123, 1000, 0FFFFh, 7, 25
multipliers   DWORD 36,  1000, 3,      0, 25

str1 BYTE " * ",0
str2 BYTE " = ",0

.code
main PROC
    mov esi, 0                         ; 인덱스
    mov ecx, LENGTHOF multiplicands

L1:
    mov eax, multiplicands[esi*4]
    call WriteDec                      ; 피승수
    mov edx, OFFSET str1
    call WriteString
    mov eax, multipliers[esi*4]
    call WriteDec                      ; 승수
    mov edx, OFFSET str2
    call WriteString

    mov eax, multiplicands[esi*4]      ; EAX = 피승수
    mov ebx, multipliers[esi*4]        ; EBX = 승수
    call BitwiseMultiply               ; EAX = 곱
    call WriteDec
    call Crlf

    inc esi
    loop L1

    exit
main ENDP

;-----------------------------------------------------
; BitwiseMultiply
;
; Multiplies EAX by EBX using only shifting and
; addition (unsigned).
; Receives: EAX = multiplicand, EBX = multiplier
; Returns:  EAX = product (assumed to fit in 32 bits)
;-----------------------------------------------------
BitwiseMultiply PROC USES ebx edx
    mov edx, eax                       ; EDX = 피승수 (자리에 맞게 시프트됨)
    mov eax, 0                         ; EAX = 곱

L1:
    shr ebx, 1                         ; 승수의 최하위 비트를 CF로
    jnc L2                             ; 비트가 0이면 더하지 않음
    add eax, edx                       ; 비트가 1이면 시프트된 피승수를 더함
L2:
    shl edx, 1                         ; 피승수를 다음 자리로 (* 2)
    test ebx, ebx
    jnz L1                             ; 승수에 1비트가 남아 있으면 반복

    ret
BitwiseMultiply ENDP
END main

```


* **설명:** 7.2절의 이진 곱셈(`EAX * 36 = EAX * 2⁵ + EAX * 2²`)과 같은 원리입니다. 승수를 오른쪽으로 한 비트씩 밀면서 1인 비트가 나올 때마다 그 자리만큼 왼쪽으로 시프트된 피승수를 곱에 더합니다. 피승수를 매 반복마다 1비트씩 왼쪽으로 밀어 두므로 시프트 횟수를 따로 셀 필요가 없고, 승수가 0이 되면(마지막 1비트를 처리하면) 종료합니다.
* **실행 결과:**
```
123 * 36 = 4428
1000 * 1000 = 1000000
65535 * 3 = 196605
7 * 0 = 0
25 * 25 = 625
```




8. 팩 정수 덧셈 (Add Packed Integers)
* Extend the AddPacked procedure from Section 7.6.1 so that it adds two packed decimal integers of arbitrary size (both lengths must be the same). Write a test program that passes AddPacked several pairs of integers: 4-byte, 8-byte, and 16-byte. We suggest that you use the following registers to pass information to the procedure:
```
ESI - pointer to the first number
EDI - pointer to the second number
EDX - pointer to the sum
ECX - number of bytes to add
```
* **해석:** 7.6.1절의 AddPacked 프로시저를 확장하여 임의 크기의 두 팩 10진 정수(두 길이는 같아야 함)를 더하도록 만드세요. 4바이트, 8바이트, 16바이트 정수 쌍을 AddPacked에 전달하는 테스트 프로그램을 작성하세요. 위의 레지스터로 프로시저에 정보를 전달할 것을 권장합니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
; 리틀 엔디언: 최하위 바이트(최하위 두 자리)가 먼저 나옴
p4a  DWORD 87654321h                               ; 4바이트
p4b  DWORD 45678912h
sum4 BYTE 5 DUP(?)                                 ; 마지막 carry용 1바이트 추가

p8a  QWORD 1234567890123456h                       ; 8바이트
p8b  QWORD 9876543210987654h
sum8 BYTE 9 DUP(?)

p16a QWORD 1234567890123456h, 9999999999999999h    ; 16바이트 (하위, 상위)
p16b QWORD 8765432109876544h, 0000000000000000h
sum16 BYTE 17 DUP(?)

.code
main PROC
    mov esi, OFFSET p4a
    mov edi, OFFSET p4b
    mov edx, OFFSET sum4
    mov ecx, SIZEOF p4a
    call AddPacked
    mov esi, OFFSET sum4
    mov ecx, SIZEOF sum4
    call DisplayPacked                 ; 0133333233

    mov esi, OFFSET p8a
    mov edi, OFFSET p8b
    mov edx, OFFSET sum8
    mov ecx, SIZEOF p8a
    call AddPacked
    mov esi, OFFSET sum8
    mov ecx, SIZEOF sum8
    call DisplayPacked                 ; 011111111101111110

    mov esi, OFFSET p16a
    mov edi, OFFSET p16b
    mov edx, OFFSET sum16
    mov ecx, SIZEOF p16a
    call AddPacked
    mov esi, OFFSET sum16
    mov ecx, SIZEOF sum16
    call DisplayPacked                 ; 01000...000 (0이 32개)

    exit
main ENDP

;-----------------------------------------------------
; AddPacked
;
; Adds two packed decimal integers of arbitrary size.
; Receives: ESI = pointer to the first number
;           EDI = pointer to the second number
;           EDX = pointer to the sum (ECX + 1 bytes)
;           ECX = number of bytes to add
; Returns:  nothing
;-----------------------------------------------------
AddPacked PROC USES eax ecx edx esi edi
    clc                                ; 처음에는 carry 없음

L1:
    mov al, [esi]
    adc al, [edi]                      ; carry를 포함하여 더함
    daa                                ; 팩 10진수로 조정 (CF = 10진 carry)
    mov [edx], al                      ; 합 저장
    inc esi                            ; INC와 LOOP는
    inc edi                            ;   CF를 바꾸지 않음
    inc edx
    loop L1

    mov al, 0                          ; 마지막 carry가 있으면
    adc al, 0                          ;   최상위 바이트에 저장
    mov [edx], al
    ret
AddPacked ENDP

;-----------------------------------------------------
; DisplayPacked
;
; Displays a packed decimal integer, starting from
; the most significant byte.
; Receives: ESI = pointer to the number
;           ECX = number of bytes
; Returns:  nothing
;-----------------------------------------------------
DisplayPacked PROC USES eax ebx ecx esi
    mov ebx, 1                         ; WriteHexB 출력 크기 = 1바이트

L1:
    movzx eax, BYTE PTR [esi + ecx - 1]    ; 최상위 바이트부터
    call WriteHexB                     ; 두 자리 출력
    loop L1

    call Crlf
    ret
DisplayPacked ENDP
END main

```


* **설명:** 7.6.1절의 AddPacked는 2바이트 고정이었지만, 루프를 사용해 ECX 바이트만큼 `ADC + DAA`를 반복하도록 확장했습니다. 포인터 증가에 `INC`를 사용하면 CF가 유지되므로 플래그를 따로 저장할 필요가 없습니다. 합을 저장할 버퍼는 마지막 carry를 위해 **ECX + 1 바이트**가 필요합니다.
* **실행 결과:**
```
0133333233
011111111101111110
0100000000000000000000000000000000
```
* (`87654321 + 45678912 = 133333233`, `1234567890123456 + 9876543210987654 = 11111111101111110`, `99999999999999991234567890123456 + 8765432109876544 = 100000000000000000000000000000000`)
