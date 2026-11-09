# Review Question and Exercises

## Algorithm Workbench

1. 다음은 세 doubleword를 더하는 AddThree 프로시저의 호출 순서입니다 (STDCALL 호출 규약을 사용한다고 가정). EBP가 런타임 스택에 push된 직후의 스택 프레임을 그림으로 나타내세요.
* Here is a calling sequence for a procedure named AddThree that adds three doublewords (assume that the STDCALL calling convention is used):
```assembly
push 10h
push 20h
push 30h
call AddThree

```
* Draw a picture of the procedure's stack frame immediately after EBP has been pushed on the runtime stack.
* Answer:
```
┌────────────────┐
│      10h       │  [EBP + 16]
├────────────────┤
│      20h       │  [EBP + 12]
├────────────────┤
│      30h       │  [EBP + 8]
├────────────────┤
│ return address │  [EBP + 4]
├────────────────┤
│   saved EBP    │  ← ESP  (mov ebp,esp 이후에는 EBP도 여기)
└────────────────┘
```


* **설명:** 스택은 아래(낮은 주소) 방향으로 자라므로 먼저 push한 10h가 가장 높은 주소에 있습니다. 마지막에 push한 30h가 첫 번째 파라미터 `[EBP + 8]` 이 됩니다.




2. 세 정수 파라미터를 받아 합을 계산하고 EAX 레지스터로 반환하는 AddThree 프로시저를 작성하세요.
* Create a procedure named AddThree that receives three integer parameters and calculates and returns their sum in the EAX register.
* Answer:
```assembly
AddThree PROC
    push ebp
    mov  ebp,esp
    mov  eax,[ebp + 8]      ; 첫 번째 파라미터
    add  eax,[ebp + 12]     ; 두 번째 파라미터
    add  eax,[ebp + 16]     ; 세 번째 파라미터
    pop  ebp
    ret  12                 ; STDCALL: 파라미터 3개 * 4바이트 정리
AddThree ENDP

```


* PROC 지시어의 파라미터 목록을 사용하면 다음처럼 쓸 수 있습니다. (MASM이 `push ebp / mov ebp,esp` 와 `leave / ret 12` 를 자동 생성)
```assembly
AddThree PROC,
    val1:DWORD, val2:DWORD, val3:DWORD
    mov eax,val1
    add eax,val2
    add eax,val3
    ret
AddThree ENDP

```




3. doubleword 배열을 가리키는 포인터인 지역 변수 pArray를 선언하세요.
* Declare a local variable named pArray that is a pointer to an array of doublewords.
* Answer:
```assembly
LOCAL pArray:PTR DWORD

```




4. 20바이트 배열인 지역 변수 buffer를 선언하세요.
* Declare a local variable named buffer that is an array of 20 bytes.
* Answer:
```assembly
LOCAL buffer[20]:BYTE

```




5. 16비트 부호 없는 정수를 가리키는 지역 변수 pwArray를 선언하세요.
* Declare a local variable named pwArray that points to a 16-bit unsigned integer.
* Answer:
```assembly
LOCAL pwArray:PTR WORD

```




6. 8비트 부호 있는 정수를 저장하는 지역 변수 myByte를 선언하세요.
* Declare a local variable named myByte that holds an 8-bit signed integer.
* Answer:
```assembly
LOCAL myByte:SBYTE

```




7. 20개의 doubleword 배열인 지역 변수 myArray를 선언하세요.
* Declare a local variable named myArray that is an array of 20 doublewords.
* Answer:
```assembly
LOCAL myArray[20]:DWORD

```


* **설명:** LOCAL 지시어는 PROC 지시어 **바로 다음 줄**에 와야 합니다. (3 ~ 7번 모두 동일)




8. 두 스택 파라미터 forecolor와 backcolor를 받아 Irvine32 라이브러리의 SetTextColor 프로시저를 호출하는 SetColor 프로시저를 작성하세요.
* Create a procedure named SetColor that receives two stack parameters: forecolor and backcolor, and calls the SetTextColor procedure from the Irvine32 library.
* Answer:
```assembly
SetColor PROC USES eax,
    forecolor:DWORD,
    backcolor:DWORD
    mov  eax,backcolor
    shl  eax,4              ; 배경색 * 16 (상위 4비트)
    add  eax,forecolor      ; 글자색 (하위 4비트)
    call SetTextColor
    ret
SetColor ENDP

```


* **설명:** SetTextColor는 EAX = `foreground + (background * 16)` 형식의 색상 값을 받습니다. 호출 예: `INVOKE SetColor, yellow, blue`




9. 세 스택 파라미터 char, forecolor, backcolor를 받는 WriteColorChar 프로시저를 작성하세요. forecolor와 backcolor로 지정한 색상 속성으로 문자 하나를 출력합니다.
* Create a procedure named WriteColorChar that receives three stack parameters: char, forecolor, and backcolor. It displays a single character, using the color attributes specified in forecolor and backcolor.
* Answer:
```assembly
WriteColorChar PROC USES eax,
    char:BYTE,
    forecolor:DWORD,
    backcolor:DWORD
    INVOKE SetColor, forecolor, backcolor   ; 8번의 SetColor 사용
    mov  al,char
    call WriteChar                          ; 문자 출력
    INVOKE SetColor, lightGray, black       ; 기본 색으로 복원
    ret
WriteColorChar ENDP

```


* 호출 예: `INVOKE WriteColorChar, 'A', white, red`




10. Irvine32 라이브러리의 DumpMem 프로시저를 감싸는(encapsulate) DumpMemory 프로시저를 작성하세요. 선언된 파라미터와 USES 지시어를 사용하세요. 호출 예: `INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array`
* Write a procedure named DumpMemory that encapsulates the DumpMem procedure in the Irvine32 library. Use declared parameters and the USES directive. The following is an example of how it should be called: INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array.
* Answer:
```assembly
DumpMemory PROC USES esi ecx ebx,
    address:DWORD,          ; 시작 주소
    numItems:DWORD,         ; 출력할 원소 개수
    itemSize:DWORD          ; 원소 크기 (1, 2, 4)
    mov  esi,address
    mov  ecx,numItems
    mov  ebx,itemSize
    call DumpMem
    ret
DumpMemory ENDP

```


* **설명:** DumpMem은 ESI = 시작 주소, ECX = 개수, EBX = 크기를 레지스터로 받습니다. DumpMemory는 이를 스택 파라미터로 받아 레지스터에 옮긴 뒤 호출하고, USES로 변경한 레지스터를 보존합니다. (`LENGTH`, `SIZE` 는 MASM 예약어이므로 파라미터 이름으로 쓰지 않습니다.)




11. 두 doubleword 배열에 대한 포인터와, 배열 원소 개수를 나타내는 세 번째 파라미터를 받는 MultArray 프로시저를 선언하세요. 또한 이 프로시저의 PROTO 선언도 작성하세요.
* Declare a procedure named MultArray that receives two pointers to arrays of doublewords, and a third parameter indicating the number of array elements. Also, create a PROTO declaration for this procedure.
* Answer:
```assembly
; 프로토타입 선언
MultArray PROTO,
    pArray1:PTR DWORD,
    pArray2:PTR DWORD,
    numElements:DWORD

; 프로시저 선언
MultArray PROC,
    pArray1:PTR DWORD,
    pArray2:PTR DWORD,
    numElements:DWORD
    ; ...
    ret
MultArray ENDP

```


* **설명:** PROTO는 PROC와 같은 파라미터 목록을 가지며, INVOKE로 프로시저를 정의보다 먼저 호출할 수 있게 해 줍니다.
