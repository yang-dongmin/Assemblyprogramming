# 1112

## 9.2 문자열 기본 명령어 (String Primitive Instructions)

### 1. 문자열 기본 명령어 개요

32비트 모드에서 Table 9-1의 각 명령어는 메모리 주소 지정에 **ESI, EDI 또는 둘 다를 암묵적으로** 사용함. **누산기(accumulator)** 는 명령어의 데이터 크기에 따라 **AL, AX, EAX** 중 하나를 의미함.

문자열 기본 명령어는 **자동으로 반복하고 배열 인덱스를 증가**시키므로 효율적으로 실행됨. 이름은 "문자열"이지만 문자 배열에만 쓰이는 것이 아니라 **바이트, 워드, 더블워드 배열** 모두에 사용 가능함.

#### Table 9-1. String Primitive Instructions

| 명령어 | 설명 |
| --- | --- |
| **MOVSB, MOVSW, MOVSD** | Move string data: ESI가 가리키는 메모리의 데이터를 EDI가 가리키는 메모리로 **복사** |
| **CMPSB, CMPSW, CMPSD** | Compare strings: ESI와 EDI가 가리키는 두 메모리 위치의 내용을 **비교** |
| **SCASB, SCASW, SCASD** | Scan string: 누산기(AL, AX, EAX)와 EDI가 가리키는 메모리 내용을 **비교** |
| **STOSB, STOSW, STOSD** | Store string data: 누산기 내용을 EDI가 가리키는 메모리에 **저장** |
| **LODSB, LODSW, LODSD** | Load accumulator from string: ESI가 가리키는 메모리를 누산기로 **로드** |

* 접미사 **B / W / D** = Byte(1) / Word(2) / Doubleword(4) 단위.

| 명령어 | 사용 레지스터 |
| --- | --- |
| MOVS, CMPS | ESI(source), EDI(destination) 둘 다 |
| SCAS, STOS | EDI + 누산기 |
| LODS | ESI + 누산기 |

---

### 2. 반복 접두사 (Using a Repeat Prefix)

문자열 기본 명령어 **혼자서는 메모리 값 하나(또는 한 쌍)만** 처리함. **반복 접두사(repeat prefix)** 를 붙이면 **ECX를 카운터**로 사용하여 명령어를 반복함 → **명령어 하나로 배열 전체를 처리**할 수 있음.

| 접두사 | 반복 조건 |
| --- | --- |
| **REP** | ECX > 0 인 동안 반복 |
| **REPZ, REPE** | Zero 플래그가 **set(1)** 이고 ECX > 0 인 동안 반복 (같은 동안) |
| **REPNZ, REPNE** | Zero 플래그가 **clear(0)** 이고 ECX > 0 인 동안 반복 (다른 동안) |

#### Example: Copy a String

```assembly
cld                             ; clear direction flag
mov   esi,OFFSET string1        ; ESI points to source
mov   edi,OFFSET string2        ; EDI points to target
mov   ecx,10                    ; set counter to 10
rep   movsb                     ; move 10 bytes
```

* 반복 접두사는 실행 전에 **ECX > 0 인지 먼저 검사**함. ECX = 0이면 명령어를 무시하고 다음 줄로 넘어감.
* ECX > 0이면 **ECX를 1 감소**시키고 명령어를 반복함.
* MOVSB가 반복될 때 ESI와 EDI는 **자동으로 증가**하며, 이 동작은 CPU의 **Direction 플래그**가 제어함.

```
REP MOVSB 동작 (DF = 0, ECX = 10)

반복  ┌─ ECX = 0? ── 예 ──→ 종료
      │      │ 아니오
      │      ▼
      │  [EDI] ← [ESI]  (1바이트 복사)
      │  ESI++, EDI++
      │  ECX--
      └──────┘
```

---

### 3. 방향 플래그 (Direction Flag)

문자열 기본 명령어는 **Direction 플래그(DF)** 상태에 따라 ESI와 EDI를 **증가 또는 감소**시킴. DF는 CLD와 STD 명령어로 명시적으로 바꿀 수 있음.

```assembly
CLD             ; clear Direction flag (forward direction)
STD             ; set Direction flag (reverse direction)
```

#### Table 9-2. Direction Flag Usage in String Primitive Instructions

| Direction 플래그 값 | ESI, EDI에 대한 효과 | 주소 진행 순서 |
| --- | --- | --- |
| Clear (DF = 0) | 증가 (Incremented) | 낮은 주소 → 높은 주소 (Low-high) |
| Set (DF = 1) | 감소 (Decremented) | 높은 주소 → 낮은 주소 (High-low) |

* 문자열 기본 명령어를 쓰기 전에 **DF를 설정하는 것을 잊으면**, ESI와 EDI가 의도와 반대 방향으로 움직여 큰 문제가 생길 수 있음 → 보통 **`cld` 를 먼저 실행**함.

---

### 4. MOVSB, MOVSW, MOVSD

MOVSB, MOVSW, MOVSD는 **ESI가 가리키는 메모리 위치의 데이터를 EDI가 가리키는 메모리 위치로 복사**함. 두 레지스터는 DF 값에 따라 자동으로 증가 또는 감소함.

| 명령어 | 설명 | ESI, EDI 증감 크기 |
| --- | --- | --- |
| **MOVSB** | Move (copy) bytes | 1 |
| **MOVSW** | Move (copy) words | 2 |
| **MOVSD** | Move (copy) doublewords | 4 |

#### Example: Copy Doubleword Array

20개의 doubleword 정수를 source에서 target으로 복사함.

```assembly
.data
source DWORD 20 DUP(0FFFFFFFFh)
target DWORD 20 DUP(?)
.code
cld                             ; direction = forward
mov   ecx,LENGTHOF source       ; set REP counter
mov   esi,OFFSET source         ; ESI points to source
mov   edi,OFFSET target         ; EDI points to target
rep   movsd                     ; copy doublewords
```

* 복사가 끝나면 ESI와 EDI는 각 배열의 **끝에서 한 칸(4바이트) 뒤**를 가리킴.
* `rep movsd` 는 다음 루프와 같은 일을 명령어 하나로 수행함.

```assembly
L1: mov   eax,[esi]
    mov   [edi],eax
    add   esi,4
    add   edi,4
    loop  L1
```

---

### 5. CMPSB, CMPSW, CMPSD

CMPSB, CMPSW, CMPSD는 **ESI가 가리키는 메모리 피연산자와 EDI가 가리키는 메모리 피연산자를 비교**함.

| 명령어 | 설명 |
| --- | --- |
| **CMPSB** | Compare bytes |
| **CMPSW** | Compare words |
| **CMPSD** | Compare doublewords |

* 플래그는 `CMP [esi], [edi]` 를 한 것처럼 설정됨 (즉, **source − target** 을 계산하여 플래그만 설정). 일반 CMP는 메모리 대 메모리 비교가 불가능하지만 CMPS는 가능함.

#### Example: Comparing Doublewords

```assembly
.data
source DWORD 1234h
target DWORD 5678h
.code
mov   esi,OFFSET source
mov   edi,OFFSET target
cmpsd                           ; compare doublewords
ja    L1                        ; jump if source > target
```

* source(1234h) < target(5678h) 이므로 **JA는 L1으로 점프하지 않음**.

#### 여러 doubleword 비교

DF를 지우고(정방향), ECX를 카운터로 초기화한 뒤 CMPSD에 반복 접두사를 사용함.

```assembly
mov   esi,OFFSET source
mov   edi,OFFSET target
cld                             ; direction = forward
mov   ecx,LENGTHOF source       ; repetition counter
repe  cmpsd                     ; repeat while equal
```

* **REPE** 는 ESI와 EDI를 자동으로 증가시키면서, **ECX가 0이 되거나 서로 다른 doubleword 쌍을 찾을 때까지** 비교를 반복함.
* 반복이 끝난 후 ZF = 1이면 모두 같음, ZF = 0이면 서로 다른 값을 찾은 것.

---

### 6. SCASB, SCASW, SCASD

SCASB, SCASW, SCASD는 **AL / AX / EAX의 값을 EDI가 가리키는 byte / word / doubleword와 비교**함. 문자열이나 배열에서 **특정 값 하나를 찾을 때** 유용함.

* **REPE(REPZ)** 와 함께 쓰면: ECX > 0이고 누산기 값이 메모리 값과 **같은 동안** 계속 스캔.
* **REPNE(REPNZ)** 와 함께 쓰면: 누산기 값과 **일치하는 값을 찾거나** ECX = 0이 될 때까지 스캔.

#### Scan for a Matching Character

문자열 alpha에서 문자 **'F'** 를 찾음.

```assembly
.data
alpha BYTE "ABCDEFGH",0
.code
mov   edi,OFFSET alpha          ; EDI points to the string
mov   al,'F'                    ; search for the letter F
mov   ecx,LENGTHOF alpha        ; set the search count
cld                             ; direction = forward
repne scasb                     ; repeat while not equal
jnz   quit                      ; quit if letter not found
dec   edi                       ; found: back up EDI
```

```
 alpha:  A   B   C   D   E   F   G   H   0
        +0  +1  +2  +3  +4  +5  +6  +7  +8
                             ▲   ▲
                             │   └─ REPNE SCASB 종료 직후 EDI (일치한 문자 다음 칸)
                             └───── dec edi 후 EDI ('F'의 위치)
```

* 문자를 찾으면 SCASB가 비교 후에도 EDI를 증가시키므로 EDI는 **일치한 문자의 한 칸 뒤**를 가리킴 → `dec edi` 로 되돌림.
* **JNZ** 는 루프가 "찾아서"가 아니라 **ECX = 0이 되어** 끝난 경우(ZF = 0, 못 찾음)를 검사하기 위해 추가함.

---

### 7. STOSB, STOSW, STOSD

STOSB, STOSW, STOSD는 **AL / AX / EAX의 내용을 EDI가 가리키는 메모리에 저장**함. EDI는 DF에 따라 증가 또는 감소함.

* **REP** 접두사와 함께 쓰면 문자열이나 배열의 **모든 원소를 하나의 값으로 채울 때** 유용함.

```assembly
.data
Count = 100
string1 BYTE Count DUP(?)
.code
mov   al,0FFh                   ; value to be stored
mov   edi,OFFSET string1        ; EDI points to target
mov   ecx,Count                 ; character count
cld                             ; direction = forward
rep   stosb                     ; fill with contents of AL
```

* string1의 **각 바이트(100개)를 0FFh로 초기화**함.

---

### 8. LODSB, LODSW, LODSD

LODSB, LODSW, LODSD는 **ESI가 가리키는 메모리에서 byte / word / doubleword를 AL / AX / EAX로 로드**함. ESI는 DF에 따라 증가 또는 감소함.

* 새 값을 로드할 때마다 누산기의 이전 값을 덮어쓰므로 **REP 접두사는 거의 사용하지 않음**. 보통 값 하나를 로드하는 데 사용함.
* DF = 0일 때 `lodsb` 는 다음 두 명령어를 대신함.

```assembly
mov   al,[esi]                  ; move byte into AL
inc   esi                       ; point to next byte
```

#### Array Multiplication Example (Mult.asm)

doubleword 배열의 **각 원소에 상수를 곱함**. LODSD와 STOSD가 함께 동작함.

```assembly
; Multiply an Array                 (Mult.asm)
; This program multiplies each element of an array
; of 32-bit integers by a constant value.
INCLUDE Irvine32.inc
.data
array      DWORD 1,2,3,4,5,6,7,8,9,10   ; test data
multiplier DWORD 10                     ; test data
.code
main PROC
    cld                         ; direction = forward
    mov   esi,OFFSET array      ; source index
    mov   edi,esi               ; destination index
    mov   ecx,LENGTHOF array    ; loop counter
L1: lodsd                       ; load [ESI] into EAX
    mul   multiplier            ; multiply by a value
    stosd                       ; store EAX into [EDI]
    loop  L1
    exit
main ENDP
END main
```

* ESI와 EDI가 **같은 배열**을 가리키므로, 읽은 자리에 곱한 결과를 다시 저장함.
* 실행 후 array = `10, 20, 30, 40, 50, 60, 70, 80, 90, 100`

| 반복 | LODSD (EAX ← [ESI]) | MUL 후 EAX | STOSD ([EDI] ← EAX) |
| --- | --- | --- | --- |
| 1 | 1 | 10 | array[0] = 10 |
| 2 | 2 | 20 | array[1] = 20 |
| ... | ... | ... | ... |
| 10 | 10 | 100 | array[9] = 100 |

---

## 9.3 주요 문자열 프로시저 (Selected String Procedures)

Irvine32 라이브러리에서 **널 종료 문자열(null-terminated string)** 을 다루는 프로시저들. 표준 C 라이브러리 함수와 비슷함.

```assembly
; Copy a source string to a target string.
Str_copy PROTO,
    source:PTR BYTE,
    target:PTR BYTE

; Return the length of a string (excluding the null byte) in EAX.
Str_length PROTO,
    pString:PTR BYTE

; Compare string1 to string2. Set the Zero and
; Carry flags in the same way as the CMP instruction.
Str_compare PROTO,
    string1:PTR BYTE,
    string2:PTR BYTE

; Trim a given trailing character from a string.
; The second argument is the character to trim.
Str_trim PROTO,
    pString:PTR BYTE,
    char:BYTE

; Convert a string to upper case.
Str_ucase PROTO,
    pString:PTR BYTE
```

| 프로시저 | C 라이브러리 대응 | 기능 |
| --- | --- | --- |
| **Str_compare** | `strcmp` | 두 문자열 비교 (플래그로 결과) |
| **Str_length** | `strlen` | 문자열 길이를 EAX로 반환 |
| **Str_copy** | `strcpy` | 문자열 복사 |
| **Str_trim** | - | 끝에 붙은 특정 문자 제거 |
| **Str_ucase** | - | 대문자로 변환 |

---

### 1. Str_compare 프로시저

```assembly
INVOKE Str_compare, ADDR string1, ADDR string2
```

* 첫 바이트부터 **정방향**으로 비교함.
* 대문자와 소문자의 ASCII 코드가 다르므로 **대소문자를 구분(case sensitive)** 함.
* 값을 반환하지 않고, **Carry 플래그와 Zero 플래그**로 결과를 알려 줌.

#### Table 9-3. Flags Affected by the Str_compare Procedure

| 관계 | Carry 플래그 | Zero 플래그 | 참일 때 분기 |
| --- | --- | --- | --- |
| string1 < string2 | 1 | 0 | **JB** |
| string1 = string2 | 0 | 1 | **JE** |
| string1 > string2 | 0 | 0 | **JA** |

```assembly
;-----------------------------------------------------------
Str_compare PROC USES eax edx esi edi,
    string1:PTR BYTE,
    string2:PTR BYTE
;
; Compares two strings.
; Returns nothing, but the Zero and Carry flags are affected
; exactly as they would be by the CMP instruction.
;-----------------------------------------------------------
    mov   esi,string1
    mov   edi,string2
L1: mov   al,[esi]
    mov   dl,[edi]
    cmp   al,0                  ; end of string1?
    jne   L2                    ; no
    cmp   dl,0                  ; yes: end of string2?
    jne   L2                    ; no
    jmp   L3                    ; yes, exit with ZF = 1

L2: inc   esi                   ; point to next
    inc   edi
    cmp   al,dl                 ; characters equal?
    je    L1                    ; yes: continue loop
                                ; no: exit with flags set
L3: ret
Str_compare ENDP
```

* 두 문자열이 **동시에 널(0)에 도달**하면 같은 문자열 → ZF = 1로 종료.
* 문자가 다르면 마지막 `cmp al, dl` 의 플래그가 그대로 남아 결과가 됨.
* 한쪽만 먼저 끝나면 널(0)과 다른 문자를 비교하게 되어 **짧은 쪽이 작다**고 판정됨 (예: "ABC" < "ABCD").
* `inc` 는 CF에 영향을 주지 않으므로, `cmp al, dl` 직전에 `inc` 를 해도 결과 플래그가 유지됨.

> CMPSB는 길이를 미리 아는 **큰 문자열이나 배열**을 다룰 때 가장 효과적임. (널 종료 문자열은 길이를 모르므로 Str_compare는 직접 루프로 비교함)

---

### 2. Str_length 프로시저

Str_length는 문자열의 길이를 **EAX** 로 반환함. 호출할 때 문자열의 **오프셋**을 전달함.

```assembly
INVOKE Str_length, ADDR myString
```

```assembly
Str_length PROC USES edi,
    pString:PTR BYTE            ; pointer to string
    mov   edi,pString
    mov   eax,0                 ; character count
L1: cmp   BYTE PTR [edi],0      ; end of string?
    je    L2                    ; yes: quit
    inc   edi                   ; no: point to next
    inc   eax                   ; add 1 to count
    jmp   L1
L2: ret
Str_length ENDP
```

* 널 바이트를 만날 때까지 한 문자씩 세며, **널 바이트는 길이에 포함하지 않음**.

---

### 3. Str_copy 프로시저

Str_copy는 널 종료 문자열을 **source 위치에서 target 위치로 복사**함. 호출 전에 target이 복사될 문자열을 담을 만큼 **충분히 큰지 확인**해야 함.

```assembly
INVOKE Str_copy, ADDR source, ADDR target
```

```assembly
;-----------------------------------------------------------
Str_copy PROC USES eax ecx esi edi,
    source:PTR BYTE,            ; source string
    target:PTR BYTE             ; target string
;
; Copies a string from source to target.
; Requires: the target string must contain enough
;           space to hold a copy of the source string.
;-----------------------------------------------------------
    INVOKE Str_length,source    ; EAX = length source
    mov   ecx,eax               ; REP count
    inc   ecx                   ; add 1 for null byte
    mov   esi,source
    mov   edi,target
    cld                         ; direction = forward
    rep   movsb                 ; copy the string
    ret
Str_copy ENDP
```

* Str_length로 길이를 구한 뒤 **널 바이트까지 복사하기 위해 +1** 하고, `rep movsb` 로 한 번에 복사함.

---

### 4. Str_trim 프로시저

Str_trim은 널 종료 문자열의 **끝에 붙은 특정 문자(trailing character)를 모두 제거**함.

```assembly
INVOKE Str_trim, ADDR string, char_to_trim
```

#### 고려해야 할 경우들

1. 문자열이 비어 있는 경우.
2. 다른 문자 뒤에 제거할 문자가 하나 이상 붙은 경우 (예: `"Hello##"`).
3. 제거할 문자 하나만 있는 경우 (예: `"#"`).
4. 제거할 문자가 없는 경우 (예: `"Hello"`, `"H"`).
5. 제거할 문자 뒤에 다른 문자가 오는 경우 (예: `"#H"`, `"###Hello"`).

```assembly
.data
string_1 BYTE "Hello##",0
.code
INVOKE Str_trim,ADDR string_1,'#'
INVOKE ShowString,ADDR string_1
```

#### 구현

```assembly
;-----------------------------------------------------------
; Str_trim
; Remove all occurrences of a given delimiter
; character from the end of a string.
; Returns: nothing
;-----------------------------------------------------------
Str_trim PROC USES eax ecx edi,
    pString:PTR BYTE,           ; points to string
    char:BYTE                   ; character to remove

    mov   edi,pString           ; prepare to call Str_length
    INVOKE Str_length,edi       ; returns the length in EAX
    cmp   eax,0                 ; is the length equal to zero?
    je    L3                    ; yes: exit now
    mov   ecx,eax               ; no: ECX = string length
    dec   eax
    add   edi,eax               ; point to last character

L1: mov   al,[edi]              ; get a character
    cmp   al,char               ; is it the delimiter?
    jne   L2                    ; no: insert null byte
    dec   edi                   ; yes: keep backing up
    loop  L1                    ; until beginning reached

L2: mov   BYTE PTR [edi+1],0    ; insert a null byte
L3: ret
Str_trim ENDP
```

* 슬라이드의 `Stmr_trim ENDP` 는 `Str_trim ENDP` 의 오타.

#### Table 9-4. Testing the Str_trim Procedure with a # Delimiter Character

| 입력 문자열 | 기대 결과 |
| --- | --- |
| `"Hello##"` | `"Hello"` |
| `"#"` | `""` (빈 문자열) |
| `"Hello"` | `"Hello"` |
| `"H"` | `"H"` |
| `"#H"` | `"#H"` |

#### 상세 설명 (Detailed Description)

알고리즘은 **문자열 끝에서부터 거꾸로 스캔**하며 **구분 문자(delimiter)가 아닌 첫 문자**를 찾음. 찾으면 그 문자 **바로 다음 위치에 널 바이트를 삽입**함.

```
ecx = length(str)
if length(str) > 0 then
    edi = length - 1
    do while ecx > 0
        if str[edi] ≠ delimiter then
            str[edi+1] = null
            break
        else
            edi = edi - 1
        end if
        ecx = ecx - 1
    end do
```

#### "Hello##" 추적

```
 인덱스:   0   1   2   3   4   5   6   7
 문자:     H   e   l   l   o   #   #   0
                               ▲   ▲
                               │   └─ ① 시작 EDI (마지막 문자 '#') → 구분 문자, 뒤로
                               └───── ② '#' → 구분 문자, 뒤로
                           ▲
                           └───────── ③ 'o' → 구분 문자 아님 → [EDI+1] = 0

 결과:     H   e   l   l   o   0   #   0    → "Hello"
```

* `"#"` 의 경우: '#' 하나를 건너뛰고 `loop` 가 끝나면 EDI = 문자열 시작 − 1 이 되므로, `[edi+1]` = 문자열 첫 바이트에 널을 넣어 **빈 문자열**이 됨.

---

### 5. Str_ucase 프로시저

Str_ucase는 문자열을 **모두 대문자로 변환**함. 반환값은 없음.

```assembly
INVOKE Str_ucase, ADDR myString
```

```assembly
;-----------------------------------------------------------
; Str_ucase
; Converts a null-terminated string to uppercase.
; Returns: nothing
;-----------------------------------------------------------
Str_ucase PROC USES eax esi,
    pString:PTR BYTE

    mov   esi,pString
L1:
    mov   al,[esi]                      ; get char
    cmp   al,0                          ; end of string?
    je    L3                            ; yes: quit
    cmp   al,'a'                        ; below "a"?
    jb    L2
    cmp   al,'z'                        ; above "z"?
    ja    L2
    and   BYTE PTR [esi],11011111b      ; convert the char
L2: inc   esi                           ; next char
    jmp   L1

L3: ret
Str_ucase ENDP
```

* 'a' ~ 'z' 범위의 문자만 변환함.
* 소문자와 대문자는 **비트 5만 다름** (`'a' = 61h = 01100001b`, `'A' = 41h = 01000001b`) → `AND 11011111b` 로 비트 5를 지우면 대문자가 됨.

(Ucase.asm 프로그램에서 이 프로시저의 사용 예를 볼 수 있음)

---

### 6. 문자열 라이브러리 데모 프로그램 (String Library Demo Program)

```assembly
; String Library Demo               (StringDemo.asm)
; This program demonstrates the string-handling procedures in
; the book's link library.
INCLUDE Irvine32.inc
.data
string_1 BYTE "abcde////",0
string_2 BYTE "ABCDE",0
msg0     BYTE "string_1 in upper case: ",0
msg1     BYTE "string_1 and string_2 are equal",0
msg2     BYTE "string_1 is less than string_2",0
msg3     BYTE "string_2 is less than string_1",0
msg4     BYTE "Length of string_2 is ",0
msg5     BYTE "string_1 after trimming: ",0
.code
main PROC
    call  trim_string
    call  upper_case
    call  compare_strings
    call  print_length
    exit
main ENDP

trim_string PROC
; Remove trailing characters from string_1.
    INVOKE Str_trim, ADDR string_1, '/'
    mov   edx,OFFSET msg5
    call  WriteString
    mov   edx,OFFSET string_1
    call  WriteString
    call  Crlf
    ret
trim_string ENDP

upper_case PROC
; Convert string_1 to upper case.
    mov   edx,OFFSET msg0
    call  WriteString
    INVOKE Str_ucase, ADDR string_1
    mov   edx,OFFSET string_1
    call  WriteString
    call  Crlf
    ret
upper_case ENDP

compare_strings PROC
; Compare string_1 to string_2.
    INVOKE Str_compare, ADDR string_1, ADDR string_2
    .IF ZERO?
    mov   edx,OFFSET msg1
    .ELSEIF CARRY?
    mov   edx,OFFSET msg2       ; string 1 is less than...
    .ELSE
    mov   edx,OFFSET msg3       ; string 2 is less than...
    .ENDIF
    call  WriteString
    call  Crlf
    ret
compare_strings ENDP

print_length PROC
; Display the length of string_2.
    mov   edx,OFFSET msg4
    call  WriteString
    INVOKE Str_length, ADDR string_2
    call  WriteDec
    call  Crlf
    ret
print_length ENDP
END main
```

#### 실행 흐름

| 단계 | 동작 | string_1 상태 |
| --- | --- | --- |
| trim_string | 끝의 `'/'` 4개 제거 | `"abcde"` |
| upper_case | 대문자로 변환 | `"ABCDE"` |
| compare_strings | `"ABCDE"` 와 `"ABCDE"` 비교 → ZF = 1 | - |
| print_length | string_2의 길이 = 5 | - |

#### 실행 결과

```
string_1 after trimming: abcde
string_1 in upper case: ABCDE
string_1 and string_2 are equal
Length of string_2 is 5
```

* `.IF ZERO?`, `.ELSEIF CARRY?` 는 MASM의 조건부 지시어로, Str_compare가 남긴 **ZF / CF** 를 검사함 (Table 9-3).

---

## 9.4 2차원 배열 (Two-Dimensional Arrays)

### 1. 행과 열의 순서 (Ordering of Rows and Columns)

2차원 배열은 메모리에 1차원으로 저장되며, 저장 순서에 따라 두 가지 방식이 있음.

#### Figure 9-1. Row-major and column-major ordering

```
Logical arrangement (3행 × 5열):

        ┌────┬────┬────┬────┬────┐
        │ 10 │ 20 │ 30 │ 40 │ 50 │
        ├────┼────┼────┼────┼────┤
        │ 60 │ 70 │ 80 │ 90 │ A0 │
        ├────┼────┼────┼────┼────┤
        │ B0 │ C0 │ D0 │ E0 │ F0 │
        └────┴────┴────┴────┴────┘

Row-major order (행 우선):
┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐
│ 10 │ 20 │ 30 │ 40 │ 50 │ 60 │ 70 │ 80 │ 90 │ A0 │ B0 │ C0 │ D0 │ E0 │ F0 │
└────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┘
 └────── 0행 ──────────┘ └────── 1행 ──────────┘ └────── 2행 ──────────┘

Column-major order (열 우선):
┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐
│ 10 │ 60 │ B0 │ 20 │ 70 │ C0 │ 30 │ 80 │ D0 │ 40 │ 90 │ E0 │ 50 │ A0 │ F0 │
└────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┘
 └── 0열 ──┘ └── 1열 ──┘ └── 2열 ──┘ └── 3열 ──┘ └── 4열 ──┘
```

| 방식 | 설명 | 원소 [r][c] 의 위치 |
| --- | --- | --- |
| **Row-major** | 첫 행을 모두 저장한 뒤 다음 행 저장 (C/C++, 어셈블리에서 주로 사용) | `r × 열 개수 + c` |
| **Column-major** | 첫 열을 모두 저장한 뒤 다음 열 저장 (Fortran 등) | `c × 행 개수 + r` |

---

### 2. 베이스-인덱스 피연산자 (Base-Index Operands)

**베이스-인덱스 피연산자**는 두 레지스터(**base** 와 **index**)의 값을 더해 오프셋 주소를 만듦.

```assembly
[base + index]
```

```assembly
.data
array WORD 1000h,2000h,3000h
.code
mov   ebx,OFFSET array
mov   esi,2
mov   ax,[ebx+esi]              ; AX = 2000h

mov   edi,OFFSET array
mov   ecx,4
mov   ax,[edi+ecx]              ; AX = 3000h

mov   ebp,OFFSET array
mov   esi,0
mov   ax,[ebp+esi]              ; AX = 1000h
```

* 32비트 범용 레지스터 어느 것이든 base와 index로 사용할 수 있음.
* WORD 배열이므로 인덱스 레지스터에는 **바이트 오프셋**(0, 2, 4)을 넣음.

#### 2차원 배열 접근 (Two-Dimensional Array)

**행 우선(row-major)** 2차원 배열에서는 **행 오프셋을 base 레지스터**에, **열 오프셋을 index 레지스터**에 둠.

```assembly
tableB  BYTE  10h,  20h,  30h,  40h,  50h
Rowsize = ($ - tableB)
        BYTE  60h,  70h,  80h,  90h, 0A0h
        BYTE 0B0h, 0C0h, 0D0h, 0E0h, 0F0h

row_index = 1
column_index = 2

mov   ebx,OFFSET tableB         ; table offset
add   ebx,RowSize * row_index   ; row offset
mov   esi,column_index
mov   al,[ebx + esi]            ; AL = 80h
```

* `Rowsize = ($ - tableB)` : 첫 행 정의 직후의 위치 카운터(`$`)에서 시작 주소를 빼서 **한 행의 바이트 수(5)** 를 구함.

#### Figure 9-2. Addressing an array with a base-index operand

```
 0150                 0155       0157
  │                     │          │
┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐
│ 10 │ 20 │ 30 │ 40 │ 50 │ 60 │ 70 │ 80 │ 90 │ A0 │ B0 │ C0 │ D0 │ E0 │ F0 │
└────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┘
                          ▲         ▲
                        [ebx]   [ebx+esi]
```

* tableB가 0150h에서 시작한다고 하면, `EBX = 0150h + 5 × 1 = 0155h` (1행 시작), `EBX + ESI = 0155h + 2 = 0157h` → **80h**.

---

### 3. 행 합계 계산 (Calculating a Row Sum)

8비트 정수 행렬에서 **선택한 행의 합**을 계산함.

```assembly
;----------------------------------------------------------
; calc_row_sum
; Calculates the sum of a row in a byte matrix.
; Receives: EBX = table offset, EAX = row index,
;           ECX = row size, in bytes.
; Returns: EAX holds the sum.
;----------------------------------------------------------
calc_row_sum PROC USES ebx ecx edx esi
    mul   ecx                           ; row index * row size
    add   ebx,eax                       ; row offset
    mov   eax,0                         ; accumulator
    mov   esi,0                         ; column index
L1: movzx edx,BYTE PTR[ebx + esi]       ; get a byte
    add   eax,edx                       ; add to accumulator
    inc   esi                           ; next byte in row
    loop  L1
    ret
calc_row_sum ENDP
```

* `mul ecx` 로 **행 인덱스 × 행 크기 = 행 오프셋**을 구해 EBX에 더함.
* ESI(열 인덱스)를 0부터 증가시키며 `[ebx + esi]` 로 한 행의 원소를 차례로 읽음.
* `MOVZX` 로 바이트를 32비트로 0 확장한 뒤 더함 → 합이 255를 넘어도 안전함.
* ECX(행 크기)는 루프 카운터로도 쓰임.
* 예: tableB에서 1행 합계 = 60h + 70h + 80h + 90h + A0h = **190h** (400)

---

### 4. 스케일 팩터 (Scale Factors)

**WORD 배열**이면 인덱스 피연산자에 **스케일 팩터 2**를 곱해야 함.

```assembly
tableW  WORD  10h,  20h,  30h,  40h,  50h
RowsizeW = ($ - tableW)
        WORD  60h,  70h,  80h,  90h, 0A0h
        WORD 0B0h, 0C0h, 0D0h, 0E0h, 0F0h
.code
row_index = 1
column_index = 2
mov   ebx,OFFSET tableW             ; table offset
add   ebx,RowSizeW * row_index      ; row offset
mov   esi,column_index
mov   ax,[ebx + esi*TYPE tableW]    ; AX = 0080h
```

* RowsizeW = 10 (WORD 5개 × 2바이트).
* `esi*TYPE tableW` = 2 × 2 = 4 → 1행 시작에서 4바이트 뒤 → **0080h**.

DWORD 배열이면 스케일 팩터 4를 사용함.

```assembly
tableD DWORD 10h, 20h, ...etc.
.code
mov   eax,[ebx + esi*TYPE tableD]
```

* 스케일 팩터는 **1, 2, 4, 8** 만 가능하며, `TYPE` 연산자를 쓰면 배열 타입이 바뀌어도 코드를 고칠 필요가 없음.

---

### 5. 베이스-인덱스-변위 피연산자 (Base-Index-Displacement Operands)

**베이스-인덱스-변위 피연산자**는 **변위(displacement), 베이스 레지스터, 인덱스 레지스터, 선택적인 스케일 팩터**를 결합하여 유효 주소를 만듦. 변위는 **변수 이름이나 상수 식**이 될 수 있음.

```assembly
[base + index + displacement]
displacement[base + index]
```

#### Doubleword Array Example

```assembly
tableD  DWORD   10h,  20h,  30h,  40h,  50h
Rowsize = ($ - tableD)
        DWORD   60h,  70h,  80h,  90h, 0A0h
        DWORD  0B0h, 0C0h, 0D0h, 0E0h, 0F0h

mov   ebx,Rowsize                   ; row index
mov   esi,2                         ; column index
mov   eax,tableD[ebx + esi*TYPE tableD]
```

#### Figure 9-3. Base-index-displacement example

```
 0150                 0164       016C
  │                     │          │
┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐
│ 10 │ 20 │ 30 │ 40 │ 50 │ 60 │ 70 │ 80 │ 90 │ A0 │ B0 │ C0 │ D0 │ E0 │ F0 │
└────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┘
  ▲                       ▲         ▲
table                 table[ebx]  table[ebx+esi*4]
Rowsize = 0014h
```

| 구성 요소 | 값 | 의미 |
| --- | --- | --- |
| displacement | tableD (0150h) | 배열 시작 주소 |
| base (EBX) | Rowsize = 14h (20) | 1행의 바이트 오프셋 (DWORD 5개 × 4) |
| index (ESI) × scale | 2 × 4 = 8 | 1행 안에서의 열 오프셋 |
| **유효 주소** | 0150h + 14h + 8 = **016Ch** | EAX = **80h** |

* 베이스-인덱스 방식과 달리 배열 이름을 **변위**로 쓰므로, EBX에 OFFSET을 넣지 않고 **행 오프셋만** 넣으면 됨.

| 주소 지정 방식 | 형식 | 예 |
| --- | --- | --- |
| Base-Index | `[base + index]` | `[ebx + esi]` |
| Base-Index (scale) | `[base + index*scale]` | `[ebx + esi*2]` |
| Base-Index-Displacement | `disp[base + index*scale]` | `tableD[ebx + esi*4]` |

---

## 9.5 정수 배열의 검색과 정렬 (Searching and Sorting Integer Arrays)

### 1. 버블 정렬 (Bubble Sort)

버블 정렬은 **0번과 1번 위치부터 시작해 인접한 값의 쌍을 비교**함. 비교한 두 값이 **역순이면 교환**함.

* 한 번의 패스(pass)가 끝나도 배열은 아직 정렬되지 않지만, **가장 큰 값이 가장 높은 인덱스 위치**로 이동함.
* 바깥 루프가 다시 배열을 훑는 패스를 시작하며, **n − 1번의 패스 후에는 반드시 정렬**됨.

#### Figure 9-4. First pass through an array (bubble sort)

```
 비교 →  (3,1)  (3,7)  (7,5)  (7,2)  (7,9)  (9,4)  (9,3)
 시작     ①      ②      ③      ④      ⑤      ⑥      ⑦ (1패스 끝)
 ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌───┐
 │ 3 │  │*1*│  │ 1 │  │ 1 │  │ 1 │  │ 1 │  │ 1 │  │ 1 │
 │ 1 │  │*3*│  │ 3 │  │ 3 │  │ 3 │  │ 3 │  │ 3 │  │ 3 │
 │ 7 │  │ 7 │  │ 7 │  │*5*│  │ 5 │  │ 5 │  │ 5 │  │ 5 │
 │ 5 │  │ 5 │  │ 5 │  │*7*│  │*2*│  │ 2 │  │ 2 │  │ 2 │
 │ 2 │  │ 2 │  │ 2 │  │ 2 │  │*7*│  │ 7 │  │ 7 │  │ 7 │
 │ 9 │  │ 9 │  │ 9 │  │ 9 │  │ 9 │  │ 9 │  │*4*│  │ 4 │
 │ 4 │  │ 4 │  │ 4 │  │ 4 │  │ 4 │  │ 4 │  │*9*│  │*3*│
 │ 3 │  │ 3 │  │ 3 │  │ 3 │  │ 3 │  │ 3 │  │ 3 │  │*9*│
 └───┘  └───┘  └───┘  └───┘  └───┘  └───┘  └───┘  └───┘
                          (*x* = 교환된 값)
```

| 단계 | 비교 쌍 | 교환 | 결과 |
| --- | --- | --- | --- |
| 시작 | - | - | 3 1 7 5 2 9 4 3 |
| ① | 3, 1 | O | 1 3 7 5 2 9 4 3 |
| ② | 3, 7 | X | 1 3 7 5 2 9 4 3 |
| ③ | 7, 5 | O | 1 3 5 7 2 9 4 3 |
| ④ | 7, 2 | O | 1 3 5 2 7 9 4 3 |
| ⑤ | 7, 9 | X | 1 3 5 2 7 9 4 3 |
| ⑥ | 9, 4 | O | 1 3 5 2 7 4 9 3 |
| ⑦ | 9, 3 | O | 1 3 5 2 7 4 3 **9** |

* 1패스 후 가장 큰 값 **9가 맨 끝**으로 이동함 (거품이 위로 떠오르는 것과 같아 "버블" 정렬).

#### 의사 코드 (Pseudocode)

```
cx1 = N - 1
while( cx1 > 0 )
{
    esi = addr(array)
    cx2 = cx1
    while( cx2 > 0 )
    {
        if( array[esi] > array[esi+4] )
            exchange( array[esi], array[esi+4] )
        add esi,4
        dec cx2
    }
    dec cx1
}
```

* 패스가 끝날 때마다 맨 끝 원소가 확정되므로, 안쪽 루프의 비교 횟수(cx2)를 **cx1만큼으로 줄여 나감**.

#### 어셈블리 구현 (Assembly Language)

```assembly
;------------------------------------------------------
; BubbleSort
; Sort an array of 32-bit signed integers in ascending
; order, using the bubble sort algorithm.
; Receives: pointer to array, array size
; Returns: nothing
;------------------------------------------------------
BubbleSort PROC USES eax ecx esi,
    pArray:PTR DWORD,           ; pointer to array
    Count:DWORD                 ; array size

    mov   ecx,Count
    dec   ecx                   ; decrement count by 1
L1: push  ecx                   ; save outer loop count
    mov   esi,pArray            ; point to first value
L2: mov   eax,[esi]             ; get array value
    cmp   [esi+4],eax           ; compare a pair of values
    jg    L3                    ; if [ESI] <= [ESI+4], no exchange
    xchg  eax,[esi+4]           ; exchange the pair
    mov   [esi],eax
L3: add   esi,4                 ; move both pointers forward
    loop  L2                    ; inner loop
    pop   ecx                   ; retrieve outer loop count
    loop  L1                    ; else repeat outer loop
L4: ret
BubbleSort ENDP
```

* 바깥 루프와 안쪽 루프가 모두 **ECX를 공유**하므로, 안쪽 루프 시작 전에 `push ecx` 로 바깥 카운트를 저장하고 끝난 뒤 `pop ecx` 로 복원함.
* 안쪽 루프의 ECX는 바깥 카운트와 같은 값에서 시작 → 의사 코드의 `cx2 = cx1` 과 같음.
* `cmp [esi+4], eax` 후 **JG**(부호 있는 비교)로 `[ESI+4] > [ESI]` 이면 교환하지 않음. (같은 값은 교환하는데, 결과에는 영향 없음)
* `xchg eax,[esi+4]` + `mov [esi],eax` 로 두 값을 교환함.
* 시간 복잡도는 **O(n²)** → 큰 배열에는 비효율적임.

---

### 2. 이진 검색 (Binary Search)

검색을 시작하기 전에 사용자에게 정수를 입력받으며, 이를 **searchVal** 이라 함. (배열은 **정렬되어 있어야** 함)

1. 검색할 배열의 범위는 첨자 **first** 와 **last** 로 나타냄. **first > last** 이면 검색을 종료하고 실패를 알림.
2. first와 last 사이의 **중간점(midpoint)** 을 계산함.
3. searchVal을 중간점의 정수와 비교함.
   * 값이 **같으면** 중간점을 EAX에 담아 반환함 → 배열에서 일치하는 값을 찾았다는 뜻.
   * searchVal이 중간값보다 **크면** first를 **중간점 + 1** 로 재설정.
   * searchVal이 중간값보다 **작으면** last를 **중간점 − 1** 로 재설정.
4. 1단계로 돌아감.

* 비교할 때마다 검색 범위가 **절반**으로 줄어들므로 시간 복잡도는 **O(log n)** (예: 원소 1,024개 → 최대 약 11번 비교).

#### C++ 구현

```cpp
int BinSearch( int values[], const int searchVal, int count )
{
    int first = 0;
    int last = count - 1;

    while( first <= last )
    {
        int mid = (last + first) / 2;
        if( values[mid] < searchVal )
            first = mid + 1;
        else if( values[mid] > searchVal )
            last = mid - 1;
        else
            return mid;         // success
    }
    return -1;                  // not found
}
```

#### 어셈블리 구현

```assembly
;-------------------------------------------------------------
; BinarySearch
; Searches an array of signed integers for a single value.
; Receives: Pointer to array, array size, search value.
; Returns: If a match is found, EAX = the array position of the
; matching element; otherwise, EAX = -1.
;-------------------------------------------------------------
BinarySearch PROC USES ebx edx esi edi,
    pArray:PTR DWORD,           ; pointer to array
    Count:DWORD,                ; array size
    searchVal:DWORD             ; search value
    LOCAL first:DWORD,          ; first position
          last:DWORD,           ; last position
          mid:DWORD             ; midpoint

    mov   first,0               ; first = 0
    mov   eax,Count             ; last = (count - 1)
    dec   eax
    mov   last,eax
    mov   edi,searchVal         ; EDI = searchVal
    mov   ebx,pArray            ; EBX points to the array

L1: ; while first <= last
    mov   eax,first
    cmp   eax,last
    jg    L5                    ; exit search

    ; mid = (last + first) / 2
    mov   eax,last
    add   eax,first
    shr   eax,1
    mov   mid,eax

    ; EDX = values[mid]
    mov   esi,mid
    shl   esi,2                 ; scale mid value by 4
    mov   edx,[ebx+esi]         ; EDX = values[mid]

    ; if ( EDX < searchval(EDI) )
    cmp   edx,edi
    jge   L2
    ; first = mid + 1
    mov   eax,mid
    inc   eax
    mov   first,eax
    jmp   L4

    ; else if( EDX > searchVal(EDI) )
L2: cmp   edx,edi               ; optional
    jle   L3
    ; last = mid - 1
    mov   eax,mid
    dec   eax
    mov   last,eax
    jmp   L4

    ; else return mid
L3: mov   eax,mid               ; value found
    jmp   L9                    ; return (mid)

L4: jmp   L1                    ; continue the loop

L5: mov   eax,-1                ; search failed
L9: ret
BinarySearch ENDP
```

* first, last, mid는 **LOCAL** 지역 변수로 선언함.
* `shr eax, 1` 로 2로 나누어 중간점을 구함.
* `shl esi, 2` 로 인덱스에 4를 곱해 **바이트 오프셋**으로 바꾼 뒤 `[ebx+esi]` 로 접근함 (`[ebx+esi*4]` 와 같음).
* 부호 있는 정수 배열이므로 **JGE, JLE, JG** (signed) 비교를 사용함.
* `L2` 의 `cmp edx,edi` 는 앞의 CMP 플래그가 그대로 남아 있으므로 생략 가능함 (optional).

#### 검색 추적 예

정렬된 배열 `values = [-50, -20, 3, 7, 15, 28, 40, 66]` (Count = 8)에서 **searchVal = 28** 검색:

| 반복 | first | last | mid | values[mid] | 비교 | 다음 동작 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 0 | 7 | 3 | 7 | 7 < 28 | first = 4 |
| 2 | 4 | 7 | 5 | 28 | 같음 | **EAX = 5** 반환 |

같은 배열에서 **searchVal = 10** 검색 (없는 값):

| 반복 | first | last | mid | values[mid] | 비교 | 다음 동작 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 0 | 7 | 3 | 7 | 7 < 10 | first = 4 |
| 2 | 4 | 7 | 5 | 28 | 28 > 10 | last = 4 |
| 3 | 4 | 4 | 4 | 15 | 15 > 10 | last = 3 |
| 4 | 4 | 3 | - | - | first > last | **EAX = -1** 반환 |

---

### 3. 테스트 프로그램 (Test Program)

BubbleSort와 BinarySearch를 함께 사용하는 테스트 프로그램은 다음 순서로 동작함.

1. 배열을 **무작위 정수**로 채움.
2. 배열을 **출력**함.
3. **버블 정렬**로 배열을 정렬함.
4. 배열을 **다시 출력**함.
5. 사용자에게 **정수를 입력**받음.
6. 배열에서 사용자가 입력한 정수를 **이진 검색**함.
7. 이진 검색 **결과를 출력**함.

```
[무작위로 채우기] → [출력] → [BubbleSort] → [다시 출력]
        → [정수 입력] → [BinarySearch] → [결과 출력]
```

* 이진 검색은 **정렬된 배열**에서만 동작하므로 반드시 정렬을 먼저 해야 함.

---

## 9.8 주요 요약 및 학습 키워드 (Key Terms and Instructions)

* **String Primitive Instructions**: ESI, EDI를 암묵적으로 사용하고 자동으로 증감하는 명령어. 바이트·워드·더블워드 배열 모두에 사용.

* **MOVS / CMPS / SCAS / STOS / LODS**: 복사([ESI]→[EDI]) / 비교([ESI]와 [EDI]) / 스캔(누산기와 [EDI]) / 저장(누산기→[EDI]) / 로드([ESI]→누산기). 접미사 B·W·D에 따라 1·2·4씩 증감.

* **Repeat Prefix**: ECX를 카운터로 반복. REP(ECX > 0), REPE/REPZ(같은 동안), REPNE/REPNZ(다른 동안).

* **Direction Flag**: CLD(DF = 0) → ESI, EDI 증가(정방향), STD(DF = 1) → 감소(역방향). 문자열 명령어 사용 전에 반드시 설정.

* **REPNE SCASB**: 문자 검색. 찾으면 EDI가 일치한 문자 다음을 가리키므로 `dec edi`, 못 찾으면 ZF = 0 (JNZ로 검사).

* **REP STOSB**: 배열 전체를 같은 값으로 채움. **LODSD + STOSD**: 배열을 읽고 가공해 다시 저장.

* **Str_compare / Str_length / Str_copy / Str_trim / Str_ucase**: Irvine32의 널 종료 문자열 프로시저. Str_compare는 CMP처럼 CF·ZF로 결과를 알려 줌 (JB / JE / JA).

* **Row-major / Column-major**: 2차원 배열을 행 우선 / 열 우선으로 메모리에 저장하는 방식. 어셈블리에서는 주로 행 우선.

* **Base-Index Operand**: `[base + index]`. 2차원 배열에서 base = 행 오프셋, index = 열 오프셋.

* **Scale Factor**: `[base + index*scale]`, scale = 1·2·4·8. `TYPE` 연산자로 지정하면 원소 크기에 맞게 자동 계산.

* **Base-Index-Displacement Operand**: `displacement[base + index*scale]`. 배열 이름을 변위로 쓰고 base에는 행 오프셋만 넣음.

* **Bubble Sort**: 인접한 쌍을 비교·교환. 한 패스마다 최댓값이 끝으로 이동, n − 1 패스 후 정렬 완료. O(n²).

* **Binary Search**: 정렬된 배열에서 중간값과 비교해 범위를 절반씩 줄임. 찾으면 위치, 못 찾으면 −1 반환. O(log n).
