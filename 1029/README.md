# 1029

## 7.1 시프트와 회전 명령어 (Shift and Rotate Instructions)

### 1. 명령어 목록 (Table 7-1)

| 명령어 | 설명 |
| --- | --- |
| **SHL** | Shift left (논리 왼쪽 시프트) |
| **SHR** | Shift right (논리 오른쪽 시프트) |
| **SAL** | Shift arithmetic left (산술 왼쪽 시프트) |
| **SAR** | Shift arithmetic right (산술 오른쪽 시프트) |
| **ROL** | Rotate left (왼쪽 회전) |
| **ROR** | Rotate right (오른쪽 회전) |
| **RCL** | Rotate carry left (Carry 포함 왼쪽 회전) |
| **RCR** | Rotate carry right (Carry 포함 오른쪽 회전) |
| **SHLD** | Double-precision shift left (배정밀도 왼쪽 시프트) |
| **SHRD** | Double-precision shift right (배정밀도 오른쪽 시프트) |

---

### 2. 논리 시프트와 산술 시프트 (Logical Shifts and Arithmetic Shifts)

#### ① 논리 시프트 (logical shift)

비어 있는 비트 자리를 **0으로 채움**. 밀려나는 비트는 Carry 플래그(CF)로 들어감.

```
0 → [■ → ■ → ■ → ■ → ■ → ■ → ■ → ■] → CF

    1 1 0 0 1 1 1 1  → (cf) = 1
    ↘ ↘ ↘ ↘ ↘ ↘ ↘
→ 0 1 1 0 0 1 1 1
```

#### ② 산술 시프트 (arithmetic shift)

비어 있는 비트 자리를 **원래 수의 부호 비트(MSB)로 채움** → 부호가 유지됨.

```
┌→[■ → ■ → ■ → ■ → ■ → ■ → ■ → ■] → CF
└──┘ (MSB 복사)

    1 1 0 0 1 1 1 1  → (cf) = 1
    ↓ ↘ ↘ ↘ ↘ ↘ ↘ ↘
    1 1 1 0 0 1 1 1
```

---

### 3. SHL 명령어

destination 피연산자를 **논리 왼쪽 시프트**하고, **최하위 비트를 0으로 채움**. 최상위 비트는 CF로 이동.

```assembly
SHL destination, count

SHL reg, imm8
SHL mem, imm8
SHL reg, CL
SHL mem, CL
```

```
CF ← [■ ← ■ ← ■ ← ■ ← ■ ← ■ ← ■ ← ■] ← 0

(cf) ← 1 1 0 0 1 1 1 1
        ↙ ↙ ↙ ↙ ↙ ↙ ↙
       1 0 0 1 1 1 1 0 ← 0
```

```assembly
mov bl, 8Fh             ; BL = 10001111b
shl bl, 1               ; CF = 1, BL = 00011110b

mov al, 10000000b
shl al, 2               ; CF = 0, AL = 00000000b
```

#### 활용: 비트 단위 곱셈 (Bitwise Multiplication)

**n비트 왼쪽 시프트 = 2ⁿ 곱하기**.

```assembly
mov dl, 5               ; before: 00000101 = 5
shl dl, 1               ; after:  00001010 = 10

mov dl, 10              ; before: 00001010
shl dl, 2               ; after:  00101000 (= 40)
```

---

### 4. SHR 명령어

destination 피연산자를 **논리 오른쪽 시프트**하고, **최상위 비트를 0으로 채움**. 최하위 비트는 CF로 이동.

```
0 → [■ → ■ → ■ → ■ → ■ → ■ → ■ → ■] → CF
```

```assembly
mov al, 0D0h            ; AL = 11010000b
shr al, 1               ; AL = 01101000b, CF = 0

mov al, 00000010b
shr al, 2               ; AL = 00000000b, CF = 1
```

#### 활용: 비트 단위 나눗셈 (Bitwise Division)

**n비트 오른쪽 시프트 = 2ⁿ 으로 나누기** (부호 없는 수).

```assembly
mov dl, 32              ; before: 00100000 = 32
shr dl, 1               ; after:  00010000 = 16

mov al, 01000000b       ; AL = 64
shr al, 3               ; 8로 나누기, AL = 00001000b
```

---

### 5. SAL과 SAR 명령어

* **SAL** (shift arithmetic left): **SHL과 완전히 동일**하게 동작함.
* **SAR** (shift arithmetic right): 오른쪽으로 시프트하면서 **부호 비트(MSB)를 복사**해 채움.

```
SAL:  CF ← [■ ← ■ ← ■ ← ■ ← ■ ← ■ ← ■ ← ■] ← 0

SAR:  ┌→[■ → ■ → ■ → ■ → ■ → ■ → ■ → ■] → CF
      └──┘
```

```assembly
SAR destination, count

mov al, 0F0h            ; AL = 11110000b (-16)
sar al, 1               ; AL = 11111000b (-8), CF = 0
```

#### 활용 ①: 부호 있는 나눗셈 (Signed Division)

```assembly
mov dl, -128            ; DL = 10000000b
sar dl, 3               ; DL = 11110000b (-16)
```

#### 활용 ②: AX를 EAX로 부호 확장 (Sign-Extend AX into EAX)

```assembly
mov ax, -128            ; EAX = ????FF80h
shl eax, 16             ; EAX = FF800000h
sar eax, 16             ; EAX = FFFFFF80h
```

---

### 6. ROL 명령어

각 비트를 왼쪽으로 이동시키고, **최상위 비트를 CF와 최하위 비트 자리에 복사**함.
**비트 회전은 비트를 잃지 않음 (Bit rotation does not lose bits).**

```
CF ← [■ ← ■ ← ■ ← ■ ← ■ ← ■ ← ■ ← ■] ←┐
       └───────────────────────────────┘
```

```assembly
mov al, 40h             ; AL = 01000000b
rol al, 1               ; AL = 10000000b, CF = 0
rol al, 1               ; AL = 00000001b, CF = 1
rol al, 1               ; AL = 00000010b, CF = 0
```

#### 활용: 비트 그룹 교환 (Exchanging Groups of Bits)

4비트씩 회전하면 16진수 한 자리(nybble)씩 순환함.

```assembly
mov ax, 6A4Bh
rol ax, 4               ; AX = A4B6h
rol ax, 4               ; AX = 4B6Ah
rol ax, 4               ; AX = B6A4h
rol ax, 4               ; AX = 6A4Bh
```

---

### 7. ROR 명령어

각 비트를 오른쪽으로 이동시키고, **최하위 비트를 CF와 최상위 비트 자리에 복사**함.

```
┌→[■ → ■ → ■ → ■ → ■ → ■ → ■ → ■] → CF
└──────────────────────────────┘
```

```assembly
mov al, 01h             ; AL = 00000001b
ror al, 1               ; AL = 10000000b, CF = 1
ror al, 1               ; AL = 01000000b, CF = 0

mov al, 00000100b
ror al, 3               ; AL = 10000000b, CF = 1
```

---

### 8. RCL과 RCR 명령어

CF를 **회전 고리의 한 비트처럼 포함**하여 회전함.

| 명령어 | 동작 |
| --- | --- |
| **RCL** | 각 비트를 왼쪽으로 이동, **CF → LSB**, **MSB → CF** |
| **RCR** | 각 비트를 오른쪽으로 이동, **CF → MSB**, **LSB → CF** |

```
RCL:  ┌ CF ← [■ ← ■ ← ■ ← ■ ← ■ ← ■ ← ■ ← ■] ←┐
      └──────────────────────────────────────────┘

RCR:  ┌→[■ → ■ → ■ → ■ → ■ → ■ → ■ → ■] → CF ┐
      └──────────────────────────────────────────┘
```

```assembly
clc                     ; CF = 0
mov bl, 88h             ; CF,BL = 0 10001000b
rcl bl, 1               ; CF,BL = 1 00010000b
rcl bl, 1               ; CF,BL = 0 00100001b

stc                     ; CF = 1
mov ah, 10h             ; AH, CF = 00010000 1
rcr ah, 1               ; AH, CF = 10001000 0
```

---

### 9. 부호 있는 오버플로 (Signed Overflow)

부호 있는 정수를 **1비트** 시프트/회전한 결과가 destination의 **부호 있는 정수 범위를 벗어나면 OF가 1**이 됨.

```assembly
mov al, +127            ; AL = 01111111b
rol al, 1               ; OF = 1, AL = 11111110b

mov al, -128            ; AL = 10000000b
shr al, 1               ; OF = 1, AL = 01000000b
```

* **시프트/회전 횟수가 1보다 크면 OF 값은 정의되지 않음(undefined).**

---

### 10. SHLD / SHRD 명령어

| 명령어 | 동작 |
| --- | --- |
| **SHLD** | destination을 왼쪽으로 count만큼 시프트하고, 빈 자리를 **source의 최상위 비트들**로 채움 |
| **SHRD** | destination을 오른쪽으로 count만큼 시프트하고, 빈 자리를 **source의 최하위 비트들**로 채움 |

```assembly
SHLD dest, source, count
SHRD dest, source, count

SHLD reg16, reg16, CL/imm8
SHLD mem16, reg16, CL/imm8
SHLD reg32, reg32, CL/imm8
SHLD mem32, reg32, CL/imm8
```

* **source 피연산자는 변경되지 않음.** 단, Sign, Zero, Auxiliary, Parity, Carry 플래그는 영향을 받음.

#### SHLD 동작 (count = 1)

```
Destination: 1 1 1 0 0 0 0 0      Source: 1 0 0 1 1 1 0 1
             ↓(→CF=1)                     ↓ (MSB)
Destination: 1 1 0 0 0 0 0 1  ← 빈 자리를 source의 MSB로 채움
```

#### SHRD 동작 (count = 1)

```
Source: 0 0 0 1 1 1 0 1      Destination: 1 1 0 0 0 0 0 1
                      ↓ (LSB)                           ↓(→CF=1)
Destination: 1 1 1 0 0 0 0 0  ← 빈 자리를 source의 LSB로 채움
```

#### Example 1: SHLD

```assembly
.data
wval WORD 9BA6h
.code
mov  ax, 0AC36h
shld wval, ax, 4        ; wval = BA6Ah
```

```
wval        AX
9BA6  ←    AC36
BA6A       AC36     ← wval을 4비트 왼쪽으로, 빈 자리는 AX의 상위 4비트(A)로 채움
```

#### Example 2: SHRD

```assembly
mov  ax, 234Bh
mov  dx, 7654h
shrd ax, dx, 4          ; AX = 4234h
```

```
DX      AX
7654    234B  →
7654    4234        ← AX를 4비트 오른쪽으로, 빈 자리는 DX의 하위 4비트(4)로 채움
```

#### Example 3: 더블워드 배열 전체를 4비트 오른쪽 시프트 (Explain the program below)

```assembly
.data
array DWORD 648B2165h, 8C943A29h, 6DFA4B86h, 91F76C04h, 8BAF9857h

.code
    mov bl, 4                       ; 시프트 횟수
    mov esi, OFFSET array           ; 배열의 오프셋
    mov ecx, (LENGTHOF array) - 1   ; 배열 원소 개수 - 1

L1: push ecx                        ; 루프 카운터 저장
    mov  eax, [esi + TYPE DWORD]    ; 다음 원소를 EAX에
    mov  cl, bl                     ; 시프트 횟수
    shrd [esi], eax, cl             ; EAX의 하위 비트를 [ESI]의 상위 비트로 시프트
    add  esi, TYPE DWORD            ; 다음 더블워드 쌍을 가리킴
    pop  ecx                        ; 루프 카운터 복원
    loop L1

    shr DWORD PTR [esi], COUNT      ; 마지막 더블워드 시프트
```

**설명**

* 5개의 DWORD 배열을 **하나의 160비트 정수**(array[0]이 최하위)로 보고, 전체를 **4비트 오른쪽으로 시프트**하는 프로그램.
* 루프는 `LENGTHOF array - 1 = 4`번 반복함. ECX를 push/pop하는 이유는 루프 안에서 CL(= ECX의 하위 바이트)을 시프트 횟수로 사용하기 때문.
* 각 반복에서 `SHRD [esi], eax, cl`은 현재 원소를 4비트 오른쪽으로 밀고, 빈 상위 4비트를 **다음 원소(EAX)의 하위 4비트**로 채움 → 원소 경계를 넘어 비트가 이어짐.
* 마지막 원소는 그 뒤에 이어질 원소가 없으므로 `SHR`로 시프트하여 상위 비트를 0으로 채움. (`COUNT`는 시프트 횟수 4를 나타내는 상수)
* 실행 결과:

```
before: 648B2165h, 8C943A29h, 6DFA4B86h, 91F76C04h, 8BAF9857h
after:  9648B216h, 68C943A2h, 46DFA4B8h, 791F76C0h, 08BAF985h
```

---

## 7.2 시프트와 회전 응용 (Shift and Rotate Applications)

### 1. 여러 바이트/더블워드 시프트 (Shifting Multiple Doublewords)

바이트 배열 전체를 1비트 오른쪽으로 시프트하는 방법. **최상위 바이트는 SHR**, 나머지는 **RCR로 CF를 이어받아** 시프트함.

```assembly
.data
ArraySize = 3
array BYTE ArraySize DUP(99h)       ; 각 nybble이 1001 패턴

.code
main PROC
    mov esi, 0
    shr array[esi+2], 1             ; 상위 바이트
    rcr array[esi+1], 1             ; 중간 바이트, Carry 포함
    rcr array[esi], 1               ; 하위 바이트, Carry 포함
```

| 단계 | [esi+2] | [esi+1] | [esi] | CF |
| --- | --- | --- | --- | --- |
| **시작값** | 10011001 | 10011001 | 10011001 | - |
| **Step 1** (SHR) | 01001100 | 10011001 | 10011001 | 1 |
| **Step 2** (RCR) | 01001100 | 11001100 | 10011001 | 1 |
| **Step 3** (RCR) | 01001100 | 11001100 | 11001100 | 1 |

→ Step 3이 끝나면 **모든 비트가 1자리씩 오른쪽으로 시프트**됨.

---

### 2. 이진 곱셈 (Binary Multiplication)

곱하는 수를 2의 거듭제곱의 합으로 분해하여 **SHL + ADD**로 곱셈을 구현함.

```
EAX * 36 = EAX * (2⁵ + 2²)
         = EAX * (32 + 4)
         = (EAX * 32) + (EAX * 4)
```

```
           0 1 1 1 1 0 1 1     123
     ×     0 0 1 0 0 1 0 0      36
     ---------------------
         0 1 1 1 1 0 1 1       123 SHL 2
   + 0 1 1 1 1 0 1 1           123 SHL 5
     ---------------------
   0 0 0 1 0 0 0 1 0 1 0 0 1 1 0 0    4428
```

```assembly
mov eax, 123
mov ebx, eax
shl eax, 5              ; 2⁵ 곱하기
shl ebx, 2              ; 2² 곱하기
add eax, ebx            ; 두 곱을 더함
```

---

### 3. 이진 비트 출력 (Displaying Binary Bits)

이진 정수를 **ASCII 이진 문자열**로 변환하여 화면에 출력할 수 있게 만드는 작업.

```assembly
;--------------------------------------------------------
BinToAsc PROC
;
; 32비트 이진 정수를 ASCII 이진 문자열로 변환
; Receives: EAX = 이진 정수, ESI = 버퍼 주소
; Returns: ASCII 이진 숫자로 채워진 버퍼
;--------------------------------------------------------
    push ecx
    push esi
    mov  ecx, 32                    ; EAX의 비트 수
L1: shl  eax, 1                     ; 최상위 비트를 CF로 시프트
    mov  BYTE PTR [esi], '0'        ; 기본값 '0'
    jnc  L2                         ; Carry가 없으면 L2로
    mov  BYTE PTR [esi], '1'        ; Carry가 있으면 '1'
L2: inc  esi                        ; 다음 버퍼 위치
    loop L1                         ; 다음 비트
    pop  esi
    pop  ecx
    ret
BinToAsc ENDP
```

---

### 4. 파일 날짜 필드 추출 (Extracting File Date Fields)

파일이 **1999년 3월 10일**에 마지막으로 수정되었다면, DX 레지스터의 날짜 스탬프는 아래와 같음 (연도는 **1980년 기준** 상대값).

```
        DH                DL
0 0 1 0 0 1 1 | 0 0 1 1 | 0 1 0 1 0
└── Year ───┘   └Month┘   └─ Day ─┘
   bit 9-15     bit 5-8    bit 0-4
   (19+1980)      (3)        (10)
```

```assembly
mov al, dl              ; DL 복사
and al, 00011111b       ; 비트 5-7 지우기
mov day, al             ; day에 저장

mov ax, dx              ; DX 복사
shr ax, 5               ; 오른쪽으로 5비트 시프트
and al, 00001111b       ; 비트 4-7 지우기
mov month, al           ; month에 저장

mov al, dh              ; DH 복사
shr al, 1               ; 오른쪽으로 1비트 시프트
mov ah, 0               ; AH를 0으로
add ax, 1980            ; 연도는 1980 기준
mov year, ax            ; year에 저장
```

---

## 7.3 곱셈과 나눗셈 명령어 (Multiplication and Division Instructions)

### 1. MUL 명령어

**부호 없는 정수 곱셈**. 피승수(multiplicand)와 승수(multiplier)는 **항상 같은 크기**이고, 곱(product)은 **그 2배 크기**.

```assembly
MUL reg/mem8
MUL reg/mem16
MUL reg/mem32
```

#### MUL 피연산자 (Table 7-2)

| Multiplicand | Multiplier | Product |
| --- | --- | --- |
| AL | reg/mem8 | AX |
| AX | reg/mem16 | DX:AX |
| EAX | reg/mem32 | EDX:EAX |

* **곱의 상위 절반이 0이 아니면 CF = 1** → MUL 후 CF를 확인하면 **상위 절반을 무시해도 되는지** 알 수 있음.

#### MUL 예제

```assembly
mov al, 5h
mov bl, 10h
mul bl                  ; AX = 0050h, CF = 0
```

```
 AL      BL        AX     CF
[05] × [10]  →  [0050]   [0]
```

```assembly
.data
val1 WORD 2000h
val2 WORD 0100h
.code
mov ax, val1            ; AX = 2000h
mul val2                ; DX:AX = 00200000h, CF = 1
```

```
 AX       BX          DX     AX      CF
[2000] × [0100]  →  [0020 | 0000]   [1]
```

```assembly
mov eax, 12345h
mov ebx, 1000h
mul ebx                 ; EDX:EAX = 0000000012345000h, CF = 0
```

```
  EAX          EBX              EDX        EAX        CF
[00012345] × [00001000]  →  [00000000 | 12345000]    [0]
```

---

### 2. IMUL 명령어

**부호 있는 정수 곱셈**을 수행함. 1, 2, 3 피연산자 형식이 있음.

#### ① 1 피연산자 형식 (Single-Operand Formats)

곱을 **AX, DX:AX, EDX:EAX**에 저장함 (MUL과 동일한 구조).

```assembly
IMUL reg/mem8           ; AX = AL * reg/mem8
IMUL reg/mem16          ; DX:AX = AX * reg/mem16
IMUL reg/mem32          ; EDX:EAX = EAX * reg/mem32
```

#### ② 2 피연산자 형식 (Two-Operand Formats, 32-Bit Mode)

```assembly
IMUL reg16, reg/mem16       IMUL reg32, reg/mem32
IMUL reg16, imm8            IMUL reg32, imm8
IMUL reg16, imm16           IMUL reg32, imm32
```

* 곱을 **destination 크기로 잘라냄(truncate)**. 유효 숫자가 손실되면 **OF와 CF가 1**이 됨 → 반드시 확인할 것.

#### ③ 3 피연산자 형식 (Three-Operand Formats)

```assembly
IMUL reg16, reg/mem16, imm8     IMUL reg32, reg/mem32, imm8
IMUL reg16, reg/mem16, imm16    IMUL reg32, reg/mem32, imm32
```

* 유효 숫자가 손실되면 **OF와 CF가 1**이 됨 → 반드시 확인할 것.

#### IMUL 예제 (1 피연산자)

```assembly
mov  al, 48
mov  bl, 4
imul bl                 ; AX = 00C0h, OF = 1  (192는 AL에 부호 있는 값으로 안 들어감)

mov  al, -4
mov  bl, 4
imul bl                 ; AX = FFF0h, OF = 0

mov  ax, 48
mov  bx, 4
imul bx                 ; DX:AX = 000000C0h, OF = 0

mov  eax, +4823424
mov  ebx, -423
imul ebx                ; EDX:EAX = FFFFFFFF86635D80h, OF = 0
```

#### IMUL 예제 (2 피연산자)

```assembly
.data
word1  SWORD 4
dword1 SDWORD 4
.code
mov  ax, -16            ; AX = -16
mov  bx, 2              ; BX = 2
imul bx, ax             ; BX = -32
imul bx, 2              ; BX = -64
imul bx, word1          ; BX = -256
mov  eax, -16           ; EAX = -16
mov  ebx, 2             ; EBX = 2
imul ebx, eax           ; EBX = -32
imul ebx, 2             ; EBX = -64
imul ebx, dword1        ; EBX = -256

mov  ax, -32000
imul ax, 2              ; OF = 1
```

#### IMUL 예제 (3 피연산자)

```assembly
.data
word1  SWORD 4
dword1 SDWORD 4
.code
imul bx, word1, -16             ; BX = word1 * -16
imul ebx, dword1, -16           ; EBX = dword1 * -16
imul ebx, dword1, -2000000000   ; 부호 있는 오버플로!
```

* 2·3 피연산자 IMUL은 destination이 **승수와 같은 크기**이므로 부호 있는 오버플로가 발생할 수 있음 → **항상 OF를 확인**할 것.

---

### 3. 프로그램 실행 시간 측정 (Measuring Program Execution Times)

`GetMseconds`(Irvine32)로 시작/종료 시각을 구해 차이를 계산함.

```assembly
.data
startTime DWORD ?
procTime1 DWORD ?
procTime2 DWORD ?
.code
call GetMseconds            ; 시작 시각
mov  startTime, eax
.
call FirstProcedureToTest
.
call GetMseconds            ; 종료 시각
sub  eax, startTime         ; 경과 시간 계산
mov  procTime1, eax         ; 경과 시간 저장
```

---

### 4. DIV 명령어

**부호 없는 정수 나눗셈**.

```assembly
DIV reg/mem8
DIV reg/mem16
DIV reg/mem32
```

| Dividend | Divisor | Quotient | Remainder |
| --- | --- | --- | --- |
| AX | reg/mem8 | AL | AH |
| DX:AX | reg/mem16 | AX | DX |
| EDX:EAX | reg/mem32 | EAX | EDX |

#### DIV 예제

```assembly
mov ax, 0083h           ; 피제수
mov bl, 2               ; 제수
div bl                  ; AL = 41h (몫), AH = 01h (나머지)
```

```
 AX      BL       AL     AH
[0083] / [02]  → [41]   [01]
                 몫     나머지
```

```assembly
mov dx, 0               ; 피제수 상위 지우기
mov ax, 8003h           ; 피제수 하위
mov cx, 100h            ; 제수
div cx                  ; AX = 0080h, DX = 0003h
```

```
 DX     AX       CX        AX      DX
[0000 | 8003] / [0100] → [0080]  [0003]
```

```assembly
.data
dividend QWORD 0000000800300020h
divisor  DWORD 00000100h
.code
mov edx, DWORD PTR dividend + 4     ; 상위 더블워드
mov eax, DWORD PTR dividend         ; 하위 더블워드
div divisor                         ; EAX = 08003000h, EDX = 00000020h
```

```
   EDX        EAX         Divisor        EAX          EDX
[00000008 | 00300020] / [00000100] → [08003000]  [00000020]
```

---

### 5. 부호 있는 정수 나눗셈 (Signed Integer Division)

부호 있는 수를 나누기 전에 피제수를 **부호 확장(sign extension)** 해야 함.

```assembly
.data
wordVal SWORD -101      ; 009Bh
.code
mov  eax, 0             ; EAX = 00000000h
mov  ax, wordVal        ; EAX = 0000009Bh (+155)
mov  bx, 2              ; BX가 제수
idiv bx                 ; DX:AX를 BX로 나눔 (부호 있는 연산)
```

→ **EAX의 0000009Bh는 -101이 아님!** (+155로 해석됨)

```assembly
.data
wordVal SWORD -101      ; 009Bh
.code
mov  eax, 0             ; EAX = 00000000h
mov  ax, wordVal        ; EAX = 0000009Bh (+155)
cwd                     ; DX:AX = FFFFFF9Bh (-101)   ← 부호 확장
mov  bx, 2              ; BX가 제수
idiv bx                 ; DX:AX를 BX로 나눔
```

#### ① 부호 확장 명령어 (CBW, CWD, CDQ)

| 명령어 | 의미 | 동작 |
| --- | --- | --- |
| **CBW** | convert byte to word | AL의 부호 비트를 AH로 확장 |
| **CWD** | convert word to doubleword | AX의 부호 비트를 DX로 확장 |
| **CDQ** | convert doubleword to quadword | EAX의 부호 비트를 EDX로 확장 |

```assembly
.data
byteVal SBYTE -101      ; 9Bh
.code
mov al, byteVal         ; AL = 9Bh
cbw                     ; AX = FF9Bh

.data
wordVal SWORD -101      ; FF9Bh
.code
mov ax, wordVal         ; AX = FF9Bh
cwd                     ; DX:AX = FFFFFF9Bh

.data
dwordVal SDWORD -101    ; FFFFFF9Bh
.code
mov eax, dwordVal
cdq                     ; EDX:EAX = FFFFFFFFFFFFFF9Bh
```

#### ② IDIV 명령어

**부호 있는 정수 나눗셈**. DIV와 같은 피연산자를 사용함. 8비트 나눗셈 전에는 피제수(AX)를 **완전히 부호 확장**해야 함.

```assembly
; Example 1
.data
byteVal SBYTE -48       ; D0h
.code
mov  al, byteVal        ; 피제수 하위
cbw                     ; AL을 AH로 확장
mov  bl, +5             ; 제수
idiv bl                 ; AL = -9, AH = -3
```

```
          AL = 11010000  (-48)
         ↙        ↓ (8비트 복사)
AX = 11111111 11010000  (-48)
```

```assembly
; Example 2
.data
wordVal SWORD -5000
.code
mov  ax, wordVal        ; 피제수 하위
cwd                     ; AX를 DX로 확장
mov  bx, +256           ; 제수
idiv bx                 ; 몫 AX = -19, 나머지 DX = -136

; Example 3
.data
dwordVal SDWORD +50000
.code
mov  eax, dwordVal      ; 피제수 하위
cdq                     ; EAX를 EDX로 확장
mov  ebx, -256          ; 제수
idiv ebx                ; 몫 EAX = -195, 나머지 EDX = +80
```

* **DIV와 IDIV 실행 후 모든 산술 상태 플래그 값은 정의되지 않음(undefined).**

#### ③ 나눗셈 오버플로 (Divide Overflow)

몫이 destination에 들어가지 않으면 **divide overflow**가 발생 → **프로세서 예외(exception)** 가 일어나 프로그램이 중단됨.

```assembly
mov ax, 1000h
mov bl, 10h
div bl                  ; AL에 100h를 담을 수 없음 → 오버플로
```

**32비트 제수와 64비트 피제수**를 사용하면 오버플로 가능성을 줄일 수 있음.

```assembly
mov eax, 1000h
cdq
mov ebx, 10h
div ebx                 ; EAX = 00000100h
```

#### ④ 0으로 나누기 방지

나누기 전에 **제수를 검사**함.

```assembly
    mov ax, dividend
    mov bl, divisor
    cmp bl, 0               ; 제수 검사
    je  NoDivideZero        ; 0이면 에러 표시
    div bl                  ; 0이 아니면 계속
    .
    .
NoDivideZero:               ; ("Attempt to divide by zero" 출력)
```

---

### 6. 산술 표현식 구현 (Implementing Arithmetic Expressions)

#### Example 1

```c
var4 = (var1 + var2) * var3;
```

```assembly
    mov eax, var1
    add eax, var2
    mul var3                ; EAX = EAX * var3
    jc  tooBig              ; 부호 없는 오버플로?
    mov var4, eax
    jmp next
tooBig:                     ; 에러 메시지 출력
```

#### Example 2

```c
var4 = (var1 * 5) / (var2 - 3);
```

```assembly
mov eax, var1           ; 왼쪽
mov ebx, 5
mul ebx                 ; EDX:EAX = 곱
mov ebx, var2           ; 오른쪽
sub ebx, 3
div ebx                 ; 최종 나눗셈
mov var4, eax
```

#### Example 3

```c
var4 = (var1 * -5) / (-var2 % var3);
```

```assembly
mov  eax, var2          ; 오른쪽 시작
neg  eax
cdq                     ; 피제수 부호 확장
idiv var3               ; EDX = 나머지
mov  ebx, edx           ; EBX = 오른쪽
mov  eax, -5            ; 왼쪽 시작
imul var1               ; EDX:EAX = 왼쪽
idiv ebx                ; 최종 나눗셈
mov  var4, eax          ; 몫
```

* 오른쪽 식을 먼저 계산하는 이유: 왼쪽 곱셈 결과가 EDX:EAX를 차지하므로, 나머지(EDX)를 먼저 구해 EBX에 옮겨 둬야 함.

---

## 7.4 확장 덧셈과 뺄셈 (Extended Addition and Subtraction)

### 1. ADC 명령어

**source 피연산자와 CF 값을 함께** destination에 더함 (add with carry). 레지스터 크기보다 큰 정수를 더할 때 사용함.

```assembly
ADC reg, reg
ADC mem, reg
ADC reg, mem
ADC mem, imm
ADC reg, imm
```

```assembly
mov dl, 0
mov al, 0FFh
add al, 0FFh            ; AL = FEh
adc dl, 0               ; DL/AL = 01FEh
```

```
ADD AL,0FFh   11111111 + 11111111         → AL = 11111110
                                    ↘ CF = 1
ADC DL,0      00000000 + 00000000 + 1(CF) → DL = 00000001
```

---

### 2. SBB 명령어

**source 피연산자와 CF 값을 함께** destination에서 뺌 (subtract with borrow).

```assembly
mov edx, 7              ; 상위 절반
mov eax, 1              ; 하위 절반
sub eax, 2              ; 2 빼기
sbb edx, 0              ; 상위 절반 빼기 (borrow 포함)
```

```
Before:     EDX = 00000007   EAX = 00000001

SUB EAX,2   00000001 - 00000002            → EAX = FFFFFFFF
                                    ↓ CF = 1
SBB EDX,0   00000007 - 00000000 - 1(CF)    → EDX = 00000006

After:      EDX = 00000006   EAX = FFFFFFFF
```

---

## 7.5 ASCII 및 언팩 십진 산술 (ASCII and Unpacked Decimal Arithmetic)

### 1. 명령어 목록

| 명령어 | 설명 |
| --- | --- |
| **AAA** | ASCII adjust after addition (덧셈 후 ASCII 조정) |
| **AAS** | ASCII adjust after subtraction (뺄셈 후 ASCII 조정) |
| **AAM** | ASCII adjust after multiplication (곱셈 후 ASCII 조정) |
| **AAD** | ASCII adjust before division (나눗셈 전 ASCII 조정) |

---

### 2. ASCII 십진수와 언팩 십진수 (ASCII Decimal and Unpacked Decimal)

* **언팩 십진수(unpacked decimal)**: 상위 4비트가 **항상 0000b**.
* **ASCII 십진수**: 상위 4비트가 **0011b** (= 30h).

숫자 3402의 표현 (모두 16진수):

| 형식 | 바이트 |
| --- | --- |
| **ASCII format** | 33 34 30 32 |
| **Unpacked** | 03 04 00 02 |

---

### 3. AAA 명령어

ADD 또는 ADC의 **이진 결과를 언팩 십진수로 조정**함. 자리올림이 생기면 AH가 1 증가하고 CF = 1.

```assembly
mov ah, 0
mov al, '8'             ; AX = 0038h
add al, '2'             ; AX = 006Ah
aaa                     ; AX = 0100h (ASCII 조정 결과)
or  ax, 3030h           ; AX = 3130h = '10' (ASCII로 변환)
```

---

### 4. AAA를 이용한 다중 바이트 덧셈 (Multibyte Addition Using AAA)

#### 의사 코드

```
esi (index) = length of first_number - 1
edi (index) = length of first_number
ecx = length of first_number
set carry value to 0
Loop
    acc = first_number[esi]
    add previous carry to acc
    save carry in carry1
    acc += second_number[esi]
    OR the carry with carry1
    sum[edi] = acc
    dec edi
Until ecx == 0
Store last carry digit in sum
```

#### 프로그램 (ASCII_add.asm)

```assembly
; ASCII Addition                (ASCII_add.asm)
; 소수점이 고정된 ASCII 문자열에 대해 ASCII 산술 수행

INCLUDE Irvine32.inc

DECIMAL_OFFSET = 5                          ; 문자열 오른쪽에서의 오프셋

.data
decimal_one BYTE "100123456789765"          ; 1001234567.89765
decimal_two BYTE "900402076502015"          ; 9004020765.02015
sum BYTE (SIZEOF decimal_one + 1) DUP(0),0

.code
main PROC
; 마지막 자리부터 시작
    mov esi, SIZEOF decimal_one - 1
    mov edi, SIZEOF decimal_one
    mov ecx, SIZEOF decimal_one
    mov bh, 0                               ; carry 값을 0으로

L1: mov ah, 0                               ; 덧셈 전 AH 지우기
    mov al, decimal_one[esi]                ; 첫 번째 숫자
    add al, bh                              ; 이전 carry 더하기
    aaa                                     ; 합 조정 (AH = carry)
    mov bh, ah                              ; carry를 carry1에 저장
    or  bh, 30h                             ; ASCII로 변환
    add al, decimal_two[esi]                ; 두 번째 숫자 더하기
    aaa                                     ; 합 조정 (AH = carry)
    or  bh, ah                              ; carry를 carry1과 OR
    or  bh, 30h                             ; ASCII로 변환
    or  al, 30h                             ; AL을 다시 ASCII로
    mov sum[edi], al                        ; 합에 저장
    dec esi                                 ; 한 자리 앞으로
    dec edi
    loop L1
    mov sum[edi], bh                        ; 마지막 carry 저장

; 합을 문자열로 출력
    mov edx, OFFSET sum
    call WriteString
    call Crlf
    exit
main ENDP
END main
```

```
출력: 1000525533291780
```

---

### 5. AAS 명령어

SUB 또는 SBB로 언팩 십진수끼리 뺀 결과(AL)를 **조정**함. 결과가 음수이면 AH가 1 감소하고 CF = 1.

```assembly
.data
val1 BYTE '8'
val2 BYTE '9'
.code
mov ah, 0
mov al, val1            ; AX = 0038h
sub al, val2            ; AX = 00FFh
aas                     ; AX = FF09h
pushf                   ; Carry 플래그 저장
or  al, 30h             ; AX = FF39h
popf                    ; Carry 플래그 복원
```

* `OR`이 CF를 지우므로 `PUSHF / POPF`로 CF를 보존함.

---

### 6. AAM 명령어

MUL로 만든 **이진 곱을 언팩 십진수로 변환**함 (AL을 10으로 나눠 몫 → AH, 나머지 → AL).

```assembly
.data
AscVal BYTE 05h, 06h
.code
mov bl, ascVal          ; 첫 번째 피연산자
mov al, [ascVal+1]      ; 두 번째 피연산자
mul bl                  ; AX = 001Eh (30)
aam                     ; AX = 0300h
```

---

### 7. AAD 명령어

AX의 **언팩 십진 피제수를 이진수로 변환**하여 DIV를 실행할 준비를 함 (AL = AH × 10 + AL, AH = 0).

```assembly
.data
quotient  BYTE ?
remainder BYTE ?
.code
mov ax, 0307h           ; 피제수 (37)
aad                     ; AX = 0025h
mov bl, 5               ; 제수
div bl                  ; AX = 0207h
mov quotient, al
mov remainder, ah
```

---

## 7.6 팩 십진 산술 (Packed Decimal Arithmetic)

### 1. DAA 명령어

ADD 또는 ADC로 만든 AL의 **이진 합을 팩 십진수(packed decimal) 형식으로 변환**함.

```assembly
mov al, 35h
add al, 48h             ; AL = 7Dh
daa                     ; AL = 83h (조정된 결과)
```

#### 예제 (AddPacked.asm)

```assembly
; Packed Decimal Example        (AddPacked.asm)
; 팩 십진수 덧셈 예시
INCLUDE Irvine32.inc

.data
packed_1 WORD 4536h
packed_2 WORD 7207h
sum DWORD ?

.code
main PROC
; sum과 인덱스 초기화
    mov sum, 0
    mov esi, 0
; 하위 바이트 더하기
    mov al, BYTE PTR packed_1[esi]
    add al, BYTE PTR packed_2[esi]
    daa
    mov BYTE PTR sum[esi], al
; 상위 바이트 더하기 (carry 포함)
    inc esi
    mov al, BYTE PTR packed_1[esi]
    adc al, BYTE PTR packed_2[esi]
    daa
    mov BYTE PTR sum[esi], al
; 마지막 carry가 있으면 더하기
    inc esi
    mov al, 0
    adc al, 0
    mov BYTE PTR sum[esi], al
; 합을 16진수로 출력
    mov eax, sum
    call WriteHex
    call Crlf
    exit
main ENDP
END main
```

```
출력: 00011743   (4536 + 7207 = 11743)
```

---

### 2. DAS 명령어

SUB 또는 SBB로 만든 AL의 **이진 결과를 팩 십진수 형식으로 변환**함.

```assembly
mov bl, 48h
mov al, 85h
sub al, bl              ; AL = 3Dh
das                     ; AL = 37h (조정된 결과)
```

---

## 7.7 주요 요약 및 학습 키워드 (Key Terms)

* **SHL / SHR**: 논리 시프트. 빈 자리를 0으로 채우고 밀려난 비트는 CF로. SHL n = 2ⁿ 곱, SHR n = 2ⁿ 나눗셈 (부호 없는 수).

* **SAL / SAR**: 산술 시프트. SAL은 SHL과 동일, SAR은 부호 비트를 복사해 부호를 유지 → 부호 있는 나눗셈, 부호 확장에 활용.

* **ROL / ROR**: 회전. 밀려난 비트가 반대쪽 끝과 CF로 들어가므로 비트를 잃지 않음.

* **RCL / RCR**: CF를 포함한 회전. 여러 바이트/워드에 걸친 시프트에 활용.

* **Signed Overflow**: 1비트 시프트/회전 결과가 부호 있는 범위를 벗어나면 OF = 1. 횟수가 1보다 크면 OF는 undefined.

* **SHLD / SHRD**: 배정밀도 시프트. 빈 자리를 source의 비트로 채우며, source는 변하지 않음.

* **MUL / IMUL**: 부호 없는/있는 곱셈. 곱은 피연산자의 2배 크기(AX, DX:AX, EDX:EAX). 2·3 피연산자 IMUL은 결과를 잘라내므로 OF/CF 확인 필수.

* **DIV / IDIV**: 부호 없는/있는 나눗셈. 몫은 AL/AX/EAX, 나머지는 AH/DX/EDX. 실행 후 산술 플래그는 undefined. 몫이 넘치면 divide overflow 예외.

* **CBW / CWD / CDQ**: AL→AX, AX→DX:AX, EAX→EDX:EAX 부호 확장. IDIV 전에 필수.

* **ADC / SBB**: CF를 포함한 덧셈/뺄셈. 레지스터보다 큰 정수(확장 정밀도) 연산에 사용.

* **AAA / AAS / AAM / AAD**: ASCII·언팩 십진수 연산 조정. AAD만 나눗셈 **전**에 사용.

* **DAA / DAS**: 팩 십진수(한 바이트에 두 자리) 덧셈/뺄셈 결과 조정.
