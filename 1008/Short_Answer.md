# Review Question and Exercises

## Short Answer

1. 32비트 범용 레지스터 전체를 스택에 push하는 명령어는 무엇인가요?
* Which instruction pushes all of the 32-bit general-purpose registers on the stack?
* Answer: `PUSHAD` (EAX, ECX, EDX, EBX, ESP(원래 값), EBP, ESI, EDI 순서로 push합니다.)




2. 32비트 EFLAGS 레지스터를 스택에 push하는 명령어는 무엇인가요?
* Which instruction pushes the 32-bit EFLAGS register on the stack?
* Answer: `PUSHFD`




3. 스택의 값을 EFLAGS 레지스터로 pop하는 명령어는 무엇인가요?
* Which instruction pops the stack into the EFLAGS register?
* Answer: `POPFD`




4. 도전 문제: 다른 어셈블러(NASM)는 PUSH 명령어에 여러 개의 특정 레지스터를 나열할 수 있게 해줍니다. 이 방식이 MASM의 PUSHAD 명령어보다 나은 이유는 무엇일까요? 다음은 NASM 예시입니다.
* Challenge: Another assembler (called NASM) permits the PUSH instruction to list multiple specific registers. Why might this approach be better than the PUSHAD instruction in MASM? Here is a NASM example:
```assembly
PUSH EAX EBX ECX

```
* Answer:
* **효율성:** PUSHAD는 실제로 사용하지 않는 레지스터까지 8개를 모두 push하므로 스택 공간(32바이트)과 실행 시간이 낭비됩니다. 필요한 레지스터만 나열하면 그만큼만 저장/복원합니다.
* **반환값 보존:** PUSHAD/POPAD를 쓰면 프로시저가 끝날 때 POPAD가 EAX 등 모든 레지스터를 원래 값으로 덮어쓰므로, EAX로 반환값을 돌려줄 수 없습니다. 특정 레지스터만 지정하면 반환용 레지스터를 제외할 수 있습니다.




5. 도전 문제: PUSH 명령어가 없다고 가정하세요. `push eax`와 같은 동작을 하는 다른 두 개의 명령어 시퀀스를 작성하세요.
* Challenge: Suppose there were no PUSH instruction. Write a sequence of two other instructions that would accomplish the same as push eax.
* Answer:
```assembly
sub esp,4          ; ESP를 4 감소 (스택 공간 확보)
mov [esp],eax      ; ESP가 가리키는 위치에 EAX 복사

```




6. (참/거짓): RET 명령어는 스택의 맨 위 값을 명령어 포인터(instruction pointer)로 pop한다.
* (True/False): The RET instruction pops the top of the stack into the instruction pointer.
* Answer: True (스택에 저장된 반환 주소를 EIP로 pop하여 호출한 곳으로 돌아갑니다.)


7. (참/거짓): 프로시저 정의에 NESTED 연산자를 사용하지 않으면 Microsoft 어셈블러에서는 중첩 프로시저 호출이 허용되지 않는다.
* (True/False): Nested procedure calls are not permitted by the Microsoft assembler unless the NESTED operator is used in the procedure definition.
* Answer: False (NESTED 연산자는 존재하지 않으며, 중첩 호출은 별도 지시 없이 허용됩니다.)


8. (참/거짓): 보호 모드에서 각 프로시저 호출은 최소 4바이트의 스택 공간을 사용한다.
* (True/False): In protected mode, each procedure call uses a minimum of 4 bytes of stack space.
* Answer: True (CALL이 32비트 반환 주소를 스택에 push하기 때문입니다.)


9. (참/거짓): 프로시저에 32비트 매개변수를 전달할 때 ESI와 EDI 레지스터는 사용할 수 없다.
* (True/False): The ESI and EDI registers cannot be used when passing 32-bit parameters to procedures.
* Answer: False (ArraySum처럼 ESI로 배열 주소를 전달하는 등 자유롭게 사용할 수 있습니다.)


10. (참/거짓): ArraySum 프로시저(5.2.5절)는 doubleword로 이루어진 어떤 배열의 포인터든 받을 수 있다.
* (True/False): The ArraySum procedure (Section 5.2.5) receives a pointer to any array of doublewords.
* Answer: True (배열 이름이나 크기에 의존하지 않고 ESI = 주소, ECX = 개수로 전달받습니다.)


11. (참/거짓): USES 연산자는 프로시저 안에서 수정되는 모든 레지스터의 이름을 지정할 수 있게 해준다.
* (True/False): The USES operator lets you name all registers that are modified within a procedure.
* Answer: True


12. (참/거짓): USES 연산자는 PUSH 명령어만 생성하므로, POP 명령어는 직접 작성해야 한다.
* (True/False): The USES operator only generates PUSH instructions, so you must code POP instructions yourself.
* Answer: False (어셈블러가 프로시저 시작 부분에 PUSH를, RET 직전에 POP을 모두 자동으로 생성합니다.)


13. (참/거짓): USES 지시어의 레지스터 목록은 쉼표로 레지스터 이름을 구분해야 한다.
* (True/False): The register list in the USES directive must use commas to separate the register names.
* Answer: False (공백으로 구분합니다. 예: `USES esi ecx`)




14. ArraySum 프로시저(5.2.5절)가 16비트 word 배열을 누적하도록 하려면 어떤 문장을 수정해야 하나요? 그런 버전의 ArraySum을 만들고 테스트하세요.
* Which statement(s) in the ArraySum procedure (Section 5.2.5) would have to be modified so it could accumulate an array of 16-bit words? Create such a version of ArraySum and test it.
* Answer:
* 수정해야 할 문장
  * `add eax,[esi]` → 16비트 값을 읽도록 변경 (`movzx`로 확장한 뒤 더하거나 `add ax,[esi]`)
  * `add esi,TYPE DWORD` → `add esi,TYPE WORD` (다음 요소까지의 간격이 2바이트)
* 합계가 16비트를 넘을 수 있으므로 아래 버전은 MOVZX로 확장한 뒤 32비트 EAX에 누적합니다.
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
array  WORD  1000h,2000h,3000h,4000h,0F000h
theSum DWORD ?

.code
main proc
    mov esi, OFFSET array              ; ESI = 배열 주소
    mov ecx, LENGTHOF array            ; ECX = 요소 개수
    call ArraySumW
    mov theSum, eax                    ; theSum = 0001E000h

    invoke ExitProcess, 0
main endp

;-----------------------------------------------------
; ArraySumW
;
; Calculates the sum of an array of 16-bit integers.
; Receives: ESI = the array offset
;           ECX = number of elements in the array
; Returns:  EAX = sum of the array elements
;-----------------------------------------------------
ArraySumW proc
    push esi                           ; ESI, ECX, EDX 저장
    push ecx
    push edx
    mov eax, 0                         ; 합계 = 0

L1:
    movzx edx, WORD PTR [esi]          ; 16비트 값을 32비트로 확장
    add eax, edx                       ; 합계에 더함
    add esi, TYPE WORD                 ; 다음 word로 이동 (2바이트)
    loop L1

    pop edx                            ; EDX, ECX, ESI 복원
    pop ecx
    pop esi
    ret                                ; 합계는 EAX
ArraySumW endp
end main

```




15. 다음 명령어들이 실행된 후 EAX의 최종 값은 무엇인가요?
* What will be the final value in EAX after these instructions execute?
```assembly
push 5
push 6
pop  eax
pop  eax

```
* Answer: `EAX = 5` (첫 번째 pop은 마지막에 push된 6을, 두 번째 pop은 5를 꺼냅니다.)




16. 다음 예제 코드를 실행했을 때 일어나는 일에 대해 올바른 설명은 무엇인가요?
* Which statement is true about what will happen when the example code runs?
```assembly
1:  main PROC
2:      push 10
3:      push 20
4:      call Ex2Sub
5:      pop  eax
6:      INVOKE ExitProcess,0
7:  main ENDP
8:
9:  Ex2Sub PROC
10:     pop  eax
11:     ret
12: Ex2Sub ENDP

```
* a. EAX will equal 10 on line 6 (6번 줄에서 EAX는 10이 된다)
* b. The program will halt with a runtime error on Line 10 (10번 줄에서 런타임 오류로 중단된다)
* c. EAX will equal 20 on line 6 (6번 줄에서 EAX는 20이 된다)
* d. The program will halt with a runtime error on Line 11 (11번 줄에서 런타임 오류로 중단된다)
* Answer: **d**
* 10번 줄의 `pop eax`가 CALL이 저장한 반환 주소를 꺼내버리므로, 11번 줄의 `ret`는 스택 맨 위의 20을 반환 주소로 사용합니다. 주소 20(00000014h)으로 점프하면서 런타임 오류가 발생합니다.




17. 다음 예제 코드를 실행했을 때 일어나는 일에 대해 올바른 설명은 무엇인가요?
* Which statement is true about what will happen when the example code runs?
```assembly
1:  main PROC
2:      mov  eax,30
3:      push eax
4:      push 40
5:      call Ex3Sub
6:      INVOKE ExitProcess,0
7:  main ENDP
8:
9:  Ex3Sub PROC
10:     pusha
11:     mov eax,80
12:     popa
13:     ret
14: Ex3Sub ENDP

```
* a. EAX will equal 40 on line 6 (6번 줄에서 EAX는 40이 된다)
* b. The program will halt with a runtime error on Line 6 (6번 줄에서 런타임 오류로 중단된다)
* c. EAX will equal 30 on line 6 (6번 줄에서 EAX는 30이 된다)
* d. The program will halt with a runtime error on Line 13 (13번 줄에서 런타임 오류로 중단된다)
* Answer: **c**
* `pusha`와 `popa`가 짝을 이루므로 스택이 균형을 유지하고, `popa`가 AX를 원래 값(30)으로 복원합니다. 따라서 `ret`는 정상적으로 6번 줄로 돌아오고 EAX = 30입니다.




18. 다음 예제 코드를 실행했을 때 일어나는 일에 대해 올바른 설명은 무엇인가요?
* Which statement is true about what will happen when the example code runs?
```assembly
1:  main PROC
2:      mov  eax,40
3:      push offset Here
4:      jmp  Ex4Sub
5:  Here:
6:      mov  eax,30
7:      INVOKE ExitProcess,0
8:  main ENDP
9:
10: Ex4Sub PROC
11:     ret
12: Ex4Sub ENDP

```
* a. EAX will equal 30 on line 7 (7번 줄에서 EAX는 30이 된다)
* b. The program will halt with a runtime error on Line 4 (4번 줄에서 런타임 오류로 중단된다)
* c. EAX will equal 30 on line 6 (6번 줄에서 EAX는 30이 된다)
* d. The program will halt with a runtime error on Line 11 (11번 줄에서 런타임 오류로 중단된다)
* Answer: **a**
* `push offset Here` + `jmp Ex4Sub`는 CALL을 흉내 낸 것입니다. `ret`가 Here의 주소를 pop하여 5번 줄로 돌아오고, 6번 줄의 `mov eax,30`이 실행되므로 7번 줄에서 EAX = 30입니다.




19. 다음 예제 코드를 실행했을 때 일어나는 일에 대해 올바른 설명은 무엇인가요?
* Which statement is true about what will happen when the example code runs?
```assembly
1:  main PROC
2:      mov  edx,0
3:      mov  eax,40
4:      push eax
5:      call Ex5Sub
6:      INVOKE ExitProcess,0
7:  main ENDP
8:
9:  Ex5Sub PROC
10:     pop  eax
11:     pop  edx
12:     push eax
13:     ret
14: Ex5Sub ENDP

```
* a. EDX will equal 40 on line 6 (6번 줄에서 EDX는 40이 된다)
* b. The program will halt with a runtime error on Line 13 (13번 줄에서 런타임 오류로 중단된다)
* c. EDX will equal 0 on line 6 (6번 줄에서 EDX는 0이 된다)
* d. The program will halt with a runtime error on Line 11 (11번 줄에서 런타임 오류로 중단된다)
* Answer: **a**
* 10번 줄에서 반환 주소를 EAX로 꺼내고, 11번 줄에서 main이 push한 40을 EDX로 꺼낸 뒤, 12번 줄에서 반환 주소를 다시 push합니다. 따라서 `ret`는 정상적으로 돌아오고 EDX = 40입니다.




20. 다음 코드가 실행되면 배열에 어떤 값들이 기록되나요?
* What values will be written to the array when the following code executes?
```assembly
.data
array DWORD 4 DUP(0)
.code
main PROC
    mov  eax,10
    mov  esi,0
    call proc_1
    add  esi,4
    add  eax,10
    mov  array[esi],eax
    INVOKE ExitProcess,0
main ENDP

proc_1 PROC
    call proc_2
    add  esi,4
    add  eax,10
    mov  array[esi],eax
    ret
proc_1 ENDP

proc_2 PROC
    call proc_3
    add  esi,4
    add  eax,10
    mov  array[esi],eax
    ret
proc_2 ENDP

proc_3 PROC
    mov  array[esi],eax
    ret
proc_3 ENDP

```
* Answer: `array = 10, 20, 30, 40`
* **proc_3:** `array[0] = 10` (ESI = 0, EAX = 10)
* **proc_2:** `array[4] = 20` (ESI = 4, EAX = 20)
* **proc_1:** `array[8] = 30` (ESI = 8, EAX = 30)
* **main:** `array[12] = 40` (ESI = 12, EAX = 40)
