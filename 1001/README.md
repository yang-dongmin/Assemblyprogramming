# 1001

## 4.1 데이터 전송 명령어 (Data Transfer Instructions)

### 1. 피연산자 타입 (Operand Types)

구문: `[label:] mnemonic [operands] [;comment]`

```assembly
mnemonic
mnemonic [destination]
mnemonic [destination], [source]
mnemonic [destination], [source-1], [source-2]
```

* 피연산자 순서는 **destination(목적지) ← source(출발지)**.
* **Operand**: 연산의 대상 / **Operator**: 연산자

| 종류 | 설명 |
| --- | --- |
| **Immediate** | 숫자 리터럴 표현식 사용 (예: `5`, `10h`) |
| **Register** | CPU 내의 이름 있는 레지스터 사용 (예: `EAX`) |
| **Memory** | 메모리 위치를 참조 (예: 변수명) |

#### 명령어 피연산자 표기법 (Table 4-1, 32비트 모드)

| 표기 | 설명 |
| --- | --- |
| **reg8** | 8비트 범용 레지스터: `AH, AL, BH, BL, CH, CL, DH, DL` |
| **reg16** | 16비트 범용 레지스터: `AX, BX, CX, DX, SI, DI, SP, BP` |
| **reg32** | 32비트 범용 레지스터: `EAX, EBX, ECX, EDX, ESI, EDI, ESP, EBP` |
| **reg** | 아무 범용 레지스터 |
| **sreg** | 16비트 세그먼트 레지스터: `CS, DS, SS, ES, FS, GS` |
| **imm** | 8/16/32비트 즉시값 |
| **imm8 / imm16 / imm32** | 8비트(byte) / 16비트(word) / 32비트(doubleword) 즉시값 |
| **reg/mem8** | 8비트 레지스터 또는 메모리 byte |
| **reg/mem16** | 16비트 레지스터 또는 메모리 word |
| **reg/mem32** | 32비트 레지스터 또는 메모리 doubleword |
| **mem** | 8/16/32비트 메모리 피연산자 |

* `SI` = Source Index, `DI` = Destination Index

---

### 2. 직접 메모리 피연산자 (Direct Memory Operands)

변수명은 데이터 세그먼트 내의 **오프셋(offset)** 을 참조함.

```assembly
.data
var1 BYTE 10h       ; var1이 오프셋 10400h에 위치한다고 가정

.code
mov al, var1        ; 기계어: A0 00010400
```

---

### 3. MOV 명령어

source 피연산자의 데이터를 destination 피연산자로 **복사(copy)** 함. (`dest = source;`)

```assembly
MOV reg, reg
MOV mem, reg
MOV reg, mem
MOV mem, imm
MOV reg, imm
```

* 두 피연산자의 **크기가 같아야** 함.
* 두 피연산자가 **모두 메모리일 수 없음**.
* 명령어 포인터 레지스터(`IP`, `EIP`, `RIP`)는 destination이 될 수 없음.

#### 메모리 → 메모리 전송

MOV 하나로는 메모리 간 직접 이동이 불가능하므로 레지스터를 거쳐야 함.

```assembly
.data
var1 WORD ?
var2 WORD ?
.code
mov ax, var1
mov var2, ax
```

#### 값 겹치기 (Overlapping Values)

```assembly
.data
oneByte  BYTE  78h
oneWord  WORD  1234h
oneDword DWORD 12345678h

.code
mov eax, 0          ; EAX = 00000000h
mov al, oneByte     ; EAX = 00000078h
mov ax, oneWord     ; EAX = 00001234h
mov eax, oneDword   ; EAX = 12345678h
mov ax, 0           ; EAX = 12340000h  (하위 16비트만 변경)
```

---

### 4. 정수의 제로/부호 확장 (Zero/Sign Extension of Integers)

#### ① 작은 값을 큰 레지스터로 복사할 때의 문제

```assembly
.data
count WORD 1
.code
mov ecx, 0
mov cx, count               ; 부호 없는 값은 문제 없음

.data
signedVal SWORD -16         ; FFF0h (-16)
.code
mov ecx, 0
mov cx, signedVal           ; ECX = 0000FFF0h (+65,520) → 잘못된 값!

mov ecx, 0FFFFFFFFh
mov cx, signedVal           ; ECX = FFFFFFF0h (-16) → 상위 비트를 1로 채워야 올바름
```

→ 이 문제를 해결하기 위해 `MOVZX`, `MOVSX` 사용.

#### ② MOVZX (Move with Zero-Extend)

source를 destination에 복사하고 상위 비트를 **0으로 채움** (부호 없는 정수용).

```assembly
MOVZX reg32, reg/mem8
MOVZX reg32, reg/mem16
MOVZX reg16, reg/mem8
```

```assembly
.data
byteVal BYTE 10001111b
.code
movzx ax, byteVal           ; AX = 00000000 10001111b

mov   bx, 0A69Bh
movzx eax, bx               ; EAX = 0000A69Bh
movzx edx, bl               ; EDX = 0000009Bh
movzx cx, bl                ; CX  = 009Bh
```

#### ③ MOVSX (Move with Sign-Extend)

source를 destination에 복사하고 상위 비트를 **source의 최상위 비트(부호 비트)로 채움** (부호 있는 정수용).

```assembly
MOVSX reg32, reg/mem8
MOVSX reg32, reg/mem16
MOVSX reg16, reg/mem8
```

```assembly
.data
byteVal BYTE 10001111b
.code
movsx ax, byteVal           ; AX = 11111111 10001111b

mov   bx, 0A69Bh
movsx eax, bx               ; EAX = FFFFA69Bh
movsx edx, bl               ; EDX = FFFFFF9Bh
mov   bl, 7Bh
movsx cx, bl                ; CX  = 007Bh (최상위 비트가 0이므로 0으로 채움)
```

---

### 5. LAHF / SAHF 명령어

* **LAHF** (Load Status Flags into AH): EFLAGS 레지스터의 하위 바이트를 `AH`로 복사.
* **SAHF** (Store AH into Status Flags): `AH`를 EFLAGS(또는 RFLAGS)의 하위 바이트로 복사.

```assembly
.data
saveflags BYTE ?
.code
lahf                        ; 플래그를 AH로 로드
mov saveflags, ah           ; 변수에 저장

mov ah, saveflags           ; 저장한 플래그를 AH로 로드
sahf                        ; 플래그 레지스터로 복사
```

---

### 6. XCHG 명령어

두 피연산자의 내용을 **교환(exchange)** 함.

```assembly
XCHG reg, reg
XCHG reg, mem
XCHG mem, reg
```

```assembly
xchg ax, bx                 ; 16비트 레지스터 교환
xchg ah, al                 ; 8비트 레지스터 교환
xchg var1, bx               ; 16비트 메모리와 BX 교환
xchg eax, ebx               ; 32비트 레지스터 교환
```

#### 두 메모리 피연산자 교환

```assembly
mov  ax, val1
xchg ax, val2
mov  val1, ax
```

---

### 7. 직접-오프셋 피연산자 (Direct-Offset Operands)

변수명에 오프셋을 더해 **명시적인 레이블이 없는 메모리 위치**에 접근함. 원소 크기만큼 더해야 함에 주의.

```assembly
arrayB BYTE 10h, 20h, 30h, 40h, 50h
mov al, arrayB              ; AL = 10h
mov al, [arrayB+1]          ; AL = 20h
mov al, [arrayB+2]          ; AL = 30h

arrayW WORD 100h, 200h, 300h
mov ax, arrayW              ; AX = 100h
mov ax, [arrayW+2]          ; AX = 200h  (WORD = 2바이트)

arrayD DWORD 10000h, 20000h
mov eax, arrayD             ; EAX = 10000h
mov eax, [arrayD+4]         ; EAX = 20000h  (DWORD = 4바이트)
```

---

### 8. 예제 프로그램 (Moves)

```assembly
.data
val1 WORD 1000h
val2 WORD 2000h
arrayB BYTE  10h, 20h, 30h, 40h, 50h
arrayW WORD  100h, 200h, 300h
arrayD DWORD 10000h, 20000h

.code
main PROC
; MOVZX
    mov   bx, 0A69Bh
    movzx eax, bx               ; EAX = 0000A69Bh
    movzx edx, bl               ; EDX = 0000009Bh
    movzx cx, bl                ; CX  = 009Bh

; MOVSX
    mov   bx, 0A69Bh
    movsx eax, bx               ; EAX = FFFFA69Bh
    movsx edx, bl               ; EDX = FFFFFF9Bh
    mov   bl, 7Bh
    movsx cx, bl                ; CX  = 007Bh

; Memory-to-memory exchange
    mov  ax, val1               ; AX = 1000h
    xchg ax, val2               ; AX = 2000h, val2 = 1000h
    mov  val1, ax               ; val1 = 2000h

; Direct-Offset Addressing (byte array)
    mov al, arrayB              ; AL = 10h
    mov al, [arrayB+1]          ; AL = 20h
    mov al, [arrayB+2]          ; AL = 30h

; Direct-Offset Addressing (word array)
    mov ax, arrayW              ; AX = 100h
    mov ax, [arrayW+2]          ; AX = 200h

; Direct-Offset Addressing (doubleword array)
    mov eax, arrayD             ; EAX = 10000h
    mov eax, [arrayD+4]         ; EAX = 20000h
    mov eax, [arrayD+TYPE arrayD] ; EAX = 20000h

    INVOKE ExitProcess, 0
main ENDP
END main
```

---

## 4.2 덧셈과 뺄셈 (Addition and Subtraction)

### 1. INC / DEC 명령어

레지스터 또는 메모리 피연산자에 1을 더하거나(INC) 뺌(DEC).

```assembly
INC reg/mem
DEC reg/mem
```

```assembly
.data
myWord WORD 1000h
.code
inc myWord                  ; myWord = 1001h
mov bx, myWord
dec bx                      ; BX = 1000h
```

---

### 2. ADD / SUB 명령어

같은 크기의 source를 destination에 더하거나(ADD) 뺌(SUB). source는 변하지 않고 결과는 destination에 저장됨.

```assembly
ADD dest, source
SUB dest, source
```

```assembly
.data
var1 DWORD 10000h
var2 DWORD 20000h
.code
mov eax, var1               ; EAX = 10000h
add eax, var2               ; EAX = 30000h
```

* **Flags**: Carry, Zero, Sign, Overflow, Auxiliary Carry, Parity 플래그가 destination에 저장된 결과값에 따라 변경됨.

---

### 3. NEG 명령어

숫자를 **2의 보수(two's complement)** 로 변환하여 부호를 반전시킴.

```assembly
NEG reg
NEG mem
```

* **Flags**: ADD/SUB와 동일하게 CF, ZF, SF, OF, AC, PF가 변경됨.

---

### 4. 산술 표현식 구현 (Implementing Arithmetic Expressions)

`Rval = -Xval + (Yval - Zval);`

```assembly
.data
Rval SDWORD ?
Xval SDWORD 26
Yval SDWORD 30
Zval SDWORD 40

.code
; 첫 번째 항: -Xval
mov eax, Xval
neg eax                     ; EAX = -26

; 두 번째 항: (Yval - Zval)
mov ebx, Yval
sub ebx, Zval               ; EBX = -10

; 두 항을 더해서 저장
add eax, ebx
mov Rval, eax               ; Rval = -36
```

---

### 5. 덧셈과 뺄셈에 영향을 받는 플래그 (Status Flags)

| 플래그 | 의미 |
| --- | --- |
| **Carry Flag (CF)** | 부호 없는 정수 오버플로 |
| **Zero Flag (ZF)** | 결과가 0 |
| **Sign Flag (SF)** | 결과가 음수 |
| **Overflow Flag (OF)** | 부호 있는 정수 오버플로 |
| **Auxiliary Carry Flag (AC)** | 비트 3에서 올림/빌림 발생 |
| **Parity Flag (PF)** | 결과의 최하위 바이트에 1인 비트가 짝수 개 |

---

### 6. 부호 없는 연산: Zero, Carry, Auxiliary Carry

#### ① Zero Flag

산술 연산 결과가 0이면 설정됨.

```assembly
mov ecx, 1
sub ecx, 1                  ; ECX = 0, ZF = 1
mov eax, 0FFFFFFFFh
inc eax                     ; EAX = 0, ZF = 1
inc eax                     ; EAX = 1, ZF = 0
dec eax                     ; EAX = 0, ZF = 1
```

> **INC와 DEC는 Carry 플래그에 영향을 주지 않음.** 0이 아닌 피연산자에 NEG를 적용하면 항상 Carry 플래그가 설정됨.

#### ② 덧셈과 Carry Flag

최상위 비트에서 올림(carry)이 발생하면 CF = 1.

```assembly
mov al, 0FFh
add al, 1                   ; AL = 00, CF = 1  (11111111 + 00000001 = 1 00000000)

mov ax, 00FFh
add ax, 1                   ; AX = 0100h, CF = 0
mov ax, 0FFFFh
add ax, 1                   ; AX = 0000, CF = 1
```

#### ③ 뺄셈과 Carry Flag

작은 부호 없는 정수에서 큰 정수를 빼면 CF = 1.

```assembly
mov al, 1
sub al, 2                   ; AL = FFh, CF = 1
```

* 내부적으로는 `1 + (-2)` = `00000001 + 11111110` = `11111111 (FFh)` 로 계산됨.
* 정리: 자리(범위)를 넘어가는 경우(`0FFh + 1`) 또는 0 미만의 값이 되는 경우(`0 - 1`) CF = 1.

#### ④ Auxiliary Carry (AC)

destination의 **비트 3에서 올림 또는 빌림**이 발생하면 설정됨.

```assembly
mov al, 0Fh
add al, 1                   ; AC = 1

;   0 0 0 0 1 1 1 1
; + 0 0 0 0 0 0 0 1
; -----------------
;   0 0 0 1 0 0 0 0
```

#### ⑤ Parity (PF)

destination의 **최하위 바이트에 1인 비트가 짝수 개**이면 설정됨.

```assembly
mov al, 10001100b
add al, 00000010b           ; AL = 10001110, PF = 1 (1이 4개)
sub al, 10000000b           ; AL = 00001110, PF = 0 (1이 3개)
```

---

### 7. 부호 있는 연산: Sign, Overflow

#### ① Sign Flag

부호 있는 산술 연산의 결과가 음수이면 설정됨.

```assembly
mov eax, 4
sub eax, 5                  ; EAX = -1, SF = 1

mov bl, 1                   ; BL = 01h
sub bl, 2                   ; BL = FFh (-1), SF = 1
```

#### ② Overflow Flag

부호 있는 산술 연산의 결과가 destination의 범위를 넘거나(overflow) 모자라면(underflow) 설정됨.

```assembly
mov al, +127
add al, 1                   ; OF = 1

mov al, -128
sub al, 1                   ; OF = 1
```

#### ③ 덧셈 테스트 (The Addition Test)

다음 경우에 오버플로가 발생함:

* **양수 + 양수 = 음수**
* **음수 + 음수 = 양수**

#### ④ 하드웨어의 오버플로 검출 방법

최상위 비트에서 **나가는 올림(carry out)** 과 최상위 비트로 **들어오는 올림(carry in)** 을 XOR한 값이 OF에 저장됨.

```
     1 0 0 0 0 0 0 0    (-128)
   + 1 1 1 1 1 1 1 0    (-2)
   -----------------
CF 1 0 1 1 1 1 1 1 0    (+126)  → carry out = 1, carry in = 0 → OF = 1
```

#### ⑤ NEG 명령어와 오버플로

destination에 결과를 올바르게 저장할 수 없으면 잘못된 결과가 나옴.

```assembly
mov al, -128                ; AL = 10000000b
neg al                      ; AL = 10000000b, OF = 1  (+128은 8비트로 표현 불가)

mov al, +127                ; AL = 01111111b
neg al                      ; AL = 10000001b, OF = 0
```

---

### 8. 예제 프로그램 (AddSubTest)

```assembly
; Addition and Subtraction (AddSubTest.asm)
; ADD, SUB, INC, DEC, NEG 명령어와 CPU 상태 플래그에 미치는 영향 예제

.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
Rval SDWORD ?
Xval SDWORD 26
Yval SDWORD 30
Zval SDWORD 40

.code
main PROC
    ; INC and DEC
    mov ax, 1000h
    inc ax                  ; 1001h
    dec ax                  ; 1000h

    ; Expression: Rval = -Xval + (Yval - Zval)
    mov eax, Xval
    neg eax                 ; -26
    mov ebx, Yval
    sub ebx, Zval           ; -10
    add eax, ebx
    mov Rval, eax           ; -36

    ; Zero flag example
    mov cx, 1
    sub cx, 1               ; ZF = 1
    mov ax, 0FFFFh
    inc ax                  ; ZF = 1

    ; Sign flag example
    mov cx, 0
    sub cx, 1               ; SF = 1
    mov ax, 7FFFh
    add ax, 2               ; SF = 1

    ; Carry flag example
    mov al, 0FFh
    add al, 1               ; CF = 1, AL = 00

    ; Overflow flag example
    mov al, +127
    add al, 1               ; OF = 1
    mov al, -128
    sub al, 1               ; OF = 1

    INVOKE ExitProcess, 0
main ENDP
END main
```

---

## 4.3 데이터 관련 연산자와 지시자 (Data-Related Operators and Directives)

| 연산자/지시자 | 설명 |
| --- | --- |
| **OFFSET** | 변수의 오프셋(데이터 세그먼트 시작으로부터의 거리) 반환 |
| **PTR** | 피연산자의 기본 크기를 재정의(override) |
| **TYPE** | 피연산자 또는 배열 원소 하나의 크기(바이트) 반환 |
| **LENGTHOF** | 배열의 원소 개수 반환 |
| **SIZEOF** | 배열이 사용하는 전체 바이트 수 반환 |
| **ALIGN** | 변수를 특정 경계에 정렬 |
| **LABEL** | 저장 공간 할당 없이 레이블과 크기 속성을 부여 |

---

### 1. OFFSET 연산자

데이터 레이블의 **오프셋**, 즉 데이터 세그먼트 시작으로부터 레이블까지의 거리(바이트)를 반환함.

```assembly
.data
bVal  BYTE  ?
wVal  WORD  ?
dVal  DWORD ?
dVal2 DWORD ?

.code
mov esi, OFFSET bVal        ; ESI = 00404000h
mov esi, OFFSET wVal        ; ESI = 00404001h
mov esi, OFFSET dVal        ; ESI = 00404003h
mov esi, OFFSET dVal2       ; ESI = 00404007h
```

```assembly
.data
myArray WORD 1, 2, 3, 4, 5
.code
mov esi, OFFSET myArray + 4 ; ESI가 배열의 세 번째 정수를 가리킴

.data
bigArray DWORD 500 DUP(?)
pArray   DWORD bigArray     ; pArray는 bigArray의 시작 주소를 가짐
```

---

### 2. ALIGN 지시자

변수를 byte, word, doubleword, paragraph 경계에 정렬함.

구문: `ALIGN bound`

```assembly
bVal  BYTE  ?               ; 00404000h
ALIGN 2
wVal  WORD  ?               ; 00404002h
bVal2 BYTE  ?               ; 00404004h
ALIGN 4
dVal  DWORD ?               ; 00404008h
dVal2 DWORD ?               ; 0040400Ch
```

* **왜 정렬하는가?** CPU는 짝수 주소에 저장된 데이터를 홀수 주소보다 더 빠르게 처리할 수 있기 때문.

---

### 3. PTR 연산자

선언된 피연산자의 크기를 **재정의(override)** 함.

```assembly
.data
myDouble DWORD 12345678h
.code
mov ax, myDouble                    ; error: 크기 불일치
mov ax, WORD PTR myDouble           ; AX = 5678h
mov ax, WORD PTR [myDouble+2]       ; AX = 1234h
mov WORD PTR myDouble, 4321h        ; 하위 word에 4321h 저장
```

#### myDouble의 메모리 배치 (리틀 엔디안)

| Doubleword | Word | Byte | Offset | 주소 |
| --- | --- | --- | --- | --- |
| 12345678 | 5678 | 78 | 0000 | `myDouble` |
| | | 56 | 0001 | `myDouble + 1` |
| | 1234 | 34 | 0002 | `myDouble + 2` |
| | | 12 | 0003 | `myDouble + 3` |

```assembly
mov al, BYTE PTR myDouble           ; AL = 78h
mov al, BYTE PTR [myDouble+1]       ; AL = 56h
mov al, BYTE PTR [myDouble+2]       ; AL = 34h
mov bl, BYTE PTR myDouble           ; BL = 78h
```

---

### 4. TYPE 연산자

변수의 **원소 하나의 크기(바이트)** 를 반환함.

```assembly
.data
var1 BYTE  ?
var2 WORD  ?
var3 DWORD ?
var4 QWORD ?
```

| 표현식 | 값 |
| --- | --- |
| `TYPE var1` | 1 |
| `TYPE var2` | 2 |
| `TYPE var3` | 4 |
| `TYPE var4` | 8 |

---

### 5. LENGTHOF 연산자

레이블과 **같은 줄에 정의된 값**을 기준으로 배열의 원소 개수를 셈.

```assembly
.data
byte1    BYTE  10, 20, 30
array1   WORD  30 DUP(?), 0, 0
array2   WORD  5 DUP(3 DUP(?))
array3   DWORD 1, 2, 3, 4
digitStr BYTE  "12345678", 0
```

| 표현식 | 값 |
| --- | --- |
| `LENGTHOF byte1` | 3 |
| `LENGTHOF array1` | 30 + 2 = 32 |
| `LENGTHOF array2` | 5 * 3 = 15 |
| `LENGTHOF array3` | 4 |
| `LENGTHOF digitStr` | 9 (Null 문자 포함) |

---

### 6. SIZEOF 연산자

`LENGTHOF × TYPE` 과 같은 값을 반환함.

```assembly
.data
intArray WORD 32 DUP(0)
.code
mov eax, SIZEOF intArray    ; EAX = 64  (32 × 2)
```

---

### 7. LABEL 지시자

**저장 공간을 할당하지 않고** 레이블을 삽입하고 크기 속성을 부여함. 같은 메모리를 다른 크기로 접근할 때 유용.

```assembly
.data
val16 LABEL WORD
val32 DWORD 12345678h
.code
mov ax, val16               ; AX = 5678h
mov dx, [val16+2]           ; DX = 1234h
```

```assembly
.data
LongValue LABEL DWORD
val1 WORD 5678h
val2 WORD 1234h
.code
mov eax, LongValue          ; EAX = 12345678h
```

---

## 4.4 간접 주소 지정 (Indirect Addressing)

### 1. 간접 피연산자 (Indirect Operands)

레지스터에 주소를 넣고 `[reg]` 형태로 해당 주소의 값에 접근함.

```assembly
.data
byteVal BYTE 10h
.code
mov esi, OFFSET byteVal
mov al, [esi]               ; AL = 10h

inc [esi]                   ; error: operand must have size
inc BYTE PTR [esi]          ; PTR로 크기를 지정해야 함
```

---

### 2. 배열 (Arrays)

간접 피연산자는 배열 순회에 유용함. 원소 크기만큼 레지스터를 증가시켜야 함.

```assembly
.data
arrayB BYTE 10h, 20h, 30h
.code
mov esi, OFFSET arrayB
mov al, [esi]               ; AL = 10h
inc esi
mov al, [esi]               ; AL = 20h
inc esi
mov al, [esi]               ; AL = 30h
```

```assembly
.data
arrayW WORD 1000h, 2000h, 3000h
.code
mov esi, OFFSET arrayW
mov ax, [esi]               ; AX = 1000h
add esi, 2
mov ax, [esi]               ; AX = 2000h
add esi, 2
mov ax, [esi]               ; AX = 3000h
```

#### 예제: 32비트 정수 더하기

```assembly
.data
arrayD DWORD 10000h, 20000h, 30000h
.code
mov esi, OFFSET arrayD
mov eax, [esi]              ; 첫 번째 수
add esi, 4
add eax, [esi]              ; 두 번째 수
add esi, 4
add eax, [esi]              ; 세 번째 수
```

| Offset | Value | 참조 |
| --- | --- | --- |
| 10200 | 10000h | `[esi]` |
| 10204 | 20000h | `[esi] + 4` |
| 10208 | 30000h | `[esi] + 8` |

---

### 3. 인덱스 피연산자 (Indexed Operands)

레지스터에 상수를 더해 **유효 주소(effective address)** 를 생성함.

구문: `constant[reg]` 또는 `[constant + reg]`

| 형태 1 | 형태 2 |
| --- | --- |
| `arrayB[esi]` | `[arrayB + esi]` |
| `arrayD[ebx]` | `[arrayD + ebx]` |

```assembly
.data
arrayB BYTE 10h, 20h, 30h
.code
mov esi, 0
mov al, arrayB[esi]         ; AL = 10h
```

#### ① 변위 더하기 (Adding Displacements)

```assembly
.data
arrayW WORD 1000h, 2000h, 3000h
.code
mov esi, OFFSET arrayW
mov ax, [esi]               ; AX = 1000h
mov ax, [esi+2]             ; AX = 2000h
mov ax, [esi+4]             ; AX = 3000h
```

#### ② 16비트 레지스터 사용

```assembly
mov al, arrayB[si]
mov ax, arrayW[di]
mov eax, arrayD[bx]
```

#### ③ 스케일 팩터 (Scale Factors)

인덱스 피연산자는 오프셋 계산 시 **각 원소의 크기를 고려**해야 함.

```assembly
.data
arrayD DWORD 100h, 200h, 300h, 400h
.code
mov esi, 3 * TYPE arrayD    ; arrayD[3]의 오프셋
mov eax, arrayD[esi]        ; EAX = 400h
```

```assembly
.data
arrayD DWORD 1, 2, 3, 4
.code
mov esi, 3                      ; 첨자(subscript)
mov eax, arrayD[esi*4]          ; EAX = 4

mov esi, 3
mov eax, arrayD[esi*TYPE arrayD] ; EAX = 4
```

---

### 4. 포인터 (Pointers)

**다른 변수의 주소를 담고 있는 변수**를 포인터라고 함.

```assembly
.data
arrayB BYTE  10h, 20h, 30h, 40h
arrayW WORD  1000h, 2000h, 3000h
ptrB   DWORD arrayB         ; ptrB는 arrayB의 오프셋을 가짐
ptrW   DWORD arrayW         ; ptrW는 arrayW의 오프셋을 가짐

; OFFSET을 명시해도 동일
ptrB   DWORD OFFSET arrayB
ptrW   DWORD OFFSET arrayW
```

#### TYPEDEF 연산자

내장 타입과 동일한 지위를 갖는 **사용자 정의 타입**을 만듦. 포인터 변수 생성에 적합함.

```assembly
PBYTE TYPEDEF PTR BYTE

.data
arrayB BYTE 10h, 20h, 30h, 40h
ptr1   PBYTE ?              ; 초기화되지 않음
ptr2   PBYTE arrayB         ; 배열을 가리킴
```

#### 예제 프로그램 (Pointers.asm)

```assembly
; Pointers (Pointers.asm)
; 포인터와 TYPEDEF 사용 예제

.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

; 사용자 정의 타입 생성
PBYTE  TYPEDEF PTR BYTE     ; byte 포인터
PWORD  TYPEDEF PTR WORD     ; word 포인터
PDWORD TYPEDEF PTR DWORD    ; doubleword 포인터

.data
arrayB BYTE  10h, 20h, 30h
arrayW WORD  1, 2, 3
arrayD DWORD 4, 5, 6

; 포인터 변수 생성
ptr1 PBYTE  arrayB
ptr2 PWORD  arrayW
ptr3 PDWORD arrayD

.code
main PROC
    ; 포인터로 데이터 접근
    mov esi, ptr1
    mov al, [esi]           ; 10h
    mov esi, ptr2
    mov ax, [esi]           ; 1
    mov esi, ptr3
    mov eax, [esi]          ; 4

    INVOKE ExitProcess, 0
main ENDP
END main
```

---

## 4.5 JMP와 LOOP 명령어 (JMP and LOOP Instructions)

### 제어 전송의 종류

| 종류 | 설명 |
| --- | --- |
| **무조건 전송 (Unconditional Transfer)** | 항상 새로운 위치로 제어가 이동하여 그 주소에서 실행이 계속됨 (예: `JMP`) |
| **조건부 전송 (Conditional Transfer)** | 조건에 따라 제어가 이동하여 분기 로직을 구현 |

---

### 1. JMP 명령어

코드 레이블(어셈블러가 오프셋으로 변환)로 **무조건 이동**함.

구문: `JMP destination`

```assembly
top:
    .
    .
    jmp top                 ; 무한 루프 반복
```

---

### 2. LOOP 명령어

**ECX 카운터에 따른 반복(Loop According to ECX Counter)**. 블록을 지정된 횟수만큼 반복하며, ECX가 자동으로 카운터로 사용되어 반복마다 1씩 감소함. **ECX가 0이 되면 반복 종료.**

구문: `LOOP destination`

```assembly
    mov ax, 0
    mov ecx, 5
L1:
    inc ax
    loop L1                 ; 5번 반복 → AX = 5
```

#### 중첩 루프 (Nested Loops)

ECX가 하나뿐이므로 바깥 루프의 카운트를 변수에 저장/복원해야 함.

```assembly
.data
count DWORD ?
.code
    mov ecx, 100            ; 바깥 루프 카운트 설정
L1:
    mov count, ecx          ; 바깥 루프 카운트 저장
    mov ecx, 20             ; 안쪽 루프 카운트 설정
L2:
    .
    .
    loop L2                 ; 안쪽 루프 반복
    mov ecx, count          ; 바깥 루프 카운트 복원
    loop L1                 ; 바깥 루프 반복
```

---

### 3. 정수 배열 합계 (Summing an Integer Array)

#### 처리 순서

1. 배열의 시작 주소를 레지스터에 로드
2. 루프 카운터를 배열 길이로 초기화
3. 합계 레지스터를 0으로 초기화
4. 루프 시작 레이블 생성
5. 현재 원소를 합계에 더함
6. 다음 원소를 가리키도록 레지스터 증가
7. LOOP 명령어로 반복

```assembly
; Summing an Array (SumArray.asm)

.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
intarray DWORD 10000h, 20000h, 30000h, 40000h

.code
main PROC
    mov edi, OFFSET intarray    ; 1: EDI = intarray 주소
    mov ecx, LENGTHOF intarray  ; 2: 루프 카운터 초기화
    mov eax, 0                  ; 3: sum = 0
L1:                             ; 4: 루프 시작
    add eax, [edi]              ; 5: 정수 더하기
    add edi, TYPE intarray      ; 6: 다음 원소 가리키기
    loop L1                     ; 7: ECX = 0이 될 때까지 반복

    INVOKE ExitProcess, 0
main ENDP
END main
```

---

### 4. 문자열 복사 (Copying a String)

```assembly
; Copying a String (CopyStr.asm)

.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
source BYTE "This is the source string", 0
target BYTE SIZEOF source DUP(0), 0

.code
main PROC
    mov esi, 0                  ; 인덱스 레지스터
    mov ecx, SIZEOF source      ; 루프 카운터
L1:
    mov al, source[esi]         ; source에서 문자 하나 가져오기
    mov target[esi], al         ; target에 저장
    inc esi                     ; 다음 문자로 이동
    loop L1                     ; 문자열 전체 반복

    INVOKE ExitProcess, 0
main ENDP
END main
```

* 메모리 → 메모리 직접 이동이 불가능하므로 `AL`을 거쳐 복사함.

---

## 4.6 주요 요약 및 학습 키워드 (Key Terms)

* **MOV**: source → destination 복사. 두 피연산자 크기 동일, 메모리-메모리 불가, `EIP`는 destination 불가.

* **MOVZX / MOVSX**: 작은 값을 큰 레지스터로 복사하며 상위 비트를 0(Zero-Extend) 또는 부호 비트(Sign-Extend)로 채움.

* **XCHG**: 두 피연산자 값 교환 (메모리끼리는 불가).

* **Direct-Offset Operand**: `[변수 + 오프셋]` 형태로 레이블 없는 위치에 접근.

* **INC / DEC / ADD / SUB / NEG**: 산술 명령어. INC/DEC는 CF에 영향 없음, NEG는 2의 보수로 부호 반전.

* **Status Flags**: CF(부호 없는 오버플로), ZF(결과 0), SF(결과 음수), OF(부호 있는 오버플로), AC(비트 3 올림), PF(하위 바이트 1의 개수 짝수).

* **OFFSET / PTR / TYPE / LENGTHOF / SIZEOF**: 주소, 크기 재정의, 원소 크기, 원소 개수, 전체 바이트 수.

* **ALIGN / LABEL**: 경계 정렬 / 저장 공간 없이 레이블에 크기 속성 부여.

* **Indirect / Indexed Operand**: `[reg]`, `constant[reg]`, `arrayD[esi*4]` 형태의 주소 지정.

* **Pointer / TYPEDEF**: 다른 변수의 주소를 담는 변수 / 사용자 정의 타입(포인터 타입) 생성.

* **JMP / LOOP**: 무조건 분기 / ECX를 감소시키며 0이 될 때까지 반복.
