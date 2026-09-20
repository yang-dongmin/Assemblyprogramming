# 0917

## 3.1 기본 언어 요소 (Basic Language Elements)

### 1. 첫 번째 어셈블리 프로그램 예제 (`AddTwo`)

```assembly
; AddTwo 프로그램: 두 정수를 더하는 간단한 예제
main PROC
    mov eax, 5      ; EAX 레지스터에 5를 이동
    add eax, 6      ; EAX 레지스터에 6을 더함

    INVOKE ExitProcess, 0  ; 프로그램 종료 및 운영체제에 제어권 반환
main ENDP

```

* **PROC / ENDP**: 프로시저(함수)의 시작과 끝을 나타냄.


* **`;` (주석)**: 세미콜론 뒤의 문장은 어셈블러가 무시함.


* **INVOKE ExitProcess, 0**: 윈도우 OS 서비스를 호출하여 프로그램을 종료함.



---

### 2. 리터럴 및 표현식 (Literals & Expressions)

#### ① 정수 리터럴 (Integer Literals)

구문: `[{+ | -}] digits [radix]`

* **진수 표기법 (radix)**:


* `h` : 16진수 (Hexadecimal) (예: `1Ah`, `0A3h`)
* `d` / `t` : 10진수 (Decimal) (예: `26`, `26d`)
* `b` / `y` : 2진수 (Binary) (예: `11010011b`)
* `q` / `o` : 8진수 (Octal) (예: `42q`, `42o`)
* `r` : 인코딩된 실수 (Encoded Real)



#### ② 정수 연산자 및 우선순위 (Arithmetic Operators)

| 우선순위 | 연산자 | 설명 |
| --- | --- | --- |
| **1** | `( )` | 괄호 (Parentheses) |
| **2** | `+`, `-` | 단항 플러스, 마이너스 (Unary plus, minus) |
| **3** | `*`, `/`, `MOD` | 곱하기, 나누기, 나머지 연산 |
| **4** | `+`, `-` | 이항 더하기, 빼기 |

#### ③ 실수 및 문자/문자열 리터럴

* **실수 리터럴 (Real Number Literals)**: `+3.0`, `-44.2E+05`, `26.E5`

* **문자/문자열 리터럴 (Character & String Literals)**:
* 작은따옴표(' ') 또는 큰따옴표(" ") 사용


* 예: `'A'`, `"Good night, Gracie"`, `'Say "Good night," Gracie'`




---

### 3. 예약어, 식별자, 지시자, 명령어

#### ① 예약어 (Reserved Words)



* **명령어 축약어 (Mnemonics)**: `MOV`, `ADD`, `MUL` 등
* **레지스터 이름**: `EAX`, `EBX` 등
* **지시자 (Directives)**: 어셈블러에게 지시를 내리는 명령 (예: `.data`, `.code`)
* **속성 및 크기 키워드**: `BYTE`, `WORD`, `DWORD` 등
* **연산자 및 사전 정의된 기호**: `@data` 등

#### ② 식별자 규칙 (Identifiers)



* 1~247자 길이 지원.


* **대소문자 구문 없음 (Case insensitive)**.


* 첫 글자는 알파벳(`A-Z`, `a-z`), `_`, `@`, `?`, `$`만 가능하며, 이후 숫자가 올 수 있음.


* 예약어와 동일한 이름 사용 불가.



#### ③ 지시자 (Directives)



어셈블러가 소스 코드를 해석할 때 수행할 작업을 지시하는 명령 (기계어로 번역되지 않음).

* `.data`: 변수가 선언되는 데이터 세그먼트 정의.


* `.code`: 실행 코드가 포함된 코드 세그먼트 정의.


* `.stack 100h`: 런타임 스택 영역 크기 정의.



#### ④ 명령어 구조 (Instructions)



구문: `[label:] mnemonic [operands] [;comment]`

| 요소 | 필수 여부 | 설명 | 예시 |
| --- | --- | --- | --- |
| **Label** | 선택 | 코드/데이터의 위치를 나타내는 식별자

 | `target:`, `count DWORD 100`<br> |
| **Mnemonic** | 필수 | 수행할 연산을 나타내는 기호

 | `MOV`, `ADD`, `SUB`, `MUL`, `JMP`, `CALL`<br> |
| **Operands** | 주 형태에 따라 | 연산에 필요한 데이터(값, 레지스터, 메모리 주소)

 | `stc` (0개), `inc eax` (1개), `mov count, ebx` (2개)

 |
| **Comment** | 선택 | 주석 (`;` 또는 `COMMENT ! ... !`)

 | `; 주석 내용`<br> |

#### ⑤ NOP (No Operation) 명령어



* 1바이트를 차지하지만 아무 연산도 수행하지 않음.


* 코드 메모리 주소를 효율적인 경계(Alignment)로 맞추기 위해 사용됨.



---

## 3.2 정수 가감산 예제 (Adding and Subtracting Integers)

### 1. `AddSub2.asm` 코드 구조

```assembly
INCLUDE Irvine32.inc    ; Irvine32 라이브러리 포함[cite: 1]

.data
    val1 DWORD 10000h
    val2 DWORD 40000h
    val3 DWORD 20000h
    finalVal DWORD ?    ; 초기화되지 않은 32비트 변수[cite: 1]

.code
main PROC
    mov eax, val1       ; EAX = 10000h
    add eax, val2       ; EAX = 50000h
    sub eax, val3       ; EAX = 30000h
    mov finalVal, eax   ; finalVal = 30000h

    call DumpRegs       ; CPU 레지스터 및 플래그 상태 출력 함수 호출[cite: 1]
    exit                ; ExitProcess 호출을 간단하게 래핑한 것[cite: 1]
main ENDP
END main

```

---

## 3.3 어셈블, 링크 및 실행 (Assembling, Linking, and Running)

### 1. 빌드 및 실행 과정 (Assemble-Link-Execute Cycle)



1. **Source File (`.asm`)**: 텍스트 에디터를 통해 코드 작성.


2. **Assembler (`ml.exe`)**: 소스 코드를 기계어로 번역하여 **Object File (`.obj`)** 생성 및 **Listing File (`.lst`)** 생성.


3. **Linker (`link.exe`)**: `.obj` 파일과 라이브러리(`.lib`)를 결합하여 **Executable (`.exe`)** 생성.


4. **OS Loader**: 실행 파일을 메모리에 로드하여 CPU에서 실행.



---

## 3.4 데이터 정의 (Defining Data)

### 1. 기본 데이터 타입 (Intrinsic Data Types)

| 타입 | 크기 | 설명 |
| --- | --- | --- |
| **BYTE** / **SBYTE** | 8비트 | 부호 없는 / 부호 있는 8비트 정수

 |
| **WORD** / **SWORD** | 16비트 | 부호 없는 / 부호 있는 16비트 정수

 |
| **DWORD** / **SDWORD** | 32비트 | 부호 없는 / 부호 있는 32비트 정수

 |
| **QWORD** | 64비트 | 64비트 정수

 |
| **TBYTE** | 80비트 | 10바이트 정수 / Packed BCD

 |
| **REAL4** / **REAL8** / **REAL10** | 32/64/80비트 | 단정밀도 / 다정밀도 / 확장정밀도 IEEE 부동소수점

 |

* 레거시 지시자: `DB` (8비트), `DW` (16비트), `DD` (32비트), `DQ` (64비트), `DT` (80비트)



---

### 2. 데이터 정의 예시 및 연산자

#### ① 문자열 선언 및 Null 종료 문자열 (Null-Terminated String)

```assembly
greeting1 BYTE "Good afternoon", 0    ; 끝에 0(Null)을 붙여 문자열의 끝을 나타냄[cite: 1]
greeting2 BYTE "Welcome", 0Dh, 0Ah, 0 ; 0Dh(CR), 0Ah(LF) 개행 문입 포함[cite: 1]

```

#### ② DUP 연산자 (반복 할당)

```assembly
var1 BYTE 20 DUP(0)         ; 0으로 채워진 20바이트 생성[cite: 1]
var2 BYTE 20 DUP(?)         ; 초기화되지 않은 20바이트 생성[cite: 1]
var3 BYTE 4 DUP("STACK")    ; "STACKSTACKSTACKSTACK"[cite: 1]

```

---

### 3. 바이트 순서: 리틀 엔디안 (Little-Endian Order)



x86 아키텍처 CPU는 데이터를 메모리에 저장할 때 **리틀 엔디안 (하위 바이트가 낮은 메모리 주소에 저장)** 방식을 사용함.

예시: `12345678h`를 메모리 주소 `0000`부터 저장할 때:

* `0000`: `78h` (최하위 바이트 LSB)


* `0001`: `56h`

* `0002`: `34h`

* `0003`: `12h` (최상위 바이트 MSB)



---

### 4. `.DATA?` 지시자 (초기화되지 않은 데이터)



초기화되지 않은 대용량 배열을 선언할 때 `.DATA?` 영역을 사용하면 compiled된 실행 파일(`.exe`)의 크기를 획기적으로 줄일 수 있음.

```assembly
.data
smallArray DWORD 10 DUP(0)     ; 실행 파일 크기에 포함됨[cite: 1]

.data?
bigArray DWORD 5000 DUP(?)     ; 실행 파일 크기를 늘리지 않음[cite: 1]

```

---

## 3.5 기호 상수 (Symbolic Constants)

### 1. 등호 지시자 (`=`)



상수 정수 표현식을 기호 이름에 바인딩함. (코드 내에서 재정의 가능)

```assembly
COUNT = 500[cite: 1]
mov eax, COUNT[cite: 1]

COUNT = 10    ; 재정의 가능[cite: 1]
mov al, COUNT[cite: 1]

```

#### 현재 위치 카운터 (`$`)를 활용한 크기 계산



`$` 연산자는 현재 실행 중인/위치한 메모리 주소를 나타냄.

```assembly
; 바이트 배열 크기 계산
list BYTE 10, 20, 30, 40[cite: 1]
ListSize = ($ - list)         ; ListSize = 4[cite: 1]

; 워드(2바이트) 배열 크기 계산
listWORD WORD 1000h, 2000h, 3000h[cite: 1]
ListSize = ($ - listWORD) / 2[cite: 1]

; 더블워드(4바이트) 배열 크기 계산
listDWORD DWORD 10000000h, 20000000h[cite: 1]
ListSize = ($ - listDWORD) / 4[cite: 1]

```

---

### 2. `EQU` 지시자



정수 표현식 또는 텍스트를 기호명에 바인딩함 (재정의 불가).

```assembly
PI EQU <3.1416>[cite: 1]
pressKey EQU <"Press any key to continue...", 0>[cite: 1]
matrix1 EQU 10 * 10[cite: 1]

```

---

### 3. `TEXTEQU` 지시자 (텍스트 매크로)



텍스트 매크로를 생성하여 명령어나 특정 문장으로 치환할 때 사용함.

```assembly
continueMsg TEXTEQU <"Do you wish to continue (Y/N)?">[cite: 1]
move TEXTEQU <mov>[cite: 1]
setupAL TEXTEQU <move al, 10>[cite: 1]

```

---

## 3.6 주요 요약 및 학습 키워드 (Key Terms)



* **Assembler / Linker**: 소스 파일(`.asm`) → 목적 파일(`.obj`) → 실행 파일(`.exe`)로 변환하는 도구.


* **Directive (지시자)**: 어셈블러에게 전달하는 지시사항 (`.data`, `.code`, `PROC` 등).


* **Instruction (명령어)**: CPU가 실행할 실제 기계어로 번역되는 연산 명령 (`MOV`, `ADD` 등).


* **Little-Endian**: 하위 바이트를 메모리의 앞쪽(낮은 주소)에 저장하는 방식.


* **Symbolic Constant**: `=` , `EQU`, `TEXTEQU`를 이용한 코드 가독성 향상 목적의 상수 선언.