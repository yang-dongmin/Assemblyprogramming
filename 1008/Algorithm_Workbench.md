# Review Question and Exercises

## Algorithm Workbench

* 다음 문제들은 32비트 또는 64비트 코드로 풀 수 있습니다.
* The following exercises can be solved using either 32-bit or 64-bit code.




1. PUSH와 POP 명령어만 사용하여 EAX와 EBX 레지스터(64비트 모드에서는 RAX와 RBX)의 값을 교환하는 문장 시퀀스를 작성하세요.
* Write a sequence of statements that use only PUSH and POP instructions to exchange the values in the EAX and EBX registers (or RAX and RBX in 64-bit mode).
* Answer:
```assembly
push eax          ; 스택: EAX
push ebx          ; 스택: EAX, EBX
pop  eax          ; EAX = 기존 EBX
pop  ebx          ; EBX = 기존 EAX

```




2. 서브루틴이 현재 스택에 있는 반환 주소보다 메모리상 3바이트 높은 주소로 돌아가게 하고 싶다고 가정하세요. 이를 수행하기 위해 서브루틴의 RET 명령어 바로 앞에 삽입할 명령어 시퀀스를 작성하세요.
* Suppose you wanted a subroutine to return to an address that was 3 bytes higher in memory than the return address currently on the stack. Write a sequence of instructions that would be inserted just before the subroutine's RET instruction that accomplish this task.
* Answer:
```assembly
add DWORD PTR [esp],3   ; 스택 맨 위의 반환 주소에 3을 더함
ret                     ; 반환 주소 + 3 위치로 돌아감

```




3. 고급 언어의 함수는 종종 스택에서 반환 주소 바로 아래에 지역 변수를 선언합니다. 어셈블리 언어 서브루틴의 시작 부분에 넣어 두 개의 doubleword 정수 변수를 위한 공간을 확보하는 명령어를 작성하세요. 그런 다음 두 지역 변수에 1000h와 2000h를 대입하세요.
* Functions in high-level languages often declare local variables just below the return address on the stack. Write an instruction that you could put at the beginning of an assembly language subroutine that would reserve space for two integer doubleword variables. Then, assign the values 1000h and 2000h to the two local variables.
* Answer:
```assembly
MySub PROC
    sub esp,8                       ; doubleword 2개(8바이트) 공간 확보
    mov DWORD PTR [esp],1000h       ; 첫 번째 지역 변수 = 1000h
    mov DWORD PTR [esp+4],2000h     ; 두 번째 지역 변수 = 2000h
    ; ...
    add esp,8                       ; 반환 전에 지역 변수 공간 해제
    ret
MySub ENDP

```


* **설명:** CALL 직후 ESP는 반환 주소를 가리키므로, ESP를 8 감소시키면 반환 주소 바로 아래에 8바이트 공간이 생깁니다. RET 전에 반드시 `add esp,8`로 ESP를 반환 주소 위치로 되돌려야 합니다.




4. 인덱스 주소 지정 방식을 사용하여 doubleword 배열의 한 요소를 같은 배열의 바로 앞 위치로 복사하는 문장 시퀀스를 작성하세요.
* Write a sequence of statements using indexed addressing that copies an element in a doubleword array to the previous position in the same array.
* Answer:
```assembly
.data
array DWORD 10,20,30,40,50
.code
mov esi,3                                   ; 복사할 요소의 인덱스 (40)
mov eax,array[esi*TYPE array]               ; EAX = array[3]
mov array[esi*TYPE array - TYPE array],eax  ; array[2] = array[3]
; 결과: 10,20,40,40,50

```




5. 서브루틴의 반환 주소를 화면에 출력하는 문장 시퀀스를 작성하세요. 스택에 가하는 어떤 수정도 서브루틴이 호출자에게 돌아가는 것을 방해하지 않도록 하세요.
* Write a sequence of statements that display a subroutine's return address. Be sure that whatever modifications you make to the stack do not prevent the subroutine from returning to its caller.
* Answer:
```assembly
INCLUDE Irvine32.inc

ShowReturn PROC
    push eax                  ; EAX 보존 (ESP가 4 감소)
    mov  eax,[esp+4]          ; 반환 주소는 push한 EAX 바로 위에 있음
    call WriteHex             ; 반환 주소를 16진수로 출력
    call Crlf
    pop  eax                  ; EAX 복원 → ESP가 다시 반환 주소를 가리킴
    ret
ShowReturn ENDP

```


* **설명:** 반환 주소를 pop하지 않고 `[esp+4]`로 읽기만 하므로 스택 내용이 바뀌지 않습니다. push와 pop의 개수가 같아 RET 실행 시 ESP가 정확히 반환 주소를 가리킵니다.
