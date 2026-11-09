# Review Question and Exercises

## Short Answer

1. 프로시저에 스택 파라미터와 지역 변수가 있을 때, 프로시저의 에필로그(epilogue)에는 어떤 문장들이 들어가나요?
* Which statements belong in a procedure's epilogue when the procedure has stack parameters and local variables?
* Answer:
```assembly
mov esp,ebp       ; 지역 변수 해제 (ESP를 EBP 위치로 되돌림)
pop ebp           ; 호출자의 EBP 복원
ret               ; (STDCALL이면 ret n 으로 스택 파라미터까지 정리)

```
* `mov esp, ebp` / `pop ebp` 두 줄은 `leave` 한 줄로 대신할 수 있습니다. 프롤로그에서 레지스터를 저장했다면 `mov esp, ebp` 전에 먼저 pop으로 복원합니다.




2. C 함수가 32비트 정수를 반환할 때, 반환값은 어디에 저장되나요?
* When a C function returns a 32-bit integer, where is the return value stored?
* Answer: `EAX` 레지스터




3. STDCALL 호출 규약을 사용하는 프로그램은 프로시저 호출 후 스택을 어떻게 정리하나요?
* How does a program using the STDCALL calling convention clean up the stack after a procedure call?
* Answer: 호출된 프로시저가 `RET n` 처럼 RET 명령어에 정수 피연산자를 주어 정리합니다. RET은 복귀 주소를 pop한 뒤 ESP에 n을 더하며, n은 파라미터가 차지한 스택 바이트 수와 같아야 합니다. (예: 파라미터 2개 → `ret 8`)




4. LEA 명령어는 OFFSET 연산자보다 어떤 점에서 더 강력한가요?
* How is the LEA instruction more powerful than the OFFSET operator?
* Answer: OFFSET은 **어셈블 시점**에 주소가 정해지는 전역 변수에만 쓸 수 있지만, LEA는 `[ebp-30]`, `[esi+ebx*4]` 같은 간접 피연산자의 주소를 **실행 시점(runtime)** 에 계산할 수 있습니다. 그래서 스택에 있는 지역 변수나 스택 파라미터의 주소를 구할 때 LEA를 사용합니다.
```assembly
lea esi,[ebp-30]          ; OK : 지역 배열의 주소
mov esi,OFFSET [ebp-30]   ; error : 어셈블 시점에 알 수 없는 주소

```




5. 8.2.3절의 C++ 예제에서 int 타입 변수는 스택 공간을 얼마나 사용하나요?
* In the C++ example shown in Section 8.2.3, how much stack space is used by a variable of type int?
* Answer: 4바이트 (32비트 모드에서 int는 doubleword이며, 스택 파라미터는 4바이트 단위로 push됩니다.)




6. C 호출 규약은 STDCALL 호출 규약에 비해 어떤 장점이 있을까요?
* What advantages might the C calling convention have over the STDCALL calling convention?
* Answer: C 호출 규약은 **호출자(caller)** 가 스택을 정리하므로, 호출할 때마다 인자 개수가 달라지는 **가변 인자(variable-length) 파라미터 목록**을 가진 함수(예: `printf`)를 만들 수 있습니다. STDCALL은 피호출자가 `ret n` 으로 고정된 바이트 수만 정리하므로 가변 인자를 지원할 수 없습니다.




7. (참/거짓): PROC 지시어를 사용할 때 모든 파라미터는 같은 줄에 나열해야 한다.
* (True/False): When using the PROC directive, all parameters must be listed on the same line.
* Answer: False (쉼표로 구분하면 파라미터를 여러 줄에 나눠 쓸 수 있습니다.)
```assembly
AddTwo PROC,
    val1:DWORD,
    val2:DWORD

```




8. (참/거짓): 바이트 배열의 오프셋을 담은 변수를 word 배열 포인터를 기대하는 프로시저에 전달하면, 어셈블러가 이를 오류로 표시한다.
* (True/False): If you pass a variable containing the offset of an array of bytes to a procedure that expects a pointer to an array of words, the assembler will flag this as an error.
* Answer: False (어셈블러는 포인터가 가리키는 대상의 타입까지 검사하지 않습니다. 8.4.7절 Debugging Tips의 "Passing the Wrong Type of Pointer"처럼 오류 없이 어셈블되고, 실행 시 잘못된 결과가 나옵니다.)




9. (참/거짓): 참조 파라미터를 기대하는 프로시저에 즉시값(immediate value)을 전달하면 일반 보호 오류(general-protection fault)가 발생할 수 있다.
* (True/False): If you pass an immediate value to a procedure that expects a reference parameter, you can generate a general-protection fault.
* Answer: True (프로시저가 즉시값을 주소로 보고 역참조하기 때문입니다. 예: `INVOKE Sub2, 1000h` → 메모리 1000h 위치에 접근하여 runtime error 발생)
