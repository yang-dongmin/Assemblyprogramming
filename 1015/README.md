# 1015

## 6.1 조건 분기 (Conditional Branching)

어셈블리 언어는 원시적이지만, **의사 결정 로직에 필요한 모든 도구**를 제공함.

| 주제 | 설명 |
| --- | --- |
| **Boolean Operations** | AND, OR, NOT 연산을 논리식에 사용하는 방법 |
| **IF Statements** | IF문을 작성하는 방법과 컴파일러가 이를 어떻게 번역하는지 |
| **Bit Manipulation** | 이진수의 개별 비트를 설정(set)하고 지우는(clear) 방법 |
| **Data Encryption** | 간단한 이진 데이터 암호화 기법 |
| **Signed vs Unsigned Numbers** | 불리언 표현식에서 부호 있는 수와 부호 없는 수를 구분하는 방법 |

---

## 6.2 불리언 및 비교 명령어 (Boolean and Comparison Instructions)

### 1. 주요 불리언 명령어 (Table 6-1)

| 명령어 | 설명 |
| --- | --- |
| **AND** | source와 destination 사이의 불리언 AND 연산 |
| **OR** | source와 destination 사이의 불리언 OR 연산 |
| **XOR** | source와 destination 사이의 불리언 배타적 OR 연산 |
| **NOT** | destination에 대한 불리언 NOT 연산 |
| **TEST** | source와 destination 사이의 암묵적 AND 연산. 결과는 저장하지 않고 플래그만 설정 |

---

### 2. CPU 상태 플래그 (The CPU Status Flags)

불리언 명령어는 Zero, Carry, Sign, Overflow, Parity 플래그에 영향을 줌.

| 플래그 | 설정되는 경우 |
| --- | --- |
| **Zero** | 연산 결과가 0일 때 |
| **Carry** | 연산 결과 destination의 최상위 비트에서 자리올림(carry out)이 발생할 때 |
| **Sign** | destination의 최상위 비트의 복사본 (1이면 음수) |
| **Overflow** | 결과가 부호 있는 범위를 벗어날 때 |
| **Parity** | 결과 하위 바이트의 1인 비트 개수가 짝수일 때 |

---

### 3. AND 명령어

두 피연산자의 대응하는 비트끼리 AND 연산을 수행하고 결과를 destination에 저장함.
**다른 비트에 영향을 주지 않고 1개 이상의 비트를 지울 때** 사용함 → **비트 마스크(bit mask)**.

```assembly
AND destination, source

AND reg, reg
AND reg, mem
AND reg, imm
AND mem, reg
AND mem, imm
```

| x | y | x ∧ y |
| --- | --- | --- |
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

```
      0 0 1 1 1 0 1 1
AND   0 0 0 0 1 1 1 1
      ---------------
      0 0 0 0 1 0 1 1
      └cleared┘└unchanged┘
```

```assembly
mov al, 10101110b
and al, 11110110b       ; result in AL = 10100110
```

* **AND는 항상 Overflow와 Carry 플래그를 0으로 지움.**
* Sign, Zero, Parity 플래그는 결과에 따라 변경됨.

#### 활용: 소문자를 대문자로 변환 (Converting Characters to Upper case)

`'a'`(61h)와 `'A'`(41h)는 **비트 5만 다름**. 따라서 `11011111b`와 AND하면 비트 5만 지워져 대문자가 됨.

```
0 1 1 0 0 0 0 1 = 61h ('a')
0 1 0 0 0 0 0 1 = 41h ('A')
```

```assembly
.data
array BYTE 50 DUP(?)

.code
    mov ecx, LENGTHOF array
    mov esi, OFFSET array
L1: and BYTE PTR [esi], 11011111b   ; 비트 5 지우기
    inc esi
    loop L1
```

---

### 4. OR 명령어

두 피연산자의 대응하는 비트끼리 OR 연산을 수행하고 결과를 destination에 저장함.
**다른 비트에 영향을 주지 않고 특정 비트를 1로 설정**할 때 사용함.

```assembly
OR destination, source

OR reg, reg
OR reg, mem
OR reg, imm
OR mem, reg
OR mem, imm
```

| x | y | x ∨ y |
| --- | --- | --- |
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |

```
      0 0 1 1 1 0 1 1
OR    0 0 0 0 1 1 1 1
      ---------------
      0 0 1 1 1 1 1 1
      └unchanged┘└set┘
```

```assembly
mov al, 11100011b
or  al, 00000100b       ; result in AL = 11100111
```

* **OR는 항상 Carry와 Overflow 플래그를 0으로 지움.**
* Sign, Zero, Parity 플래그는 결과에 따라 변경됨.

---

### 5. 비트 맵 집합 (Bit-Mapped Sets)

32비트 값의 각 비트를 집합의 원소 하나로 사용함. 아래는 원소 0, 1, 2, 31이 집합 SetX에 속하는 경우.

```
SetX = 10000000 00000000 00000000 00000111
```

#### ① 원소 포함 여부 확인

```assembly
mov eax, SetX
and eax, 10000b         ; element[4]가 SetX의 원소인가?
```

→ AND 결과 **Zero 플래그가 0(clear)이면** element[4]는 SetX의 원소임.

#### ② 여집합 (Set Complement)

NOT으로 모든 비트를 뒤집어 여집합을 만듦.

```assembly
mov eax, SetX
not eax                 ; SetX의 여집합
```

#### ③ 교집합 (Set Intersection) - AND

```assembly
mov eax, SetX
and eax, SetY
```

```
        10000000000000000000000000000111   (SetX)
AND     10000010101000000000011101100011   (SetY)
        --------------------------------
        10000000000000000000000000000011   (intersection)
```

#### ④ 합집합 (Set Union) - OR

```assembly
mov eax, SetX
or  eax, SetY
```

```
        10000000000000000000000000000111   (SetX)
OR      10000010101000000000011101100011   (SetY)
        --------------------------------
        10000010101000000000011101100111   (union)
```

---

### 6. XOR 명령어

두 피연산자의 대응하는 비트끼리 배타적 OR 연산을 수행하고 결과를 destination에 저장함.
**두 비트가 다르면 1, 같으면 0**. 같은 값으로 두 번 XOR하면 원래 값으로 돌아옴 → 암호화에 활용.

```assembly
XOR destination, source
```

| x | y | x ⊕ y | (x ⊕ y) ⊕ y |
| --- | --- | --- | --- |
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |

```
      0 0 1 1 1 0 1 1
XOR   0 0 0 0 1 1 1 1
      ---------------
      0 0 1 1 0 1 0 0
      └unchanged┘└inverted┘
```

* **XOR는 항상 Overflow와 Carry 플래그를 0으로 지움.**
* Sign, Zero, Parity 플래그는 결과에 따라 변경됨.

#### 활용: Parity 플래그 확인 (Checking the Parity Flag)

값을 바꾸지 않고 패리티를 확인하려면 **0과 XOR**하면 됨.

```assembly
mov al, 10110101b       ; 1이 5개 = 홀수 패리티
xor al, 0               ; Parity 플래그 clear (홀수)
mov al, 11001100b       ; 1이 4개 = 짝수 패리티
xor al, 0               ; Parity 플래그 set (짝수)
```

16비트 값의 패리티는 상위 바이트와 하위 바이트를 XOR하여 확인함.

```assembly
mov ax, 64C1h           ; 0110 0100 1100 0001
xor ah, al              ; Parity 플래그 set (짝수)
```

---

### 7. NOT 명령어

피연산자의 **모든 비트를 반전**시킴. 결과를 **1의 보수(one's complement)** 라고 함.

```assembly
NOT reg
NOT mem
```

```assembly
mov al, 11110000b
not al                  ; AL = 00001111b
```

```
NOT   0 0 1 1 1 0 1 1
      ---------------
      1 1 0 0 0 1 0 0   ← inverted
```

* **NOT은 어떤 플래그에도 영향을 주지 않음.**

---

### 8. TEST 명령어

두 피연산자 사이에 **암묵적인 AND 연산**을 수행하여 Sign, Zero, Parity 플래그를 설정함.
**AND와의 유일한 차이점은 destination을 변경하지 않는다는 것.**

#### 예: 여러 비트 검사 (Testing Multiple Bits)

비트 0 또는 비트 3 중 하나라도 1인지 확인:

```
0 0 1 0 0 1 0 1   <- input value
0 0 0 0 1 0 0 1   <- test value
0 0 0 0 0 0 0 1   <- result: ZF = 0

0 0 1 0 0 1 0 0   <- input value
0 0 0 0 1 0 0 1   <- test value
0 0 0 0 0 0 0 0   <- result: ZF = 1
```

* **TEST는 항상 Overflow와 Carry 플래그를 0으로 지움.**
* Sign, Zero, Parity 플래그는 AND와 같은 방식으로 변경됨.

---

### 9. CMP 명령어

destination에서 source를 빼는 **암묵적인 뺄셈**을 수행함. **두 피연산자 모두 변경되지 않음.**

```assembly
CMP destination, source
```

* 고급 언어의 `if A > B`, `while X > 0 and X < 200`, `if check_for_error(N) = true` 같은 조건 처리의 기반이 됨.
* 실제로 뺄셈을 했을 때의 결과에 따라 **Overflow, Sign, Zero, Carry, Auxiliary Carry, Parity** 플래그를 변경함.

#### 부호 없는 비교 (unsigned operands are compared)

| CMP 결과 | ZF | CF |
| --- | --- | --- |
| Destination < source | 0 | 1 |
| Destination > source | 0 | 0 |
| Destination = source | 1 | 0 |

#### 부호 있는 비교 (signed operands are compared)

| CMP 결과 | Flags |
| --- | --- |
| Destination < source | SF ≠ OF |
| Destination > source | SF = OF |
| Destination = source | ZF = 1 |

#### 예제

```assembly
mov ax, 5
cmp ax, 10              ; ZF = 0 and CF = 1  (5 < 10)

mov ax, 1000
mov cx, 1000
cmp cx, ax              ; ZF = 1 and CF = 0  (같음)

mov si, 105
cmp si, 0               ; ZF = 0 and CF = 0  (105 > 0)
```

---

### 10. 개별 CPU 플래그 설정과 해제 (Setting and Clearing Individual CPU Flags)

```assembly
test al, 0              ; Zero 플래그 set
and  al, 0              ; Zero 플래그 set
or   al, 1              ; Zero 플래그 clear

or   al, 80h            ; Sign 플래그 set
and  al, 7Fh            ; Sign 플래그 clear

stc                     ; Carry 플래그 set
clc                     ; Carry 플래그 clear

mov  al, 7Fh            ; AL = +127
inc  al                 ; AL = 80h (-128), OF = 1
or   eax, 0             ; Overflow 플래그 clear
```

---

## 6.3 조건 점프 (Conditional Jumps)

### 1. 조건 구조 (Conditional Structures)

x86 명령어 집합에는 명시적인 고급 논리 구조가 없지만, **비교와 점프의 조합**으로 구현할 수 있음.

| 단계 | 내용 |
| --- | --- |
| **1. Modify CPU Status Flags** | CMP, AND, SUB 같은 연산이 CPU 상태 플래그를 변경 |
| **2. Test Status Flags** | 조건 점프 명령어가 상태 플래그를 검사 |
| **3. Branch to New Address** | 플래그가 조건을 만족하면 새 주소로 점프 |

```assembly
; Example 1
    cmp eax, 0
    jz  L1                  ; ZF = 1이면 점프
    .
    .
L1:

; Example 2
    and dl, 10110000b
    jnz L2                  ; ZF = 0이면 점프
    .
    .
L2:
```

---

### 2. Jcond 명령어

조건 점프 명령어는 **상태 플래그 조건이 참일 때** destination 레이블로 분기함.

```assembly
Jcond destination
```

| 명령어 | 설명 |
| --- | --- |
| **JC** | Jump if carry (Carry 플래그 set) |
| **JNC** | Jump if not carry (Carry 플래그 clear) |
| **JZ** | Jump if zero (Zero 플래그 set) |
| **JNZ** | Jump if not zero (Zero 플래그 clear) |

#### CMP 명령어와 함께 사용

```assembly
cmp eax, 5
je  L1                  ; 같으면 점프

mov ax, 5
cmp ax, 6
jl  L1                  ; 작으면 점프

mov ax, 5
cmp ax, 4
jg  L1                  ; 크면 점프
```

---

### 3. 조건 점프 명령어의 종류 (Types of Conditional Jump Instructions)

| 분류 | 기준 |
| --- | --- |
| **Flag values** | 특정 플래그 값에 따라 점프 |
| **Equality** | 두 피연산자가 같은지 여부 또는 (E)CX 값에 따라 점프 |
| **Unsigned operands** | 부호 없는 피연산자의 비교 결과에 따라 점프 |
| **Signed operands** | 부호 있는 피연산자의 비교 결과에 따라 점프 |

#### ① 특정 플래그 값 기준 (Table 6-2)

| 명령어 | 설명 | 플래그 |
| --- | --- | --- |
| **JZ** | Jump if zero | ZF = 1 |
| **JNZ** | Jump if not zero | ZF = 0 |
| **JC** | Jump if carry | CF = 1 |
| **JNC** | Jump if not carry | CF = 0 |
| **JO** | Jump if overflow | OF = 1 |
| **JNO** | Jump if not overflow | OF = 0 |
| **JS** | Jump if signed | SF = 1 |
| **JNS** | Jump if not signed | SF = 0 |
| **JP** | Jump if parity (even) | PF = 1 |
| **JNP** | Jump if not parity (odd) | PF = 0 |

#### ② 같음 비교 기준 (Equality Comparisons, Table 6-3)

| 명령어 | 설명 |
| --- | --- |
| **JE** | Jump if equal (leftOp = rightOp) |
| **JNE** | Jump if not equal (leftOp ≠ rightOp) |
| **JCXZ** | Jump if CX = 0 |
| **JECXZ** | Jump if ECX = 0 |
| **JRCXZ** | Jump if RCX = 0 (64비트 모드) |

```assembly
; Example 1
mov edx, 0A523h
cmp edx, 0A523h
jne L5                  ; 점프 안 함
je  L1                  ; 점프함

; Example 2
mov bx, 1234h
sub bx, 1234h
jne L5                  ; 점프 안 함
je  L1                  ; 점프함

; Example 3
mov  cx, 0FFFFh
inc  cx                 ; CX = 0
jcxz L2                 ; 점프함

; Example 4
xor   ecx, ecx          ; ECX = 0
jecxz L2                ; 점프함
```

#### ③ 부호 없는 비교 기준 (Unsigned Comparisons, Table 6-4)

**A**bove / **B**elow 사용.

| 명령어 | 설명 |
| --- | --- |
| **JA** | Jump if above (leftOp > rightOp) |
| **JNBE** | Jump if not below or equal (JA와 같음) |
| **JAE** | Jump if above or equal (leftOp ≥ rightOp) |
| **JNB** | Jump if not below (JAE와 같음) |
| **JB** | Jump if below (leftOp < rightOp) |
| **JNAE** | Jump if not above or equal (JB와 같음) |
| **JBE** | Jump if below or equal (leftOp ≤ rightOp) |
| **JNA** | Jump if not above (JBE와 같음) |

#### ④ 부호 있는 비교 기준 (Signed Comparisons, Table 6-5)

**G**reater / **L**ess 사용.

| 명령어 | 설명 |
| --- | --- |
| **JG** | Jump if greater (leftOp > rightOp) |
| **JNLE** | Jump if not less than or equal (JG와 같음) |
| **JGE** | Jump if greater than or equal (leftOp ≥ rightOp) |
| **JNL** | Jump if not less (JGE와 같음) |
| **JL** | Jump if less (leftOp < rightOp) |
| **JNGE** | Jump if not greater than or equal (JL과 같음) |
| **JLE** | Jump if less than or equal (leftOp ≤ rightOp) |
| **JNG** | Jump if not greater (JLE와 같음) |

```assembly
; Example 1
mov  edx, -1
cmp  edx, 0
jnl  L5                 ; 점프 안 함 (-1 >= 0 은 거짓)
jnle L5                 ; 점프 안 함 (-1 > 0 은 거짓)
jl   L1                 ; 점프함 (-1 < 0 은 참)

; Example 2
mov  bx, +32
cmp  bx, -35
jng  L5                 ; 점프 안 함 (+32 <= -35 는 거짓)
jnge L5                 ; 점프 안 함 (+32 < -35 는 거짓)
jge  L1                 ; 점프함 (+32 >= -35 는 참)

; Example 3
mov ecx, 0
cmp ecx, 0
jg  L5                  ; 점프 안 함 (0 > 0 은 거짓)
jnl L1                  ; 점프함 (0 >= 0 은 참)

; Example 4
mov ecx, 0
cmp ecx, 0
jl  L5                  ; 점프 안 함 (0 < 0 은 거짓)
jng L1                  ; 점프함 (0 <= 0 은 참)
```

---

### 4. 조건 점프 활용 (Conditional Jump Applications)

#### ① 상태 비트 검사 (Testing Status Bits)

```assembly
mov  al, status
test al, 00100000b      ; 비트 5 검사
jnz  DeviceOffline

mov  al, status
test al, 00010011b      ; 비트 0, 1, 4 검사 (하나라도 1이면 점프)
jnz  InputDataByte

mov  al, status
and  al, 10001100b      ; 비트 2, 3, 7만 남김
cmp  al, 10001100b      ; 세 비트가 모두 1인가?
je   ResetMachine       ; yes: 레이블로 점프
```

#### ② 두 정수 중 큰 값 (Larger of Two Integers)

```assembly
    mov edx, eax        ; EAX가 크다고 가정
    cmp eax, ebx        ; EAX >= EBX 이면
    jae L1              ;   L1로 점프
    mov edx, ebx        ; 아니면 EBX를 EDX로 이동
L1:                     ; EDX에 큰 정수가 들어 있음
```

#### ③ 세 정수 중 가장 작은 값 (Smallest of Three Integers)

```assembly
.data
V1 WORD ?
V2 WORD ?
V3 WORD ?

.code
    mov ax, V1          ; V1이 가장 작다고 가정
    cmp ax, V2          ; AX <= V2 이면
    jbe L1              ;   L1로 점프
    mov ax, V2          ; 아니면 V2를 AX로 이동
L1: cmp ax, V3          ; AX <= V3 이면
    jbe L2              ;   L2로 점프
    mov ax, V3          ; 아니면 V3를 AX로 이동
L2:
```

#### ④ 키 입력까지 반복 (Loop until Key Pressed)

```assembly
.data
char BYTE ?

.code
L1: mov  eax, 10        ; 10ms 지연
    call Delay
    call ReadKey        ; 키 입력 확인
    jz   L1             ; 키가 없으면 반복
    mov  char, AL       ; 문자 저장
```

* `ReadKey`는 키 입력이 없으면 ZF = 1을 반환하므로 `jz`로 계속 대기함.

---

### 5. 응용: 배열 순차 검색 (Sequential Search of an Array)

배열에서 **처음으로 0이 아닌 값**을 찾아 출력함.

```assembly
; Scanning an Array (ArrayScan.asm)
; Scan an array for the first nonzero value.

INCLUDE Irvine32.inc

.data
intArray SWORD 0,0,0,0,1,20,35,-12,66,4,0
;intArray SWORD 1,0,0,0         ; 대체 테스트 데이터
;intArray SWORD 0,0,0,0         ; 대체 테스트 데이터
;intArray SWORD 0,0,0,1         ; 대체 테스트 데이터
noneMsg  BYTE "A non-zero value was not found",0

.code
main PROC
    mov ebx, OFFSET intArray        ; 배열을 가리킴
    mov ecx, LENGTHOF intArray      ; 루프 카운터
L1: cmp WORD PTR [ebx], 0           ; 값을 0과 비교
    jnz found                       ; 값을 찾음
    add ebx, 2                      ; 다음 원소를 가리킴
    loop L1                         ; 루프 계속
    jmp notFound                    ; 찾지 못함

found:                              ; 값 출력
    movsx eax, WORD PTR [ebx]       ; EAX로 부호 확장
    call WriteInt
    jmp quit

notFound:                           ; "not found" 메시지 출력
    mov edx, OFFSET noneMsg
    call WriteString

quit:
    call Crlf
    exit
main ENDP
END main
```

---

### 6. 응용: 문자열 암호화 (Encryption Program)

XOR의 성질 **(x ⊕ y) ⊕ y = x** 를 이용해, 같은 키로 한 번 XOR하면 암호화되고 다시 XOR하면 복호화됨.

```assembly
; Encryption Program (Encrypt.asm)

INCLUDE Irvine32.inc

KEY    = 239                    ; 1-255 사이의 아무 값
BUFMAX = 128                    ; 최대 버퍼 크기

.data
sPrompt  BYTE "Enter the plain text:",0
sEncrypt BYTE "Cipher text:",0
sDecrypt BYTE "Decrypted:",0
buffer   BYTE BUFMAX+1 DUP(0)
bufSize  DWORD ?

.code
main PROC
    call InputTheString         ; 평문 입력
    call TranslateBuffer        ; 버퍼 암호화
    mov  edx, OFFSET sEncrypt   ; 암호화된 메시지 출력
    call DisplayMessage
    call TranslateBuffer        ; 버퍼 복호화
    mov  edx, OFFSET sDecrypt   ; 복호화된 메시지 출력
    call DisplayMessage
    exit
main ENDP

;----------------------------------------------------
InputTheString PROC
;
; Prompts user for a plaintext string. Saves the string
; and its length.
; Receives: nothing
; Returns: nothing
;----------------------------------------------------
    pushad                      ; 32비트 레지스터 저장
    mov  edx, OFFSET sPrompt    ; 안내 문구 출력
    call WriteString
    mov  ecx, BUFMAX            ; 최대 문자 수
    mov  edx, OFFSET buffer     ; 버퍼를 가리킴
    call ReadString             ; 문자열 입력
    mov  bufSize, eax           ; 길이 저장
    call Crlf
    popad
    ret
InputTheString ENDP

;----------------------------------------------------
DisplayMessage PROC
;
; Displays the encrypted or decrypted message.
; Receives: EDX points to the message
; Returns: nothing
;----------------------------------------------------
    pushad
    call WriteString
    mov  edx, OFFSET buffer     ; 버퍼 출력
    call WriteString
    call Crlf
    call Crlf
    popad
    ret
DisplayMessage ENDP

;----------------------------------------------------
TranslateBuffer PROC
;
; Translates the string by exclusive-ORing each
; byte with the encryption key byte.
; Receives: nothing
; Returns: nothing
;----------------------------------------------------
    pushad
    mov ecx, bufSize            ; 루프 카운터
    mov esi, 0                  ; 버퍼의 인덱스 0
L1:
    xor buffer[esi], KEY        ; 바이트 하나 변환
    inc esi                     ; 다음 바이트를 가리킴
    loop L1
    popad
    ret
TranslateBuffer ENDP
END main
```

* 세 프로시저 모두 반환값이 없으므로 `PUSHAD / POPAD`로 레지스터 전체를 보존해도 문제없음.

---

## 6.4 조건 루프 명령어 (Conditional Loop Instructions)

### 1. LOOPZ / LOOPE 명령어

LOOP와 같지만 **Zero 플래그가 1이어야 한다**는 조건이 하나 더 있음. (LOOPE는 LOOPZ와 같은 명령어)

```assembly
LOOPZ destination
```

```
ECX = ECX - 1
if ECX > 0 and ZF = 1, jump to destination
```

---

### 2. LOOPNZ / LOOPNE 명령어

LOOPZ의 반대. ECX를 감소시킨 뒤 **ECX가 0보다 크고 Zero 플래그가 0인 동안** 반복함. (LOOPNE는 LOOPNZ와 같은 명령어)

```assembly
LOOPNZ destination
```

```
ECX = ECX - 1
if ECX > 0 and ZF = 0, jump to destination
```

---

### 3. 예제

#### ① LOOPNZ: 첫 번째 양수 찾기

부호 비트를 검사하며 음수인 동안 계속 반복함.

```assembly
.data
array    SWORD -3, -6, -1, -10, 10, 30, 40, 4
sentinel SWORD 0

.code
    mov esi, OFFSET array
    mov ecx, LENGTHOF array
next:
    test WORD PTR [esi], 8000h  ; 부호 비트 검사
    pushfd                      ; 플래그를 스택에 push
    add  esi, TYPE array
    popfd                       ; 스택에서 플래그 pop
    loopnz next                 ; 루프 계속
    jnz  quit                   ; 찾지 못함
    sub  esi, TYPE array        ; ESI가 찾은 값을 가리킴
quit:
```

#### ② LOOPE: 첫 번째 0이 아닌 값 찾기

```assembly
.data
array    SWORD 50 DUP(?)
sentinel SWORD 0FFFFh

.code
    mov esi, OFFSET array
    mov ecx, LENGTHOF array
L1: cmp WORD PTR [esi], 0
    pushfd
    add esi, TYPE array
    popfd
    loope L1
    jz  quit
    sub esi, TYPE array
quit:
```

* `add`가 플래그를 바꾸므로 **`pushfd / popfd`로 비교 결과 플래그를 보존**한 뒤 루프 조건을 검사함.
* 배열 뒤의 `sentinel`은 끝까지 찾지 못했을 때 루프를 안전하게 멈추게 하는 보초값.

---

## 6.5 조건 구조 (Conditional Structures)

### 1. 블록 구조 IF문 (Block-Structured IF Statements)

#### Example 1

```c
if( op1 == op2 )
{
    X = 1;
    Y = 2;
}
```

```assembly
    mov eax, op1
    cmp eax, op2        ; op1 == op2?
    jne L1              ; no: 다음을 건너뜀
    mov X, 1            ; yes: X와 Y에 대입
    mov Y, 2
L1:
```

같은 로직을 `je`로 작성할 수도 있지만 점프가 하나 더 필요함.

```assembly
    mov eax, op1
    cmp eax, op2        ; op1 == op2?
    je  L1              ; yes: L1로 점프
    jmp L2              ; no: 대입을 건너뜀
L1: mov X, 1            ; X와 Y에 대입
    mov Y, 2
L2:
```

→ **조건을 반대로 뒤집어서 점프**하면 코드가 더 짧아짐.

#### Example 2

```c
clusterSize = 8192;
if terrabytes < 16
    clusterSize = 4096;
```

```assembly
    mov clusterSize, 8192   ; 큰 클러스터라고 가정
    cmp terrabytes, 16      ; 16TB보다 작은가?
    jae next
    mov clusterSize, 4096   ; 작은 클러스터로 변경
next:
```

#### Example 3: IF-ELSE

```c
if op1 > op2
    call Routine1
else
    call Routine2
end if
```

```assembly
    mov  eax, op1       ; op1을 레지스터로 이동
    cmp  eax, op2       ; op1 > op2?
    jg   A1             ; yes: Routine1 호출
    call Routine2       ; no: Routine2 호출
    jmp  A2             ; IF문 종료
A1: call Routine1
A2:
```

---

### 2. 화이트 박스 테스트 (White Box Testing)

중첩 IF문의 **모든 실행 경로**를 테스트할 수 있도록 입력값을 정함.

```c
if op1 == op2
    if X > Y
        call Routine1
    else
        call Routine2
    end if
else
    call Routine3
end if
```

```assembly
1:      mov  eax, op1
2:      cmp  eax, op2       ; op1 == op2?
3:      jne  L2             ; no: Routine3 호출
; 안쪽 IF-ELSE문 처리
4:      mov  eax, X
5:      cmp  eax, Y         ; X > Y?
6:      jg   L1             ; yes: Routine1 호출
7:      call Routine2       ; no: Routine2 호출
8:      jmp  L3             ; 종료
9:  L1: call Routine1       ; Routine1 호출
10:     jmp  L3             ; 종료
11: L2: call Routine3
12: L3:
```

#### 중첩 IF문 테스트 (Table 6-6)

| op1 | op2 | X | Y | 실행되는 줄 순서 | 호출 |
| --- | --- | --- | --- | --- | --- |
| 10 | 20 | 30 | 40 | 1, 2, 3, 11, 12 | Routine3 |
| 10 | 20 | 40 | 30 | 1, 2, 3, 11, 12 | Routine3 |
| 10 | 10 | 30 | 40 | 1, 2, 3, 4, 5, 6, 7, 8, 12 | Routine2 |
| 10 | 10 | 40 | 30 | 1, 2, 3, 4, 5, 6, 9, 10, 12 | Routine1 |

---

### 3. 복합 표현식 (Compound Expressions)

#### ① 논리 AND 연산자 (Logical AND Operator)

```c
if (al > bl) AND (bl > cl)
    X = 1
end if
```

```assembly
    cmp al, bl         ; 첫 번째 표현식...
    ja  L1
    jmp next
L1: cmp bl, cl         ; 두 번째 표현식...
    ja  L2
    jmp next
L2: mov X, 1           ; 둘 다 참: X = 1
next:
```

조건을 반대로 뒤집으면 더 간단해짐. (**단락 평가, short-circuit evaluation**: 첫 조건이 거짓이면 바로 종료)

```assembly
    cmp al, bl         ; 첫 번째 표현식...
    jbe next           ; 거짓이면 종료
    cmp bl, cl         ; 두 번째 표현식
    jbe next           ; 거짓이면 종료
    mov X, 1           ; 둘 다 참
next:
```

#### ② 논리 OR 연산자 (Logical OR Operator)

```c
if (al > bl) OR (bl > cl)
    X = 1
```

```assembly
    cmp al, bl         ; 1: AL과 BL 비교
    ja  L1             ; 참이면 두 번째 표현식은 건너뜀
    cmp bl, cl         ; 2: BL과 CL 비교
    jbe next           ; 거짓: 다음 문장을 건너뜀
L1: mov X, 1           ; 참: X = 1
next:
```

---

### 4. WHILE 루프 (WHILE Loops)

```c
while( val1 < val2 )
{
    val1++;
    val2--;
}
```

```assembly
    mov eax, val1       ; 변수를 EAX로 복사
beginwhile:
    cmp eax, val2       ; not (val1 < val2) 이면
    jnl endwhile        ;   루프 종료
    inc eax             ; val1++;
    dec val2            ; val2--;
    jmp beginwhile      ; 루프 반복
endwhile:
    mov val1, eax       ; val1에 새 값 저장
```

#### 예제: IF문을 포함한 루프 (Loop containing IF statement)

```c
int array[] = {10,60,20,33,72,89,45,65,72,18};
int sample = 50;
int ArraySize = sizeof array / sizeof sample;
int index = 0;
int sum = 0;
while( index < ArraySize )
{
    if( array[index] > sample )
    {
        sum += array[index];
    }
    index++;
}
```

```assembly
.data
sum       DWORD 0
sample    DWORD 50
array     DWORD 10,60,20,33,72,89,45,65,72,18
ArraySize = ($ - array) / TYPE array

.code
main PROC
    mov eax, 0              ; sum
    mov edx, sample
    mov esi, 0              ; index
    mov ecx, ArraySize
L1: cmp esi, ecx            ; if esi < ecx
    jl  L2
    jmp L5
L2: cmp array[esi*4], edx   ; if array[esi] > edx
    jg  L3
    jmp L4
L3: add eax, array[esi*4]
L4: inc esi
    jmp L1
L5: mov sum, eax
```

* 슬라이드에는 `($ - Array)`로 되어 있지만, Irvine32.inc를 쓰면 대소문자를 구분(`casemap:none`)하므로 `array`로 써야 함.

#### 흐름도 (Figure 6-1)

```
            Begin
              │
   eax = sum, edx = sample
   esi = index, ecx = ArraySize
              │
  ┌─────────▶ L1: esi < ecx? ──FALSE──▶ L5: sum = eax ──▶ end
  │               │ TRUE
  │           L2: array[esi] > edx?
  │            TRUE │        │ FALSE
  │       L3: eax += array[esi]   │
  │                 │        │
  │                 └── L4 ◀─┘
  │                     │
  │                  inc esi
  └─────────────────────┘
```

---

### 5. 테이블 기반 선택 (Table-Driven Selection)

**테이블 조회로 다중 선택 구조(switch 등)를 대체**하는 방법.
조회 값과 레이블/프로시저의 오프셋을 담은 테이블을 만들고, 루프로 테이블을 검색함.

```assembly
.data
CaseTable BYTE  'A'             ; 조회 값
          DWORD Process_A       ; 프로시저 주소
          BYTE  'B'
          DWORD Process_B
          (etc.)
```

#### 프로시저 오프셋 테이블 (Figure 6-2)

| 'A' | 00000120 | 'B' | 00000130 | 'C' | 00000140 | 'D' | 00000150 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 조회 값 | Process_A 주소 | 조회 값 | Process_B 주소 | 조회 값 | Process_C 주소 | 조회 값 | Process_D 주소 |

#### 예제 (ProcTable.asm)

```assembly
; Table of Procedure Offsets (ProcTable.asm)
; This program contains a table with offsets of procedures.
; It uses the table to execute indirect procedure calls.

INCLUDE Irvine32.inc

.data
CaseTable BYTE  'A'                 ; 조회 값
          DWORD Process_A           ; 프로시저 주소
EntrySize = ($ - CaseTable)         ; 항목 하나의 크기 = 5바이트
          BYTE  'B'
          DWORD Process_B
          BYTE  'C'
          DWORD Process_C
          BYTE  'D'
          DWORD Process_D
NumberOfEntries = ($ - CaseTable) / EntrySize

prompt BYTE "Press capital A,B,C,or D: ",0
msgA   BYTE "Process_A",0
msgB   BYTE "Process_B",0
msgC   BYTE "Process_C",0
msgD   BYTE "Process_D",0

.code
main PROC
    mov  edx, OFFSET prompt         ; 사용자 입력 요청
    call WriteString
    call ReadChar                   ; 문자를 AL로 읽음
    mov  ebx, OFFSET CaseTable      ; EBX가 테이블을 가리킴
    mov  ecx, NumberOfEntries       ; 루프 카운터
L1:
    cmp  al, [ebx]                  ; 일치하는가?
    jne  L2                         ; no: 계속
    call NEAR PTR [ebx + 1]         ; yes: 프로시저 호출
    call WriteString                ; 메시지 출력
    call Crlf
    jmp  L3                         ; 검색 종료
L2:
    add  ebx, EntrySize             ; 다음 항목을 가리킴
    loop L1                         ; ECX = 0이 될 때까지 반복
L3:
    exit
main ENDP

Process_A PROC
    mov edx, OFFSET msgA
    ret
Process_A ENDP

Process_B PROC
    mov edx, OFFSET msgB
    ret
Process_B ENDP

Process_C PROC
    mov edx, OFFSET msgC
    ret
Process_C ENDP

Process_D PROC
    mov edx, OFFSET msgD
    ret
Process_D ENDP
END main
```

* `call NEAR PTR [ebx + 1]`: 조회 값(1바이트) 바로 뒤에 저장된 프로시저 주소로 **간접 호출**함.

---

## 6.7 조건 제어 흐름 지시어 (Conditional Control Flow Directives)

32비트 모드에서 MASM은 조건문 작성을 쉽게 해주는 **고급 조건 제어 흐름 지시어**를 제공함. **64비트 모드에서는 사용할 수 없음.**

### 1. 지시어 목록 (Table 6-7)

| 지시어 | 설명 |
| --- | --- |
| **.BREAK** | .WHILE 또는 .REPEAT 블록을 종료하는 코드 생성 |
| **.CONTINUE** | .WHILE 또는 .REPEAT 블록의 맨 위로 점프하는 코드 생성 |
| **.ELSE** | .IF 조건이 거짓일 때 실행할 문장 블록 시작 |
| **.ELSEIF** *condition* | condition을 검사하여 다음 .ENDIF 또는 .ELSEIF까지의 문장을 실행하는 코드 생성 |
| **.ENDIF** | .IF, .ELSE, .ELSEIF 다음의 문장 블록 종료 |
| **.ENDW** | .WHILE 다음의 문장 블록 종료 |
| **.IF** *condition* | condition이 참이면 문장 블록을 실행하는 코드 생성 |
| **.REPEAT** | condition이 참이 될 때까지 문장 블록을 반복하는 코드 생성 |
| **.UNTIL** *condition* | condition이 참이 될 때까지 .REPEAT와 .UNTIL 사이의 블록을 반복 |
| **.UNTILCXZ** | CX가 0이 될 때까지 .REPEAT와 .UNTILCXZ 사이의 블록을 반복 |
| **.WHILE** *condition* | condition이 참인 동안 .WHILE과 .ENDW 사이의 블록을 실행 |

---

### 2. IF문 만들기 (Creating IF Statements)

`.IF`, `.ELSE`, `.ELSEIF`, `.ENDIF`로 다중 분기 로직을 쉽게 작성할 수 있음.

```assembly
.IF condition1
    statements
[.ELSEIF condition2
    statements ]
[.ELSE
    statements ]
.ENDIF
```

#### 런타임 관계/논리 연산자 (Table 6-8)

| 연산자 | 설명 |
| --- | --- |
| `expr1 == expr2` | expr1과 expr2가 같으면 참 |
| `expr1 != expr2` | expr1과 expr2가 다르면 참 |
| `expr1 > expr2` | expr1이 expr2보다 크면 참 |
| `expr1 >= expr2` | expr1이 expr2보다 크거나 같으면 참 |
| `expr1 < expr2` | expr1이 expr2보다 작으면 참 |
| `expr1 <= expr2` | expr1이 expr2보다 작거나 같으면 참 |
| `! expr` | expr이 거짓이면 참 |
| `expr1 && expr2` | expr1과 expr2의 논리 AND |
| `expr1 \|\| expr2` | expr1과 expr2의 논리 OR |
| `expr1 & expr2` | expr1과 expr2의 비트 AND |
| `CARRY?` | Carry 플래그가 set이면 참 |
| `OVERFLOW?` | Overflow 플래그가 set이면 참 |
| `PARITY?` | Parity 플래그가 set이면 참 |
| `SIGN?` | Sign 플래그가 set이면 참 |
| `ZERO?` | Zero 플래그가 set이면 참 |

---

### 3. 생성되는 어셈블리 코드 (Generating ASM Code)

어셈블러는 `.IF` 지시어를 CMP와 조건 점프로 변환함.

```assembly
.data
val1   DWORD 5
result DWORD ?

.code
    mov eax, 6
    .IF eax > val1
        mov result, 1
    .ENDIF
```

위 코드는 아래와 같이 변환됨:

```assembly
    mov eax, 6
    cmp eax, val1
    jbe @C0001              ; 부호 없는 비교로 점프
    mov result, 1
@C0001:
```

* `val1`이 `DWORD`(부호 없음)이므로 **부호 없는 비교 점프(JBE)** 가 생성됨.

#### 레지스터끼리 비교 (Comparing Registers)

```assembly
mov eax, 6
mov ebx, val2
.IF eax > ebx
    mov result, 1
.ENDIF
```

```assembly
    mov eax, 6
    mov ebx, val2
    cmp eax, ebx
    jbe @C0001
    mov result, 1
@C0001:
```

* 레지스터끼리 비교할 때는 부호 여부를 알 수 없으므로 **기본적으로 부호 없는 비교**로 처리됨.

---

### 4. 복합 표현식 (Compound Expressions)

```assembly
.IF expression1 || expression2
    statements
.ENDIF

.IF expression1 && expression2
    statements
.ENDIF
```

---

### 5. .REPEAT와 .WHILE로 루프 만들기 (Creating Loops with .REPEAT and .WHILE)

```assembly
.REPEAT                     .WHILE condition
    statements                  statements
.UNTIL condition            .ENDW
```

* **.REPEAT**: 본문을 먼저 실행한 뒤 조건을 검사 (최소 1번 실행).
* **.WHILE**: 조건을 먼저 검사한 뒤 본문을 실행 (조건이 처음부터 거짓이면 0번 실행).

1부터 10까지 출력하는 두 가지 방법:

```assembly
; .REPEAT 사용
mov eax, 0
.REPEAT
    inc  eax
    call WriteDec
    call Crlf
.UNTIL eax == 10
```

```assembly
; .WHILE 사용
mov eax, 0
.WHILE eax < 10
    inc  eax
    call WriteDec
    call Crlf
.ENDW
```

---

### 6. 예제: IF문을 포함한 루프 (Loop Containing an IF Statement)

```c
while( op1 < op2 )
{
    op1++;
    if( op1 == op3 )
        X = 2;
    else
        X = 3;
}
```

```assembly
.data
X   DWORD 0
op1 DWORD 2                 ; 테스트 데이터
op2 DWORD 4                 ; 테스트 데이터
op3 DWORD 5                 ; 테스트 데이터

.code
    mov eax, op1
    mov ebx, op2
    mov ecx, op3
    .WHILE eax < ebx
        inc eax
        .IF eax == ecx
            mov X, 2
        .ELSE
            mov X, 3
        .ENDIF
    .ENDW
```

---

## 6.8 주요 요약 및 학습 키워드 (Key Terms)

* **AND / OR / XOR / NOT**: 비트 단위 불리언 연산. AND·OR·XOR는 항상 CF, OF를 0으로 지우고 SF, ZF, PF를 변경. NOT은 플래그에 영향 없음.

* **Bit Mask**: AND로 특정 비트를 지우고(clear), OR로 특정 비트를 설정(set)하고, XOR로 특정 비트를 반전.

* **Bit-Mapped Sets**: 비트 하나를 집합 원소 하나로 사용. AND = 교집합, OR = 합집합, NOT = 여집합.

* **TEST**: destination을 바꾸지 않는 AND. 특정 비트가 1인지 검사할 때 사용.

* **CMP**: destination을 바꾸지 않는 SUB. 부호 없는 비교는 ZF·CF, 부호 있는 비교는 SF·OF·ZF로 판단.

* **Jcond**: 플래그 조건이 참이면 점프. 플래그 기준(JZ, JC, JO, JS, JP), 같음 기준(JE, JNE, JECXZ), 부호 없는 비교(JA, JB), 부호 있는 비교(JG, JL)로 구분.

* **LOOPZ(LOOPE) / LOOPNZ(LOOPNE)**: ECX 감소 후 ECX > 0 이고 ZF = 1(또는 0)일 때만 반복.

* **Block-Structured IF / Compound Expressions / WHILE**: 조건을 반대로 뒤집은 점프로 고급 언어의 제어 구조를 구현. AND/OR는 단락 평가.

* **White Box Testing**: 모든 실행 경로를 지나가도록 테스트 입력을 구성.

* **Table-Driven Selection**: 조회 값과 프로시저 주소의 테이블로 다중 분기를 대체.

* **.IF / .ELSEIF / .ELSE / .ENDIF, .WHILE / .ENDW, .REPEAT / .UNTIL**: MASM 32비트 전용 조건 제어 흐름 지시어. 어셈블러가 CMP + 조건 점프로 변환.

