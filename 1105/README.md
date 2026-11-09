# 1105

## 8.2 스택 프레임 (Stack Frames)

### 1. 스택 파라미터 (Stack Parameters)

**스택 프레임(stack frame)** 또는 **활성 레코드(activation record)** 는 다음을 위해 스택에 따로 마련된 영역임.

* 전달된 인자 (passed arguments)
* 서브루틴의 복귀 주소 (return address)
* 지역 변수 (local variables)
* 저장된 레지스터 (saved registers)

#### 스택 프레임 생성 과정 (Stack Frame Creation Process)

| 순서 | 단계 | 설명 |
| --- | --- | --- |
| ① | **Push Arguments** | 인자를 스택에 push |
| ② | **Call Subroutine** | 서브루틴 호출, 복귀 주소가 스택에 push됨 |
| ③ | **Push EBP** | 현재 EBP 값을 저장 |
| ④ | **Set EBP to ESP** | EBP를 현재 스택 포인터(ESP)로 설정 |
| ⑤ | **Allocate Local Variables** | 지역 변수용 공간 확보 |
| ⑥ | **Save Registers** | 사용할 레지스터를 스택에 저장 |

---

### 2. 레지스터 파라미터의 단점 (Disadvantages of Register Parameters)

레지스터를 파라미터로 쓰려면, 프로시저 호출 **전에** 그 레지스터들을 먼저 스택에 push하고, 인자 값을 대입한 뒤, 프로시저가 반환된 **후에** 원래 값으로 복원해야 함.

```assembly
push  ebx                       ; save register values
push  ecx
push  esi
mov   esi,OFFSET array          ; starting OFFSET
mov   ecx,LENGTHOF array        ; size, in units
mov   ebx,TYPE array            ; doubleword format
call  DumpMem                   ; display memory
pop   esi                       ; restore register values
pop   ecx
pop   ebx
```

* 추가적인 push/pop 때문에 **코드가 지저분해짐**.
* 레지스터 파라미터를 써서 얻으려던 **성능상의 이점이 오히려 사라짐**.

> Microsoft는 32비트 프로그램에서 **fastcall** 이라는 파라미터 전달 규약을 제공함.

---

### 3. 인자 전달 방식 (Value vs Reference Arguments)

| 구분 | 설명 |
| --- | --- |
| **Value Arguments** | 값을 직접 전달 (pass values directly) |
| **Reference Arguments** | 메모리 주소를 전달 (pass memory addresses) |

#### ① 값에 의한 전달 (Passing by Value)

인자를 값으로 전달하면 **값의 복사본(copy)** 이 스택에 push됨.

```assembly
.data
val1  DWORD 5
val2  DWORD 6
.code
push  val2
push  val1
call  AddTwo
```

```
        ┌──────────┐
(val2)  │    6     │
        ├──────────┤
(val1)  │    5     │  ← ESP
        ├──────────┤
        │          │
        └──────────┘
```

C 표현: `int sum = AddTwo( val1, val2 );`

#### ② 참조에 의한 전달 (Passing by Reference)

참조로 전달되는 인자는 객체의 **주소(offset)** 로 구성됨.

```assembly
push  OFFSET val2
push  OFFSET val1
call  Swap
```

```
┌───────────────┐
│ offset (val2) │
├───────────────┤
│ offset (val1) │  ← ESP
├───────────────┤
│               │
└───────────────┘
```

C 표현: `Swap( &val1, &val2 );`

#### ③ 배열 전달 (Passing Arrays)

고급 언어는 배열을 항상 **참조로(by reference)** 전달함. 즉, 배열의 **주소**를 스택에 push함.

```assembly
.data
array  DWORD 50 DUP(?)
.code
push   OFFSET array
call   ArrayFill
```

---

### 4. 스택 파라미터 접근 (Accessing Stack Parameters)

#### AddTwo 예제

```c
int AddTwo( int x, int y )
{
    return x + y;
}
```

```assembly
AddTwo PROC
    push  ebp
    mov   ebp,esp               ; base of stack frame
    mov   eax,[ebp + 12]        ; second parameter
    add   eax,[ebp + 8]         ; first parameter
    pop   ebp
    ret
AddTwo ENDP
```

```
┌────────────────┐
│       6        │  [EBP + 12]
├────────────────┤
│       5        │  [EBP + 8]
├────────────────┤
│ return address │  [EBP + 4]
├────────────────┤
│      EBP       │  ← EBP, ESP
└────────────────┘
```

* `push ebp` / `mov ebp, esp` 이후 EBP가 스택 프레임의 **기준점**이 됨.
* **[EBP + 4]** = 복귀 주소, **[EBP + 8]** = 첫 번째 파라미터, **[EBP + 12]** = 두 번째 파라미터.

---

### 5. 명시적 스택 파라미터 (Explicit Stack Parameters)

`[ebp + 8]` 처럼 **오프셋을 상수로 직접 명시**하여 스택 파라미터를 참조하는 것을 **explicit stack parameter** 라고 함.

코드 가독성을 위해 **심볼 상수(symbolic constant)** 로 정의하기도 함.

```assembly
y_param EQU [ebp + 12]
x_param EQU [ebp + 8]

AddTwo PROC
    push  ebp
    mov   ebp,esp
    mov   eax,y_param
    add   eax,x_param
    pop   ebp
    ret
AddTwo ENDP
```

---

### 6. 스택 정리 (Cleaning Up the Stack)

파라미터를 push한 후 프로시저가 반환될 때 **스택에서 제거하지 않으면 스택이 깨짐(corrupted)**.

```assembly
main PROC
    call  Example1
    exit
main ENDP

Example1 PROC
    push  6
    push  5
    call  AddTwo
    ret                         ; stack is corrupted!
Example1 ENDP
```

```
┌────────────────┐
│ return address │
├────────────────┤
│       6        │
├────────────────┤
│       5        │  ← ESP
└────────────────┘
```

* Example1의 `ret`이 실행될 때 ESP는 **복귀 주소가 아니라 5** 를 가리키고 있음 → 엉뚱한 주소로 복귀.

#### 해결: 호출 후 ESP 조정

```assembly
Example1 PROC
    push  6
    push  5
    call  AddTwo
    add   esp, 8                ; 2개 * 4바이트 스택 정리
    ret
Example1 ENDP
```

---

### 7. 32비트 호출 규약 (32-Bit Calling Conventions)

#### ① C 호출 규약 (The C Calling Convention)

* C/C++에서 사용.
* 파라미터를 **역순(reverse order)** 으로 push함 → `AddTwo( A, B )` 호출 시 **B를 먼저**, 그다음 A를 push.
* **호출한 쪽(caller)** 이 `add esp, n` 으로 스택을 정리함.

```assembly
Example1 PROC
    push  6
    push  5
    call  AddTwo
    add   esp,8                 ; remove arguments from the stack
    ret
Example1 ENDP
```

#### ② STDCALL 호출 규약 (STDCALL Calling Convention)

* **호출된 프로시저(callee)** 가 `RET n` 으로 스택을 정리함.
* `RET` 에 정수 파라미터를 주면, 복귀 후 ESP에 그 값을 더함.
* 이 정수는 **파라미터가 차지한 스택 바이트 수와 같아야 함**.

```assembly
AddTwo PROC
    push  ebp
    mov   ebp,esp               ; base of stack frame
    mov   eax,[ebp + 12]        ; second parameter
    add   eax,[ebp + 8]         ; first parameter
    pop   ebp
    ret   8                     ; clean up the stack
AddTwo ENDP
```

| 규약 | push 순서 | 스택 정리 주체 | 정리 방법 |
| --- | --- | --- | --- |
| **C** | 역순 (오른쪽→왼쪽) | 호출자 (caller) | `add esp, n` |
| **STDCALL** | 역순 (오른쪽→왼쪽) | 피호출자 (callee) | `ret n` |

---

### 8. 레지스터 저장과 복원 (Saving and Restoring Registers)

서브루틴은 보통 레지스터를 수정하기 **전에** 현재 값을 스택에 저장함.

```assembly
MySub PROC
    push  ebp                   ; save base pointer
    mov   ebp,esp               ; base of stack frame
    push  ecx
    push  edx                   ; save EDX
    mov   eax,[ebp+8]           ; get the stack parameter
    .
    .
    pop   edx                   ; restore saved registers
    pop   ecx
    pop   ebp                   ; restore base pointer
    ret                         ; clean up the stack
MySub ENDP
```

```
┌────────────────┐
│  (parameter)   │  [EBP + 8]
├────────────────┤
│ return address │  [EBP + 4]
├────────────────┤
│      EBP       │  ← EBP
├────────────────┤
│      ECX       │
├────────────────┤
│      EDX       │  ← ESP
└────────────────┘
```

* `push ebp; mov ebp, esp` **이후에** 레지스터를 저장하므로, 파라미터 오프셋([EBP + 8])이 저장 레지스터 개수와 무관하게 유지됨.
* `ret` : return address(EBP+4 위치에 있던 것)를 pop하여 호출한 함수로 복귀.

---

### 9. 지역 변수 (Local Variables)

하나의 서브루틴 안에서 생성·사용·소멸되는 변수를 **지역 변수**라고 함. 지역 변수는 런타임 스택에 생성되며, 보통 **베이스 포인터(EBP) 아래쪽**에 위치함.

```c
void MySub()
{
    int X = 10;
    int Y = 20;
}
```

| Variable | Bytes | Stack Offset |
| --- | --- | --- |
| X | 4 | EBP − 4 |
| Y | 4 | EBP − 8 |

```assembly
MySub PROC
    push  ebp
    mov   ebp,esp
    sub   esp,8                     ; create locals
    mov   DWORD PTR [ebp-4],10      ; X
    mov   DWORD PTR [ebp-8],20      ; Y
    mov   esp,ebp                   ; remove locals from stack
    pop   ebp
    ret
MySub ENDP
```

```
┌────────────────┐
│ return address │
├────────────────┤
│      EBP       │  ← EBP
├────────────────┤
│     10 (X)     │  [EBP − 4]
├────────────────┤
│     20 (Y)     │  [EBP − 8]  ← ESP
└────────────────┘
```

* `sub esp, n` 으로 지역 변수 공간을 확보함.
* 종료 직전 `mov esp, ebp` 로 ESP를 EBP 값으로 되돌려 **지역 변수를 스택에서 해제**함.

---

### 10. 참조 파라미터 (Reference Parameters)

참조 파라미터는 보통 EBP 기준 **base-offset 주소 지정**으로 접근함.

#### ArrayFill 예제

배열을 **16비트 의사 난수(pseudorandom) 정수**로 채움.

```assembly
ArrayFill PROC
    push  ebp
    mov   ebp,esp
    pushad                      ; save registers
    mov   esi,[ebp+12]          ; offset of array
    mov   ecx,[ebp+8]           ; array length
    cmp   ecx,0                 ; ECX == 0?
    je    L2                    ; yes: skip over loop
L1:
    mov   eax,10000h            ; get random 0 - FFFFh
    call  RandomRange           ; from the link library
    mov   [esi],ax              ; insert value in array
    add   esi,TYPE WORD         ; move to next element
    loop  L1
L2: popad                       ; restore registers
    pop   ebp
    ret   8                     ; clean up the stack
ArrayFill ENDP
```

```
┌────────────────┐
│ offset (array) │  [EBP + 12]
├────────────────┤
│     count      │  [EBP + 8]
├────────────────┤
│ return address │
├────────────────┤
│      EBP       │  ← EBP, ESP
└────────────────┘
```

* `[ebp+12]` 에는 배열의 **주소**가 들어 있으므로 ESI에 넣고 `[esi]` 로 간접 참조함.
* `ret 8` : 파라미터 2개(8바이트)를 정리 (STDCALL 방식).

---

### 11. LEA 명령어 (LEA Instruction)

**LEA(Load Effective Address)** 는 간접 피연산자의 **주소**를 반환함.

* `OFFSET` 은 어셈블 시점에 결정되는 주소에만 사용 가능 → 스택에 있는 지역 변수 주소는 런타임에 결정되므로 **LEA** 를 사용해야 함.

```c
void makeArray( )
{
    char myString[30];
    for( int i = 0; i < 30; i++ )
        myString[i] = '*';
}
```

```assembly
makeArray PROC
    push  ebp
    mov   ebp,esp
    sub   esp,32                    ; myString is at EBP-30
    lea   esi,[ebp-30]              ; load address of myString
    mov   ecx,30                    ; loop counter
L1: mov   BYTE PTR [esi],'*'        ; fill one position
    inc   esi                       ; move to next
    loop  L1                        ; continue until ECX = 0
    add   esp,32                    ; remove the array (restore ESP)
    pop   ebp
    ret
makeArray ENDP
```

* 30바이트 배열이지만 스택은 4바이트 단위로 정렬하므로 `sub esp, 32` 로 확보함.

---

### 12. ENTER와 LEAVE 명령어 (ENTER and LEAVE Instructions)

#### ① ENTER

**ENTER** 는 호출된 프로시저의 스택 프레임을 **자동으로 생성**함. 지역 변수용 스택 공간을 확보하고 EBP를 스택에 저장함.

| 순서 | 동작 |
| --- | --- |
| 1 | **Push EBP** : 현재 베이스 포인터를 스택에 저장 |
| 2 | **Set EBP** : 베이스 포인터를 현재 스택 포인터로 갱신 |
| 3 | **Reserve Space** : 지역 변수용 메모리를 스택에 할당 |

```assembly
ENTER numbytes, nestinglevel
```

* **numbytes** : 지역 변수용으로 확보할 스택 바이트 수
* **nestinglevel** : 프로시저의 렉시컬 중첩 수준 (보통 0)

#### Example 1

```assembly
MySub PROC                  ; ≡  MySub PROC
    enter 0,0               ;        push  ebp
                            ;        mov   ebp,esp
```

#### Example 2

```assembly
MySub PROC                  ; ≡  MySub PROC
    enter 8,0               ;        push  ebp
                            ;        mov   ebp,esp
                            ;        sub   esp,8
```

```
Before                        After executing ENTER 8, 0

┌──────────┐                  ┌──────────┐
│▒▒▒▒▒▒▒▒▒▒│ ← ESP            │▒▒▒▒▒▒▒▒▒▒│
├──────────┤                  ├──────────┤
│          │                  │   EBP    │ ← EBP
├──────────┤                  ├──────────┤
│          │                  │   ????   │
├──────────┤                  ├──────────┤
│          │                  │   ????   │ ← ESP
└──────────┘                  └──────────┘
```

> ENTER를 사용했다면, 같은 프로시저 끝에서 **반드시 LEAVE를 함께 사용**하는 것이 강력히 권장됨.

#### ② LEAVE

**LEAVE** 는 프로시저의 스택 프레임을 종료함. 이전 ENTER의 동작을 되돌려 **ESP와 EBP를 프로시저 호출 시점의 값으로 복원**함.

```assembly
MySub PROC                  ; ≡  MySub PROC
    enter 8,0               ;        push  ebp
    .                       ;        mov   ebp,esp
    .                       ;        sub   esp,8
    leave                   ;        .
    ret                     ;        mov   esp,ebp
MySub ENDP                  ;        pop   ebp
                            ;        ret
                            ;    MySub ENDP
```

| 명령어 | 동등한 코드 |
| --- | --- |
| `enter n, 0` | `push ebp` / `mov ebp, esp` / `sub esp, n` |
| `leave` | `mov esp, ebp` / `pop ebp` |

---

### 13. LOCAL 지시어 (LOCAL Directive)

**LOCAL** 은 하나 이상의 지역 변수를 **이름과 크기 속성**을 붙여 선언함. (반면 ENTER는 이름 없는 하나의 공간 블록만 확보함.)

```assembly
LOCAL varlist
      label:type
```

#### Examples

```assembly
MySub PROC
    LOCAL var1:BYTE

BubbleSort PROC
    LOCAL temp:DWORD, SwapFlag:BYTE

Merge PROC
    LOCAL pArray:PTR WORD

    LOCAL TempArray[10]:DWORD
```

* LOCAL은 **PROC 지시어 바로 다음 줄**에 와야 함.
* MASM이 자동으로 `push ebp / mov ebp, esp / sub esp, n` 과 `leave` 를 생성해 줌.

---

## 8.3 재귀 (Recursion)

**재귀 서브루틴(recursive subroutine)** 은 직접 또는 간접적으로 **자기 자신을 호출**하는 서브루틴임.

### 1. 무한 재귀 (Endless Recursion)

```assembly
; Endless Recursion                 (Endless.asm)
INCLUDE Irvine32.inc
.data
endlessStr BYTE "This recursion never stops",0
.code
main PROC
    call  Endless
    exit
main ENDP

Endless PROC
    mov   edx,OFFSET endlessStr
    call  WriteString
    call  Endless
    ret                         ; never executes
Endless ENDP
END main
```

* 종료 조건이 없으므로 호출할 때마다 복귀 주소가 계속 쌓여 결국 **스택 오버플로(stack overflow)** 가 발생함.

---

### 2. 재귀로 합 구하기 (Recursively Calculating a Sum)

쓸모 있는 재귀 서브루틴은 **항상 종료 조건(terminating condition)** 을 포함함.

```assembly
; Sum of Integers                   (RecursiveSum.asm)
INCLUDE Irvine32.inc
.code
main PROC
    mov   ecx,5                 ; count = 5
    mov   eax,0                 ; holds the sum
    call  CalcSum               ; calculate sum
L1: call  WriteDec              ; display EAX
    call  Crlf                  ; new line
    exit
main ENDP

;---------------------------------------------------
CalcSum PROC
; Calculates the sum of a list of integers
; Receives: ECX = count
; Returns: EAX = sum
;---------------------------------------------------
    cmp   ecx,0                 ; check counter value
    jz    L2                    ; quit if zero
    add   eax,ecx               ; otherwise, add to sum
    dec   ecx                   ; decrement counter
    call  CalcSum               ; recursive call
L2: ret
CalcSum ENDP
END main
```

* CalcSum의 첫 두 줄은 카운터를 검사하여 **ECX = 0이면 프로시저를 빠져나감** → 더 이상 재귀 호출을 하지 않음.
* `RET` 에 처음 도달하면 이전 CalcSum 호출로 복귀하고, 그것이 다시 그 이전 호출로 복귀하는 식으로 계속 되돌아감.

#### Table 8-1. Stack Frame and Registers (CalcSum)

| Pushed on Stack | Value in ECX | Value in EAX |
| --- | --- | --- |
| L1 | 5 | 0 |
| L2 | 4 | 5 |
| L2 | 3 | 9 |
| L2 | 2 | 12 |
| L2 | 1 | 14 |
| L2 | 0 | 15 |

* 첫 호출은 main에서 하므로 복귀 주소 **L1** 이 push되고, 이후 재귀 호출은 모두 CalcSum 내부에서 하므로 **L2** 가 push됨.
* 최종 결과 EAX = 5 + 4 + 3 + 2 + 1 = **15**.

---

### 3. 팩토리얼 계산 (Calculating a Factorial)

재귀 서브루틴은 종종 **임시 데이터를 스택 파라미터에 저장**함. 재귀 호출이 되감길(unwind) 때 스택에 저장된 데이터를 활용할 수 있음.

```c
int function factorial(int n)
{
    if(n == 0)
        return 1;
    else
        return n * factorial(n-1);
}
```

```
Recursive calls          Backing up
┌────────────┐          ┌────────────┐
│ 5! = 5 * 4!│          │5 * 24 = 120│
└─────┬──────┘          └─────▲──────┘
┌─────▼──────┐          ┌─────┴──────┐
│ 4! = 4 * 3!│          │ 4 * 6 = 24 │
└─────┬──────┘          └─────▲──────┘
┌─────▼──────┐          ┌─────┴──────┐
│ 3! = 3 * 2!│          │ 3 * 2 = 6  │
└─────┬──────┘          └─────▲──────┘
┌─────▼──────┐          ┌─────┴──────┐
│ 2! = 2 * 1!│          │ 2 * 1 = 2  │
└─────┬──────┘          └─────▲──────┘
┌─────▼──────┐          ┌─────┴──────┐
│ 1! = 1 * 0!│          │ 1 * 1 = 1  │
└─────┬──────┘          └─────▲──────┘
┌─────▼──────┐          ┌─────┴──────┐
│   0! = 1   │          │   1 = 1    │
└────────────┘          └────────────┘
 (Base case)
```

#### Example Program (Fact.asm)

n(0 ~ 12 사이의 부호 없는 정수)을 스택으로 Factorial 프로시저에 전달하고, 결과는 **EAX** 로 반환함.

```assembly
; Calculating a Factorial (Fact.asm)
INCLUDE Irvine32.inc
.code
main PROC
    push  5                     ; calc 5!
    call  Factorial             ; calculate factorial (EAX)
    call  WriteDec              ; display it
    call  Crlf
    exit
main ENDP

;---------------------------------------------------
Factorial PROC
; Calculates a factorial.
; Receives: [ebp+8] = n, the number to calculate
; Returns: eax = the factorial of n
;---------------------------------------------------
    push  ebp
    mov   ebp,esp
    mov   eax,[ebp+8]           ; get n
    cmp   eax,0                 ; n > 0?
    ja    L1                    ; yes: continue
    mov   eax,1                 ; no: return 1 as the value of 0!
    jmp   L2                    ; and return to the caller
L1: dec   eax
    push  eax                   ; Factorial(n-1)
    call  Factorial

; Instructions from this point on execute when each
; recursive call returns.
ReturnFact:
    mov   ebx,[ebp+8]           ; get n
    mul   ebx                   ; EDX:EAX = EAX * EBX
L2: pop   ebp                   ; return EAX
    ret   4                     ; clean up stack
Factorial ENDP
END main
```

* **종료 조건** : n = 0이면 EAX = 1을 반환.
* **재귀 호출** : n − 1을 push하고 자기 자신을 호출.
* **되감기(ReturnFact)** : 각 단계의 `[ebp+8]` 에 남아 있는 **자신의 n** 을 꺼내 EAX에 곱함.
* `ret 4` : push했던 파라미터 1개(4바이트)를 정리.
* 12!까지만 32비트(EAX)에 들어가므로 n은 0 ~ 12로 제한됨.

#### N = 3 호출 추적 (스택 쌓이는 과정)

```
① Factorial(3)        ② Factorial(2)        ③ Factorial(1)        ④ Factorial(0)
┌──────────┐          ┌──────────┐          ┌──────────┐          ┌──────────┐
│  N = 3   │[EBP+8]   │  N = 3   │          │  N = 3   │          │  N = 3   │
├──────────┤          ├──────────┤          ├──────────┤          ├──────────┤
│(Ret Addr)│          │(Ret Addr)│          │(Ret Addr)│          │(Ret Addr)│
├──────────┤          ├──────────┤          ├──────────┤          ├──────────┤
│  (EBP)   │←ESP,EBP  │  (EBP)   │          │  (EBP)   │          │  (EBP)   │
└──────────┘          ├──────────┤          ├──────────┤          ├──────────┤
                      │  N = 2   │[EBP+8]   │  N = 2   │          │  N = 2   │
                      ├──────────┤          ├──────────┤          ├──────────┤
                      │(Ret Addr)│          │(Ret Addr)│          │(Ret Addr)│
                      ├──────────┤          ├──────────┤          ├──────────┤
                      │  (EBP)   │←ESP,EBP  │  (EBP)   │          │  (EBP)   │
                      └──────────┘          ├──────────┤          ├──────────┤
                                            │  N = 1   │[EBP+8]   │  N = 1   │
                                            ├──────────┤          ├──────────┤
                                            │(Ret Addr)│          │(Ret Addr)│
                                            ├──────────┤          ├──────────┤
                                            │  (EBP)   │←ESP,EBP  │  (EBP)   │
                                            └──────────┘          ├──────────┤
                                                                  │  N = 0   │[EBP+8]
                                                                  ├──────────┤
                                                                  │(Ret Addr)│
                                                                  ├──────────┤
                                                                  │  (EBP)   │←ESP,EBP
                                                                  └──────────┘
```

#### N = 3 반환 추적 (스택이 되감기는 과정)

| 단계 | 스택 맨 위 프레임 | [EBP + 8] | 동작 | EAX |
| --- | --- | --- | --- | --- |
| ① | N = 0 | 0 | 종료 조건 → EAX = 1 | **1** |
| ② | N = 1 | 1 | EAX × 1 | **1** |
| ③ | N = 2 | 2 | EAX × 2 | **2** |
| ④ | N = 3 | 3 | EAX × 3 | **6** |

* 반환될 때마다 `ret 4` 로 해당 프레임의 N이 제거되고, 이전 프레임의 EBP가 복원되어 `[ebp+8]` 이 **그 단계의 N** 을 다시 가리킴.

---

## 8.4 INVOKE, ADDR, PROC, PROTO

### 1. INVOKE 지시어 (INVOKE Directive)

**INVOKE** 는 32비트 모드에서만 사용 가능하며, 인자를 스택에 push(순서는 `.MODEL` 지시어의 언어 지정자에 따름)하고 프로시저를 호출함. 여러 인자를 **한 줄로** 전달할 수 있어 CALL 명령어의 편리한 대체 수단임.

```assembly
INVOKE procedureName [, argumentList]
```

```assembly
; CALL 사용
push  TYPE array
push  LENGTHOF array
push  OFFSET array
call  DumpArray

; INVOKE 사용 (위와 동일)
INVOKE DumpArray, OFFSET array, LENGTHOF array, TYPE array
```

INVOKE는 거의 모든 개수의 인자를 허용하며, 각 인자를 **별도의 줄**에 쓸 수도 있음.

```assembly
INVOKE DumpArray,               ; displays an array
    OFFSET array,               ; points to the array
    LENGTHOF array,             ; the array length
    TYPE array                  ; array component size
```

#### Table 8-2. INVOKE에 사용되는 인자 타입

| Type | Examples |
| --- | --- |
| Immediate value | `10`, `3000h`, `OFFSET mylist`, `TYPE array` |
| Integer expression | `(10 * 20)`, `COUNT` |
| Variable | `myList`, `array`, `myWord`, `myDword` |
| Address expression | `[myList+2]`, `[ebx + esi]` |
| Register | `eax`, `bl`, `edi` |
| ADDR *name* | `ADDR myList` |
| OFFSET *name* | `OFFSET myList` |

> **INVOKE는 다음을 자동으로 수행해 주는 함수 호출용 매크로**
> 1. 파라미터(push) 순서를 자동으로 맞춰서 스택에 넣고
> 2. call 명령으로 함수 실행
> 3. 호출 규칙(stdcall, cdecl 등)에 따라 스택 정리까지 자동 처리

---

### 2. ADDR 연산자 (ADDR Operator)

**ADDR** 은 32비트 모드에서 INVOKE로 프로시저를 호출할 때 **포인터 인자**를 전달하는 데 사용함.

```assembly
INVOKE FillArray, ADDR myArray          ; myArray의 주소를 FillArray에 전달

INVOKE mySub, ADDR [ebp+12]             ; error
mov    esi, ADDR myArray                ; error
```

* ADDR에 전달하는 인자는 **어셈블 시점 상수(assembly time constant)** 여야 함.
* ADDR 연산자는 **INVOKE와 함께일 때만** 사용할 수 있음.

#### Example

```assembly
.data
Array DWORD 20 DUP(?)
.code
...
INVOKE Swap,                    ; ≡  push  OFFSET Array+4
    ADDR  Array,                ;    push  OFFSET Array
    ADDR  [Array+4]             ;    call  Swap
```

---

### 3. PROC 지시어 (PROC Directive)

**PROC** 은 프로시저를 정의하는 지시어임.

```assembly
label PROC [attributes] [USES reglist], parameter_list
```

`attributes` 는 다음으로 구성됨: `[distance] [langtype] [visibility] [prologuearg]`

#### Table 8-3. PROC 지시어의 속성 필드

| Attribute | Description |
| --- | --- |
| **distance** | NEAR 또는 FAR. 어셈블러가 생성할 RET 명령어 종류(RET 또는 RETF)를 지정 |
| **langtype** | 호출 규약(C, PASCAL, STDCALL 등)을 지정. `.MODEL` 지시어에 지정된 언어를 덮어씀 |
| **visibility** | 다른 모듈에 대한 공개 범위. PRIVATE, PUBLIC(기본값), EXPORT 중 선택. EXPORT면 링커가 프로시저 이름을 export 테이블에 넣으며, PUBLIC도 함께 적용됨 |
| **prologuearg** | 프롤로그/에필로그 코드 생성에 영향을 주는 인자 지정 |

#### 파라미터 리스트 (Parameter Lists)

PROC 지시어로 **쉼표로 구분된 이름 있는 파라미터 목록**을 선언할 수 있음.

```assembly
label PROC [attributes] [USES reglist],
    parameter_1,
    parameter_2,
    .
    .
    parameter_n

label PROC [attributes], parameter_1, parameter_2, ..., parameter_n
```

각 파라미터 형식: `paramName:type`

---

### 4. PROC 예제

#### Example 1: AddTwo

두 개의 doubleword 값을 받아 합을 EAX로 반환함. 왼쪽 소스를 MASM이 오른쪽처럼 변환함.

```assembly
AddTwo PROC,                    ; ⇒  AddTwo PROC
    val1:DWORD,                 ;        push  ebp
    val2:DWORD                  ;        mov   ebp, esp
    mov   eax,val1              ;        mov   eax,dword ptr [ebp+8]
    add   eax,val2              ;        add   eax,dword ptr [ebp+0Ch]
    ret                         ;        leave
AddTwo ENDP                     ;        ret   8
                                ;    AddTwo ENDP
```

#### Example 2: FillArray

바이트 배열에 대한 포인터를 받음.

```assembly
FillArray PROC,
    pArray:PTR BYTE
    . . .
FillArray ENDP
```

#### Example 3: Swap

두 개의 doubleword 포인터를 받음.

```assembly
Swap PROC,
    pValX:PTR DWORD,
    pValY:PTR DWORD
    . . .
Swap ENDP
```

#### Example 4: Read_File

바이트 포인터 `pBuffer` 를 받고, doubleword 지역 변수 `fileHandle` 을 가지며, EAX와 EBX를 스택에 저장함.

```assembly
Read_File PROC USES eax ebx,
    pBuffer:PTR BYTE
    LOCAL fileHandle:DWORD

    mov   esi,pBuffer
    mov   fileHandle,eax
    .
    .
    ret
Read_File ENDP
```

MASM이 생성하는 코드:

```assembly
Read_File PROC
    push  ebp
    mov   ebp,esp
    add   esp,0FFFFFFFCh            ; create fileHandle (= sub esp,4)
    push  eax                       ; save EAX
    push  ebx                       ; save EBX
    mov   esi,dword ptr [ebp+8]     ; pBuffer (parameter)
    mov   dword ptr [ebp-4],eax     ; fileHandle
    pop   ebx
    pop   eax
    leave
    ret   4
Read_File ENDP
```

* 파라미터는 `[ebp+8]`, 지역 변수는 `[ebp-4]` 로 변환됨.
* `USES` 로 지정한 레지스터는 지역 변수 공간 **아래**에 push되고, `leave` 전에 pop됨.

---

### 5. PROC에 의해 수정되는 RET 명령어 (RET Instruction Modified by PROC)

PROC에 파라미터가 하나 이상 있고 STDCALL이 기본 규약이면, n개의 파라미터에 대해 MASM은 다음 진입/종료 코드를 생성함.

```assembly
push  ebp
mov   ebp,esp
.
.
leave
ret   (n*4)
```

---

### 6. 파라미터 분류 (Parameter Classifications)

프로시저 파라미터는 호출 프로그램과 호출된 프로시저 사이의 **데이터 전달 방향**에 따라 분류됨.

| 분류 | 설명 |
| --- | --- |
| **Input Parameter** | 프로시저가 데이터를 **수정하면 안 될 때** 사용 |
| **Output Parameter** | 프로시저가 변수에 **데이터를 대입해야 할 때** 사용 |
| **Input-Output Parameter** | 프로시저가 **기존 데이터를 수정해야 할 때** 사용 |

---

### 7. 예제: 두 정수 교환 (Example: Exchanging Two Integers)

```assembly
; Swap Procedure Example            (Swap.asm)
INCLUDE Irvine32.inc
Swap PROTO, pValX:PTR DWORD, pValY:PTR DWORD

.data
Array DWORD 10000h,20000h

.code
main PROC
    ; Display the array before the exchange:
    mov   esi,OFFSET Array
    mov   ecx,2                     ; count = 2
    mov   ebx,TYPE Array
    call  DumpMem                   ; dump the array values
    INVOKE Swap, ADDR Array, ADDR [Array+4]
    ; Display the array after the exchange:
    call  DumpMem
    exit
main ENDP

;------------------------------------------------------
Swap PROC USES eax esi edi,
    pValX:PTR DWORD,                ; pointer to first integer
    pValY:PTR DWORD                 ; pointer to second integer
;
; Exchange the values of two 32-bit integers
; Returns: nothing
;------------------------------------------------------
    mov   esi,pValX                 ; get pointers
    mov   edi,pValY
    mov   eax,[esi]                 ; get first integer
    xchg  eax,[edi]                 ; exchange with second
    mov   [esi],eax                 ; replace first integer
    ret                             ; PROC generates RET 8 here
Swap ENDP
END main
```

* **PROTO** : 프로시저의 **프로토타입(원형)** 을 선언함. INVOKE로 호출하기 전에 이름과 파라미터 목록을 어셈블러에 알려 주어, 인자 개수·타입을 검사할 수 있게 함.
* `pValX`, `pValY` 는 Input-Output 파라미터 (가리키는 값을 서로 바꿈).
* 파라미터 2개이므로 PROC이 `ret` 을 `ret 8` 로 바꿔 생성함.

---

### 8. 디버깅 팁 (Debugging Tips)

#### ① 인자 크기 불일치 (Argument Size Mismatch)

```assembly
.data
DoubleArray DWORD 10000h,20000h
.code
INVOKE Swap, ADDR [DoubleArray + 0], ADDR [DoubleArray + 1]
```

* DWORD 배열의 두 번째 원소는 `+4` 여야 하는데 `+1` 을 사용 → 엉뚱한 위치의 4바이트를 교환함.

#### ② 잘못된 타입의 포인터 전달 (Passing the Wrong Type of Pointer)

```assembly
.data
ByteArray BYTE 10h,20h,30h,40h,50h,60h,70h,80h
.code
INVOKE Swap, ADDR [ByteArray + 0], ADDR [ByteArray + 1]
```

* Swap은 **doubleword 포인터 두 개**를 기대하는데, 실수로 **byte 포인터**를 전달한 경우 → 4바이트 단위로 교환되어 의도와 다른 결과가 나옴.

#### ③ 즉시값 전달 (Passing Immediate Values)

```assembly
Sub2 PROC, dataPtr:PTR WORD
    mov   esi,dataPtr               ; get the address
    mov   WORD PTR [esi],0          ; dereference, assign zero
    ret
Sub2 ENDP

INVOKE Sub2, 1000h
```

* Sub2는 1000h를 **포인터 값**으로 받아 메모리 주소 1000h를 역참조함 → **runtime error**.

---

### 9. WriteStackFrame 프로시저 (WriteStackFrame Procedure)

Irvine32 라이브러리의 **WriteStackFrame** 은 현재 프로시저의 스택 프레임 내용(스택 파라미터, 복귀 주소, 지역 변수, 저장된 레지스터)을 출력해 주는 유용한 프로시저임.

```assembly
main PROC
    mov   eax, 0EAEAEAEAh
    mov   ebx, 0EBEBEBEBh
    INVOKE myProc, 1111h, 2222h     ; pass two integer arguments
    exit
main ENDP

myProc PROC USES eax ebx,
    x: DWORD, y: DWORD
    LOCAL a:DWORD, b:DWORD

    PARAMS = 2
    LOCALS = 2
    SAVED_REGS = 2
    mov   a,0AAAAh
    mov   b,0BBBBh
    INVOKE WriteStackFrame, PARAMS, LOCALS, SAVED_REGS
```

#### 출력 결과

```
Stack Frame

00002222 ebp+12 (parameter)
00001111 ebp+8 (parameter)
00401083 ebp+4 (return address)
0012FFF0 ebp+0 (saved ebp) <--- ebp
0000AAAA ebp-4 (local variable)
0000BBBB ebp-8 (local variable)
EAEAEAEA ebp-12 (saved register)
EBEBEBEB ebp-16 (saved register) <--- esp
```

* 파라미터는 EBP **위쪽(+)**, 지역 변수와 저장 레지스터는 EBP **아래쪽(−)** 에 위치함을 확인할 수 있음.

---

## 8.5 다중 모듈 프로그램 작성 (Creating Multimodule Programs)

### 1. 다중 모듈의 장점

* 각 모듈은 **독립적으로 어셈블**되므로, 한 모듈의 소스가 바뀌면 그 모듈만 다시 어셈블하면 됨.
* 링커가 어셈블된 모듈들(**OBJ 파일**)을 하나의 실행 파일로 빠르게 결합함.
* 많은 오브젝트 모듈을 링크하는 것은 같은 수의 소스 파일을 어셈블하는 것보다 **훨씬 빠름**.

| 방식 | 설명 |
| --- | --- |
| **Traditional** | 이식성을 위해 **EXTERN** 지시어 사용 |
| **Microsoft Advanced** | 간결함을 위해 **INVOKE와 PROTO** 사용 |

---

### 2. 프로시저 이름 숨기기와 내보내기 (Hiding and Exporting Procedure Names)

기본적으로 MASM은 **모든 프로시저를 public** 으로 만들어, 같은 프로그램의 다른 모듈에서 호출할 수 있게 함. **PRIVATE** 한정자로 이를 바꿀 수 있음.

```assembly
mySub PROC PRIVATE
```

* 프로시저를 private으로 만들면 **캡슐화(encapsulation)** 원칙에 따라 모듈 내부에 숨길 수 있고, 다른 모듈에 같은 이름의 프로시저가 있어도 **이름 충돌을 피할 수 있음**.

#### OPTION PROC:PRIVATE 지시어

파일 맨 위에 `OPTION PROC:PRIVATE` 를 두면 **모든 프로시저가 기본적으로 private** 이 됨. 내보낼 프로시저만 **PUBLIC** 지시어로 지정함.

```assembly
OPTION PROC:PRIVATE
PUBLIC mySub
```

PUBLIC 지시어는 쉼표로 구분된 이름 목록을 받음.

```assembly
PUBLIC sub1, sub2, sub3
```

또는 개별 프로시저를 public으로 지정할 수도 있음.

```assembly
mySub PROC PUBLIC
.
mySub ENDP
```

> 시작 모듈에서 `OPTION PROC:PRIVATE` 를 사용한다면, 시작 프로시저(보통 main)를 반드시 **PUBLIC** 으로 지정해야 함. 그렇지 않으면 운영체제 로더가 찾지 못함.

```assembly
main PROC PUBLIC
```

---

### 3. 외부 프로시저 호출 (Calling External Procedures)

**EXTERN** 지시어는 현재 모듈 밖의 프로시저를 호출할 때 사용하며, 프로시저의 **이름과 스택 프레임 크기**를 지정함.

```assembly
INCLUDE Irvine32.inc
EXTERN sub1@0:PROC
.code
main PROC
    call  sub1@0
    exit
main ENDP
END main
```

* 프로시저 이름 끝의 **@n 접미사**는 선언된 파라미터가 사용하는 **전체 스택 공간(바이트)** 을 나타냄.
* 확장 PROC 지시어로 선언한 프로시저라면 **파라미터 하나당 4바이트**를 더함.

```assembly
AddTwo PROC,
    val1:DWORD,
    val2:DWORD
    . . .
AddTwo ENDP
```

→ 파라미터 2개 × 4바이트 = 8 이므로:

```assembly
EXTERN AddTwo@8:PROC
```

PROTO를 사용하면 EXTERN 대신 다음처럼 선언할 수 있음.

```assembly
AddTwo PROTO,
    val1:DWORD,
    val2:DWORD
```

---

### 4. 모듈 경계를 넘는 변수와 심볼 (Using Variables and Symbols across Module Boundaries)

#### ① 변수와 심볼 내보내기 (Exporting Variables and Symbols)

변수와 심볼은 기본적으로 **자신이 속한 모듈에 private** 임. **PUBLIC** 지시어로 특정 이름을 내보낼 수 있음.

```assembly
PUBLIC count, SYM1
SYM1 = 10
.data
count DWORD 0
```

#### ② 외부 변수와 심볼 접근 (Accessing External Variables and Symbols)

```assembly
EXTERN name : type
```

```assembly
EXTERN one:WORD, two:SDWORD, three:PTR BYTE, four:ABS
```

* 변수는 BYTE, WORD, DWORD 등 크기 타입을, 상수 심볼(`=` 이나 EQU로 정의)은 **ABS** 타입을 사용함.

---

### 5. EXTERNDEF를 사용한 INCLUDE 파일 (Using an INCLUDE File with EXTERNDEF)

MASM의 **EXTERNDEF** 지시어는 **PUBLIC과 EXTERN을 모두 대신**함. 공유할 선언을 INCLUDE 파일에 모아 두고 각 모듈에서 include하면 됨.

```assembly
; vars.inc
EXTERNDEF count:DWORD, SYM1:ABS
```

```assembly
; sub1.asm
.386
.model flat,STDCALL
INCLUDE vars.inc
SYM1 = 10
.data
count DWORD 0
END
```

```assembly
; main.asm
.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword
INCLUDE vars.inc
.code
main PROC
    mov   count,2000h
    mov   eax,SYM1
    INVOKE ExitProcess,0
main ENDP
END main
```

* `sub1.asm` 처럼 **정의하는 모듈**에서는 EXTERNDEF가 PUBLIC처럼, `main.asm` 처럼 **사용하는 모듈**에서는 EXTERN처럼 동작함.

---

### 6. 예제: ArraySum 프로그램 (Example: ArraySum Program)

#### Figure 8-5. Structure chart, ArraySum program

```
                     ┌─────────────────────┐
                     │ ArraySum Program    │
                     │      (main)         │
                     └──────────┬──────────┘
      ┌──────────────┬──────────┴───┬─────────────────┐
┌─────┴─────┐ ┌──────┴───────────┐ ┌┴─────────┐ ┌─────┴──────┐
│  Clrscr*  │ │PromptForIntegers │ │ ArraySum │ │ DisplaySum │
└───────────┘ └──────┬───────────┘ └──────────┘ └─────┬──────┘
               ┌─────┴──────┐                   ┌─────┴──────┐
         ┌─────┴──────┐ ┌───┴─────┐       ┌─────┴──────┐ ┌───┴──────┐
         │WriteString*│ │ReadInt* │       │WriteString*│ │WriteInt* │
         └────────────┘ └─────────┘       └────────────┘ └──────────┘

  * = Irvine32 라이브러리 프로시저
```

* main이 **Clrscr → PromptForIntegers → ArraySum → DisplaySum** 순서로 호출함.
* PromptForIntegers, ArraySum, DisplaySum을 **각각 별도의 모듈**로 분리하여 다중 모듈 프로그램으로 작성할 수 있음 (EXTERN 방식 또는 INVOKE/PROTO 방식).

---

## 8.9 주요 요약 및 학습 키워드 (Key Terms)

* **Stack Frame (Activation Record)**: 인자, 복귀 주소, 지역 변수, 저장된 레지스터를 위해 스택에 마련된 영역. `push ebp / mov ebp, esp` 로 EBP를 기준점으로 설정.

* **Passing by Value / by Reference**: 값 전달은 값의 복사본을, 참조 전달은 주소(offset)를 push. 배열은 항상 참조로 전달.

* **Stack Parameter 접근**: [EBP + 4] = 복귀 주소, [EBP + 8] = 첫 번째 파라미터, [EBP + 12] = 두 번째 파라미터. EQU로 이름을 붙이면 explicit stack parameter.

* **C Calling Convention**: 역순 push, 호출자가 `add esp, n` 으로 스택 정리.

* **STDCALL**: 역순 push, 피호출자가 `ret n` 으로 스택 정리. n = 파라미터 바이트 수.

* **Local Variables**: EBP 아래([EBP − 4], [EBP − 8], ...)에 `sub esp, n` 으로 생성, `mov esp, ebp` 로 해제.

* **LEA**: 간접 피연산자의 주소를 런타임에 계산. 스택 위 지역 변수의 주소를 구할 때 사용 (OFFSET은 불가).

* **ENTER / LEAVE**: `enter n, 0` = `push ebp / mov ebp, esp / sub esp, n`, `leave` = `mov esp, ebp / pop ebp`. 항상 짝으로 사용.

* **LOCAL**: 이름과 타입이 있는 지역 변수 선언. PROC 바로 다음 줄에 위치.

* **Recursion**: 자기 자신을 호출하는 서브루틴. 반드시 종료 조건 필요(없으면 스택 오버플로). 되감기(unwind) 시 스택에 저장된 파라미터를 활용 (예: Factorial).

* **INVOKE**: 인자 push + call + 스택 정리를 한 줄로 처리하는 32비트 전용 지시어.

* **ADDR**: INVOKE와 함께만 사용 가능한 포인터 전달 연산자. 인자는 어셈블 시점 상수여야 함.

* **PROC / PROTO**: PROC은 이름 있는 파라미터·속성·USES를 갖는 프로시저 정의, PROTO는 프로시저 원형 선언. 파라미터가 n개면 MASM이 `ret` 을 `ret (n*4)` 로 생성.

* **Parameter Classifications**: Input, Output, Input-Output.

* **WriteStackFrame**: 현재 스택 프레임(파라미터, 복귀 주소, 지역 변수, 저장 레지스터)을 출력하는 Irvine32 프로시저.

* **Multimodule Programs**: 모듈별 독립 어셈블 후 링크. PRIVATE / PUBLIC / `OPTION PROC:PRIVATE` 로 프로시저 공개 범위 제어.

* **EXTERN / EXTERNDEF**: EXTERN은 외부 프로시저·변수 참조(`name@n:PROC`, n = 파라미터 바이트 수), EXTERNDEF는 PUBLIC과 EXTERN을 모두 대신하며 INCLUDE 파일과 함께 사용.
