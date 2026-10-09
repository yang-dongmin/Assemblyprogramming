# 1008

## 5.1 스택 연산 (Stack Operations)

### 1. 스택의 개념

* 접시를 쌓는 것처럼 **마지막에 넣은 값이 가장 먼저 나오는 LIFO(Last In First Out)** 구조.
* 값은 항상 맨 위(Top)에 추가되고 맨 위에서 제거됨.

---

### 2. 런타임 스택 (Runtime Stack, 32-Bit Mode)

CPU가 **ESP(Extended Stack Pointer) 레지스터**를 이용해 직접 관리하는 메모리 배열.

* **ESP는 항상 스택의 맨 위(마지막으로 push된 값)를 가리킴.**
* 스택을 그릴 때는 평소와 반대로 **위쪽이 높은 주소, 아래쪽이 낮은 주소**가 되도록 그림.

| Offset | Value | |
| --- | --- | --- |
| 00001000 | 00000006 | ← ESP = 00001000h |
| 00000FFC | | |
| 00000FF8 | | |
| 00000FF4 | | |
| 00000FF0 | | |

---

### 3. Push / Pop 동작

#### ① Push

32비트 push는 **ESP를 4 감소**시킨 뒤, ESP가 가리키는 위치에 값을 복사함. (스택은 낮은 주소 방향으로 자람)

| Offset | Before | After (push 000000A5) | 이후 (push 1, push 2) |
| --- | --- | --- | --- |
| 00001000 | 00000006 ← ESP | 00000006 | 00000006 |
| 00000FFC | | 000000A5 ← ESP | 000000A5 |
| 00000FF8 | | | 00000001 |
| 00000FF4 | | | 00000002 ← ESP |

#### ② Pop

스택에서 값을 꺼낸 뒤 **ESP를 원소 크기만큼 증가**시켜 그다음으로 높은 위치를 가리키게 함.

| Offset | Before | After (pop) |
| --- | --- | --- |
| 00001000 | 00000006 | 00000006 |
| 00000FFC | 000000A5 | 000000A5 |
| 00000FF8 | 00000001 | 00000001 ← ESP |
| 00000FF4 | 00000002 ← ESP | (사용 안 됨) |

---

### 4. 스택의 활용 (Stack Applications)

| 용도 | 설명 |
| --- | --- |
| **Register Saving** | 레지스터 값을 임시로 저장 |
| **Return Address Storage** | 서브루틴 호출 시 복귀 주소 저장 |
| **Argument Passing** | 서브루틴에 입력값(인자) 전달 |
| **Local Variable Storage** | 지역 변수를 위한 임시 저장 공간 |

---

### 5. PUSH / POP 명령어

#### ① PUSH

**ESP를 먼저 감소**시킨 뒤 source 피연산자를 스택에 복사함.

```assembly
PUSH reg/mem16
PUSH reg/mem32
PUSH imm32
```

#### ② POP

ESP가 가리키는 스택 원소를 16/32비트 destination에 **먼저 복사**한 뒤 ESP를 증가시킴.

```assembly
POP reg/mem16
POP reg/mem32
```

---

### 6. PUSHFD / POPFD 명령어

* **PUSHFD**: 32비트 EFLAGS 레지스터를 스택에 push.
* **POPFD**: 스택에서 pop하여 EFLAGS에 저장.

```assembly
pushfd
popfd
```

---

### 7. PUSHAD, PUSHA, POPAD, POPA

* **PUSHAD**: 32비트 범용 레지스터 전체를 다음 순서로 push.
  `EAX, ECX, EDX, EBX, ESP(PUSHAD 실행 전 값), EBP, ESI, EDI`
* **POPAD**: 같은 레지스터들을 **역순으로** pop.
* **PUSHA / POPA**: 16비트 레지스터(`AX, CX, DX, BX, SP, BP, SI, DI`)에 대해 같은 동작을 수행.

#### 활용 예: 프로시저 안에서 레지스터 보존

```assembly
MySub PROC
    pushad                  ; 범용 레지스터 저장
    .
    .
    mov eax, ...
    mov edx, ...
    mov ecx, ...
    .
    .
    popad                   ; 범용 레지스터 복원
    ret
MySub ENDP
```

#### 주의: 반환값이 있는 프로시저

```assembly
ReadValue PROC
    pushad                  ; 범용 레지스터 저장
    .
    .
    mov eax, return_value
    .
    .
    popad                   ; EAX를 덮어씀! → 반환값 손실
    ret
ReadValue ENDP
```

→ 반환값을 레지스터(EAX 등)로 돌려주는 프로시저에서는 PUSHAD/POPAD를 쓰면 안 됨.

---

### 8. PUSH / POP 활용 예

#### ① 레지스터 저장 후 복원

```assembly
push esi                    ; 레지스터 저장
push ecx
push ebx

mov esi, OFFSET dwordVal    ; 메모리 내용 출력
mov ecx, LENGTHOF dwordVal
mov ebx, TYPE dwordVal
call DumpMem

pop ebx                     ; 레지스터 복원 (push의 역순)
pop ecx
pop esi
```

#### ② 중첩 루프에서 바깥 루프 카운트 보존

ECX가 하나뿐이므로 바깥 루프의 카운트를 스택에 저장해 둠.

```assembly
    mov ecx, 100            ; 바깥 루프 카운트 설정
L1:                         ; 바깥 루프 시작
    push ecx                ; 바깥 루프 카운트 저장

    mov ecx, 20             ; 안쪽 루프 카운트 설정
L2:                         ; 안쪽 루프 시작
    ;
    ;
    loop L2                 ; 안쪽 루프 반복

    pop ecx                 ; 바깥 루프 카운트 복원
    loop L1                 ; 바깥 루프 반복
```

---

### 9. 예제: 문자열 뒤집기 (Reversing a String)

문자를 하나씩 push한 뒤 다시 pop하면 LIFO 특성 때문에 순서가 뒤집힘.

```assembly
.data
aName BYTE "I like StarII", 0
nameSize = ($ - aName) - 1      ; Null 문자를 뺀 길이 = 13

.code
    mov ecx, nameSize
    mov esi, 0
L1: movzx eax, aName[esi]       ; 문자 하나 가져오기
    push eax                    ; 스택에 push
    inc esi
    loop L1

    mov ecx, nameSize
    mov esi, 0
L2: pop eax                     ; 문자 하나 꺼내기
    mov aName[esi], al          ; 문자열에 저장
    inc esi
    loop L2
```

* `push`는 16/32비트만 가능하므로 `MOVZX`로 바이트를 32비트로 확장한 뒤 push함.
* 슬라이드 주석에는 `nameSize = 12`로 되어 있지만 `"I like StarII"`는 13글자이므로 실제 값은 13.

---

## 5.2 프로시저 정의와 사용 (Defining and Using Procedures)

### 1. PROC 지시자

#### ① 프로시저 정의 (Defining a Procedure)

프로시저(procedure)는 다른 언어의 **서브루틴, 메서드, 함수**에 해당함. `PROC`과 `ENDP`로 시작과 끝을 표시함.

```assembly
main PROC               ; 시작 프로시저 (startup procedure)
    .
    .
main ENDP

sample PROC
    .
    .
    ret                 ; 프로시저를 호출한 위치로 CPU를 복귀시킴
sample ENDP
```

#### ② 프로시저 안의 레이블 (Labels in Procedures)

```assembly
jmp Destination         ; Destination 레이블은 JMP와 같은 프로시저 안에 있어야 함

Destination::           ; 전역 레이블 (global label)
```

* 기본적으로 레이블은 **선언된 프로시저 안에서만** 유효함.
* `::`를 붙이면 다른 프로시저에서도 접근 가능한 전역 레이블이 됨.
* 하지만 현재 프로시저 밖으로 jump하거나 loop하는 것은 **좋은 설계가 아님**.

---

### 2. 예제: 세 정수의 합 (SumOf)

```assembly
SumOf PROC
    add eax, ebx
    add eax, ecx
    ret
SumOf ENDP
```

---

### 3. 프로시저 문서화 (Documenting Procedures)

프로시저 위에 주석 블록을 달아 무엇을 하는지, 무엇을 받고 무엇을 돌려주는지 적어 둠.

```assembly
;---------------------------------------------------------
; SumOf
;
; Calculates and returns the sum of three 32-bit integers.
; Receives: EAX, EBX, ECX, the three integers. May be
;           signed or unsigned.
; Returns:  EAX = sum
;---------------------------------------------------------
SumOf PROC
    add eax, ebx
    add eax, ecx
    ret
SumOf ENDP
```

| 순서 | 항목 | 설명 |
| --- | --- | --- |
| 1 | **Describe Tasks** | 프로시저가 수행하는 작업을 기술 |
| 2 | **List Input Parameters (Receives)** | 입력 매개변수와 그 사용 방법 명시 |
| 3 | **Describe Return Values (Returns)** | 프로시저가 반환하는 값 설명 |
| 4 | **List Preconditions (Requires)** | 호출 전에 충족되어야 하는 요구사항 명시 |

---

### 4. CALL / RET 명령어

* **CALL**: 프로세서가 새로운 메모리 위치에서 실행을 시작하도록 하여 프로시저를 호출함.
* **RET** (Return from Procedure): 프로시저를 호출한 지점으로 프로세서를 되돌림.

#### 동작 순서

1. **CALL 실행**: 프로시저 호출
2. **복귀 주소 push**: 복귀 주소(CALL 다음 명령어의 주소)를 스택에 push
3. **프로시저 주소 복사**: 호출된 프로시저의 주소를 명령어 포인터(EIP)에 복사
4. **프로시저 실행**: 새 주소에서 실행 시작
5. **RET 실행**: 프로시저에서 복귀
6. **복귀 주소 pop**: 스택에서 복귀 주소를 pop하여 EIP에 저장
7. **프로그램 계속 실행**: 복귀 주소부터 실행을 이어감

#### 예제 (Call and Return Example)

```assembly
            main PROC
00000020        call MySub
00000025        mov  eax, ebx
            .
            .
            MySub PROC
00000040        mov eax, edx
                .
                .
                ret
            MySub ENDP
```

* **CALL 실행 시**: 복귀 주소 `00000025`가 스택에 push되고 EIP = `00000040`.
* **RET 실행 시**:
  1. ESP가 가리키는 `00000025`를 pop하여 EIP에 저장.
  2. ESP는 호출 전 위치로 돌아감.

---

### 5. 중첩 프로시저 호출 (Nested Procedure Calls)

프로시저 안에서 다른 프로시저를 호출하면 복귀 주소가 차례로 스택에 쌓이고, `ret`할 때마다 역순으로 꺼내짐.

```assembly
main PROC
    .
    call Sub1
    exit
main ENDP

Sub1 PROC
    .
    call Sub2
    ret
Sub1 ENDP

Sub2 PROC
    .
    call Sub3
    ret
Sub2 ENDP

Sub3 PROC
    .
    ret
Sub3 ENDP
```

| Sub3 실행 중 | Sub2로 복귀 후 | Sub1로 복귀 후 |
| --- | --- | --- |
| (ret to main) | (ret to main) | (ret to main) ← ESP |
| (ret to Sub1) | (ret to Sub1) ← ESP | |
| (ret to Sub2) ← ESP | | |

---

### 6. 레지스터로 인자 전달 (Passing Register Arguments to Procedures)

어셈블리에서는 **범용 레지스터에 인자를 담아 전달**하는 방식이 일반적임.

```assembly
.data
theSum DWORD ?

.code
main PROC
    mov eax, 10000h         ; 인자
    mov ebx, 20000h         ; 인자
    mov ecx, 30000h         ; 인자
    call SumOf              ; EAX = (EAX + EBX + ECX)
    mov theSum, eax         ; 합계 저장
```

---

### 7. 예제: 정수 배열 합계 (ArraySum)

```assembly
;---------------------------------------------------------
; ArraySum
;
; Calculates the sum of an array of 32-bit integers.
; Receives: ESI = the array offset
;           ECX = number of elements in the array
; Returns:  EAX = sum of the array elements
;---------------------------------------------------------
ArraySum PROC
    push esi                ; ESI, ECX 저장
    push ecx
    mov eax, 0              ; 합계를 0으로 설정
L1:
    add eax, [esi]          ; 각 정수를 합계에 더함
    add esi, TYPE DWORD     ; 다음 정수를 가리킴
    loop L1                 ; 배열 크기만큼 반복
    pop ecx                 ; ECX, ESI 복원
    pop esi
    ret                     ; 합계는 EAX에 있음
ArraySum ENDP
```

#### ArraySum 테스트 (TestArraySum.asm)

```assembly
; Testing the ArraySum procedure (TestArraySum.asm)

.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
array  DWORD 10000h, 20000h, 30000h, 40000h, 50000h
theSum DWORD ?

.code
main PROC
    mov  esi, OFFSET array      ; ESI가 배열을 가리킴
    mov  ecx, LENGTHOF array    ; ECX = 배열 원소 개수
    call ArraySum               ; 합계 계산
    mov  theSum, eax            ; 결과는 EAX로 반환됨
    INVOKE ExitProcess, 0
main ENDP

; (ArraySum PROC ... ArraySum ENDP 위치)

END main
```

---

### 8. 레지스터 저장과 복원 (Saving and Restoring Registers)

프로시저에서 변경하는 레지스터는 시작할 때 저장하고 끝날 때 복원하는 것이 원칙임.
**단, 반환값으로 쓰는 레지스터(보통 EAX)는 push/pop하지 않음.**

#### USES 연산자

`USES`는 어셈블러에게 두 가지 일을 시킴:

1. 프로시저 시작 부분에 레지스터를 스택에 저장하는 **PUSH 명령어를 생성**.
2. 프로시저 끝 부분에 레지스터 값을 복원하는 **POP 명령어를 생성**.

```assembly
ArraySum PROC USES esi ecx
    mov eax, 0              ; 합계를 0으로 설정
L1:
    add eax, [esi]          ; 각 정수를 합계에 더함
    add esi, TYPE DWORD     ; 다음 정수를 가리킴
    loop L1                 ; 배열 크기만큼 반복
    ret                     ; 합계는 EAX에 있음
ArraySum ENDP
```

위 코드는 어셈블러에 의해 아래와 같이 변환됨:

```assembly
ArraySum PROC
    push esi
    push ecx
    mov eax, 0
L1:
    add eax, [esi]
    add esi, TYPE DWORD
    loop L1
    pop ecx
    pop esi
    ret
ArraySum ENDP
```

#### 예외: 반환값 레지스터를 저장하면 안 되는 경우

```assembly
SumOf PROC                  ; 세 정수의 합
    push eax                ; EAX 저장
    add eax, ebx            ; EAX, EBX, ECX의
    add eax, ecx            ; 합 계산
    pop eax                 ; 합계가 사라짐!
    ret
SumOf ENDP
```

---

## 5.3 외부 라이브러리 링크 (Linking to an External Library)

### 1. 배경 정보 (Background Information)

* **링크 라이브러리(link library)**: 기계어로 어셈블된 프로시저(서브루틴)들을 담고 있는 파일.
* 하나 이상의 소스 파일 → 어셈블 → 목적 파일(`.obj`) → 링커가 인식하는 특수한 형식의 파일로 묶음.

#### 링커 명령 옵션 (Linker Command Options)

```
link hello.obj irvine32.lib kernel32.lib
```

### 2. 32비트 프로그램 링크 (Linking 32-Bit Programs)

```
Your program ──links to──▶ Irvine32.lib
     │                         │ links to
     └──────can link to──────▶ kernel32.lib
                               │ executes
                               ▼
                           kernel32.dll
```

* **kernel32.lib**: Microsoft Windows Platform SDK의 일부로, `kernel32.dll`에 있는 시스템 함수의 링크 정보를 담고 있음.
* **kernel32.dll**: MS-Windows의 핵심 구성 요소인 **동적 링크 라이브러리(DLL)**. 문자 기반 입출력을 수행하는 실행 가능한 함수들을 포함함.

---

## 5.4 Irvine32 라이브러리 (The Irvine32 Library)

### 1. 라이브러리를 만든 동기 (Motivation)

* Microsoft가 공인한 어셈블리 표준 라이브러리는 없음.
* Windows 32비트 모드에서 입출력을 하려면 운영체제를 직접 호출해야 하므로 초보자에게 어려움.
* 그래서 **Irvine32 라이브러리는 초보자를 위한 간단한 입출력 인터페이스**를 제공함.

---

### 2. Irvine32 라이브러리의 프로시저

| 프로시저 | 설명 |
| --- | --- |
| **CloseFile** | 열려 있는 디스크 파일을 닫음 |
| **Clrscr** | 콘솔 창을 지우고 커서를 왼쪽 위로 이동 |
| **CreateOutputFile** | 출력 모드로 쓸 새 디스크 파일 생성 |
| **Crlf** | 콘솔 창에 줄바꿈(end-of-line) 출력 |
| **Delay** | 지정한 n 밀리초 동안 프로그램 실행 일시 정지 |
| **DumpMem** | 메모리 블록을 16진수로 콘솔에 출력 |
| **DumpRegs** | EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP, EFLAGS, EIP와 주요 상태 플래그를 16진수로 출력 |
| **GetCommandTail** | 프로그램의 명령줄 인자(command tail)를 바이트 배열로 복사 |
| **GetDateTime** | 시스템의 현재 날짜와 시간을 가져옴 |
| **GetMaxXY** | 콘솔 창 버퍼의 열과 행 수를 가져옴 |
| **GetMseconds** | 자정 이후 경과한 밀리초 반환 |
| **GetTextColor** | 콘솔 창의 현재 전경색/배경색 반환 |
| **Gotoxy** | 콘솔 창의 특정 행과 열로 커서 이동 |
| **IsDigit** | AL이 10진수 숫자(0–9)의 ASCII 코드이면 Zero 플래그 설정 |
| **MsgBox** | 팝업 메시지 박스 표시 |
| **MsgBoxAsk** | 예/아니오 질문을 팝업 메시지 박스로 표시 |
| **OpenInputFile** | 기존 디스크 파일을 입력용으로 열기 |
| **ParseDecimal32** | 부호 없는 10진수 문자열을 32비트 이진수로 변환 |
| **ParseInteger32** | 부호 있는 10진수 문자열을 32비트 이진수로 변환 |
| **Random32** | 0 ~ FFFFFFFFh 범위의 32비트 의사 난수 생성 |
| **Randomize** | 난수 생성기를 고유한 값으로 시드(seed) |
| **RandomRange** | 지정한 범위 안의 의사 난수 생성 |
| **ReadChar** | 키보드에서 문자 하나가 입력될 때까지 기다린 뒤 반환 |
| **ReadDec** | 키보드에서 부호 없는 32비트 10진수 입력 (Enter로 종료) |
| **ReadFromFile** | 입력 디스크 파일을 버퍼로 읽음 |
| **ReadHex** | 키보드에서 32비트 16진수 입력 (Enter로 종료) |
| **ReadInt** | 키보드에서 부호 있는 32비트 10진수 입력 (Enter로 종료) |
| **ReadKey** | 입력을 기다리지 않고 키보드 입력 버퍼에서 문자를 읽음 |
| **ReadString** | 키보드에서 문자열 입력 (Enter로 종료) |
| **SetTextColor** | 이후 콘솔에 출력되는 모든 텍스트의 전경색/배경색 설정 |
| **Str_compare** | 두 문자열 비교 |
| **Str_copy** | source 문자열을 destination 문자열로 복사 |
| **Str_length** | 문자열 길이를 EAX로 반환 |
| **Str_trim** | 문자열에서 원하지 않는 문자 제거 |
| **Str_ucase** | 문자열을 대문자로 변환 |
| **WaitMsg** | 메시지를 표시하고 키 입력을 기다림 |
| **WriteBin** | 부호 없는 32비트 정수를 ASCII 2진수 형식으로 출력 |
| **WriteBinB** | 2진수 정수를 byte/word/doubleword 형식으로 출력 |
| **WriteChar** | 문자 하나를 콘솔에 출력 |
| **WriteDec** | 부호 없는 32비트 정수를 10진수로 출력 |
| **WriteHex** | 32비트 정수를 16진수로 출력 |
| **WriteHexB** | byte/word/doubleword 정수를 16진수로 출력 |
| **WriteInt** | 부호 있는 32비트 정수를 10진수로 출력 |
| **WriteStackFrame** | 현재 프로시저의 스택 프레임을 콘솔에 출력 |
| **WriteStackFrameName** | 현재 프로시저의 이름과 스택 프레임을 콘솔에 출력 |
| **WriteString** | Null 종료 문자열을 콘솔에 출력 |
| **WriteToFile** | 버퍼를 출력 파일에 씀 |
| **WriteWindowsMsg** | MS-Windows가 마지막으로 발생시킨 오류 메시지 문자열 표시 |

---

### 3. 사용 예

#### ① 화면 지우기, 지연, 레지스터 출력

화면을 지우고 500밀리초 동안 멈춘 뒤 레지스터와 플래그를 출력함.

```assembly
.code
    call Clrscr
    mov eax, 500
    call Delay
    call DumpRegs
```

#### ② 문자열 출력 후 줄바꿈

Null 종료 문자열을 출력하고 커서를 다음 줄 처음으로 이동함. 두 방법은 같은 결과를 냄.

```assembly
.data
str1 BYTE "Assembly language is easy!", 0
.code
    mov edx, OFFSET str1
    call WriteString
    call Crlf
```

```assembly
.data
str1 BYTE "Assembly language is easy!", 0Dh, 0Ah, 0   ; CR, LF를 문자열에 포함
.code
    mov edx, OFFSET str1
    call WriteString
```

#### ③ 문자열 입력

EDX는 문자열 버퍼를 가리키고, ECX는 입력 가능한 최대 문자 수를 지정함.

```assembly
.data
fileName BYTE 80 DUP(0)
.code
    mov edx, OFFSET fileName
    mov ecx, SIZEOF fileName - 1    ; 끝에 0이 붙으므로 1을 뺌
    call ReadString
```

#### ④ 난수 출력

0–99 범위의 의사 난수 10개를 생성해 한 줄에 하나씩 출력함. 각 정수는 EAX로 WriteInt에 전달됨.

```assembly
.code
    mov ecx, 10                 ; 루프 카운터
L1: mov eax, 100                ; 상한값
    call RandomRange            ; 난수 생성
    call WriteInt               ; 부호 있는 정수 출력
    call Crlf                   ; 다음 줄로
    loop L1                     ; 반복
```

#### ⑤ 색상 출력

파란 배경에 노란 글자로 문자열을 출력함. **배경색은 16을 곱한 뒤 전경색에 더함.**

```assembly
.data
str1 BYTE "Color output is easy!", 0
.code
    mov eax, yellow + (blue * 16)
    call SetTextColor
    mov edx, OFFSET str1
    call WriteString
    call Crlf
```

---

### 4. 라이브러리 테스트 프로그램 (Library Test Programs)

#### ① Library Test #1: 정수 입출력 (InputLoop.asm)

```assembly
; Library Test #1: Integer I/O (InputLoop.asm)
; Clrscr, Crlf, DumpMem, ReadInt, SetTextColor,
; WaitMsg, WriteBin, WriteHex, WriteString 프로시저 테스트

INCLUDE Irvine32.inc

.data
COUNT = 4
BlueTextOnGray = blue + (lightGray * 16)
DefaultColor   = lightGray + (black * 16)
arrayD SDWORD 12345678h, 1A4B2000h, 3434h, 7AB9h
prompt BYTE "Enter a 32-bit signed integer: ", 0

.code
main PROC
; 밝은 회색 배경에 파란 글자 선택
    mov eax, BlueTextOnGray
    call SetTextColor
    call Clrscr                 ; 화면 지우기

; DumpMem으로 배열 출력
    mov esi, OFFSET arrayD      ; 시작 오프셋
    mov ebx, TYPE arrayD        ; doubleword = 4바이트
    mov ecx, LENGTHOF arrayD    ; arrayD의 원소 개수
    call DumpMem                ; 메모리 출력

; 부호 있는 정수를 차례로 입력받음
    call Crlf                   ; 줄바꿈
    mov ecx, COUNT
L1: mov edx, OFFSET prompt
    call WriteString
    call ReadInt                ; 정수를 EAX로 입력
    call Crlf                   ; 줄바꿈

; 정수를 10진수, 16진수, 2진수로 출력
    call WriteInt               ; 부호 있는 10진수
    call Crlf
    call WriteHex               ; 16진수
    call Crlf
    call WriteBin               ; 2진수
    call Crlf
    call Crlf
    loop L1                     ; 반복

; 콘솔 창을 기본 색상으로 되돌림
    call WaitMsg                ; "Press any key..."
    mov eax, DefaultColor
    call SetTextColor
    call Clrscr
    exit
main ENDP
END main
```

#### ② Library Test #2: 난수 (TestLib2.asm)

```assembly
; Link Library Test #2 (TestLib2.asm)
; Irvine32 라이브러리 프로시저 테스트

INCLUDE Irvine32.inc

TAB = 9                         ; Tab의 ASCII 코드

.code
main PROC
    call Randomize              ; 난수 생성기 초기화
    call Rand1
    call Rand2
    exit
main ENDP

Rand1 PROC
; 의사 난수 10개 생성
    mov ecx, 10                 ; 10번 반복
L1: call Random32               ; 난수 생성
    call WriteDec               ; 부호 없는 10진수로 출력
    mov al, TAB                 ; 수평 탭
    call WriteChar              ; 탭 출력
    loop L1
    call Crlf
    ret
Rand1 ENDP

Rand2 PROC
; -50 ~ +49 범위의 의사 난수 10개 생성
    mov ecx, 10                 ; 10번 반복
L1: mov eax, 100                ; 0-99
    call RandomRange            ; 난수 생성
    sub eax, 50                 ; -50 ~ +49
    call WriteInt               ; 부호 있는 10진수로 출력
    mov al, TAB                 ; 수평 탭
    call WriteChar              ; 탭 출력
    loop L1
    call Crlf
    ret
Rand2 ENDP
END main
```

#### ③ Library Test #3: 실행 시간 측정 (TestLib3.asm)

중첩 루프의 실행 시간을 `GetMseconds`로 측정함.

```assembly
; Link Library Test #3 (TestLib3.asm)
; 중첩 루프의 실행 경과 시간 계산

INCLUDE Irvine32.inc

.data
OUTER_LOOP_COUNT = 3
startTime DWORD ?
msg1 BYTE "Please wait...", 0Dh, 0Ah, 0
msg2 BYTE "Elapsed milliseconds: ", 0

.code
main PROC
    mov edx, OFFSET msg1        ; "Please wait..."
    call WriteString

; 시작 시간 저장
    call GetMseconds
    mov startTime, eax

; 바깥 루프 시작
    mov ecx, OUTER_LOOP_COUNT
L1: call innerLoop
    loop L1

; 경과 시간 계산
    call GetMseconds
    sub eax, startTime

; 경과 시간 출력
    mov edx, OFFSET msg2        ; "Elapsed milliseconds: "
    call WriteString
    call WriteDec               ; 밀리초 출력
    call Crlf
    exit
main ENDP

innerLoop PROC
    push ecx                    ; 현재 ECX 값 저장
    mov ecx, 0FFFFFFFh          ; 루프 카운터 설정
L1: mul eax                     ; 시간 소모용 연산
    mul eax
    mul eax
    loop L1                     ; 안쪽 루프 반복
    pop ecx                     ; 저장한 ECX 값 복원
    ret
innerLoop ENDP
END main
```

* `innerLoop`가 ECX를 다시 쓰므로 push/pop으로 바깥 루프 카운트를 보존함.

---

## 5.5 주요 요약 및 학습 키워드 (Key Terms)

* **Runtime Stack**: CPU가 ESP로 관리하는 LIFO 메모리 영역. 높은 주소에서 낮은 주소 방향으로 자람.

* **PUSH / POP**: PUSH는 ESP 감소 후 저장, POP은 읽은 후 ESP 증가. 피연산자는 16/32비트만 가능.

* **PUSHFD / POPFD**: EFLAGS 레지스터 저장/복원.

* **PUSHAD / POPAD**: 32비트 범용 레지스터 전체 저장/복원 (반환값 레지스터를 덮어쓰므로 주의).

* **PROC / ENDP**: 프로시저의 시작과 끝. 레이블은 기본적으로 프로시저 안에서만 유효하며 `::`로 전역 레이블 선언.

* **CALL / RET**: CALL은 복귀 주소를 push하고 프로시저로 이동, RET은 복귀 주소를 pop하여 EIP에 저장.

* **Nested Procedure Calls**: 복귀 주소가 스택에 차례로 쌓이고 역순으로 복귀.

* **Register Arguments**: 범용 레지스터로 인자를 전달하고 EAX로 결과를 반환하는 방식.

* **Documenting Procedures**: 작업 설명, Receives, Returns, Requires를 주석으로 기록.

* **USES**: 프로시저 시작/끝에 레지스터 PUSH/POP을 자동 생성 (반환값 레지스터는 제외).

* **Link Library / DLL**: 미리 어셈블된 프로시저를 모은 파일 / 실행 시 연결되는 동적 링크 라이브러리 (`kernel32.dll`).

* **Irvine32 Library**: 초보자를 위한 콘솔 입출력, 난수, 문자열, 파일 처리 프로시저 모음.
