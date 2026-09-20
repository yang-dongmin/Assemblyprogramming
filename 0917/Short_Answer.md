# Review Question and Exercises

## Short Answer

1. 세 가지 서로 다른 명령어 니모닉(mnemonic)의 예를 제시하세요.
* Provide examples of three different instruction mnemonics.
* Answer: MOV, ADD, SUB (이 외에도 JMP, INC, MUL 등)


2. 호출 규약(calling convention)이란 무엇이며, 어셈블리 언어 선언에서 어떻게 사용되나요?
* What is a calling convention, and how is it used in assembly language declarations?
* Answer: 호출 규약은 프로시저(함수) 호출 시 매개변수를 전달하는 순서(왼쪽에서 오른쪽 또는 오른쪽에서 왼쪽), 스택을 정리하는 주체(호출자 또는 피호출자), 그리고 레지스터 보존 규칙 등을 정의한 규약입니다. 어셈블리 언어에서는 `.model` 지시어나 `PROC` 선언부에 `C`, `STDCALL` 등을 지정하여 컴파일러 및 외부 언어와의 호환성을 설정하는 데 사용됩니다.


3. 프로그램에서 스택 공간은 어떻게 확보하나요?
* How do you reserve space for the stack in a program?
* Answer: `.stack` 지시어 뒤에 필요한 바이트 크기를 지정하여 확보합니다. (예: `.stack 4096`)


4. '어셈블러 언어(assembler language)'라는 용어가 아주 정확하지 않은 이유를 설명하세요.
* Explain why the term assembler language is not quite correct.
* Answer: '어셈블러(Assembler)'는 어셈블리 언어로 작성된 소스 코드를 기계어로 번역하는 프로그램(도구)을 의미합니다. 따라서 언어 자체를 가리킬 때는 '어셈블리 언어(Assembly language)'라고 부르는 것이 올바른 표현입니다.


5. 빅 엔디안(big endian)과 리틀 엔디안(little endian)의 차이점을 설명하세요. 또한, 이 용어의 기원을 설명하세요.
* Explain the difference between big endian and little endian. Also, look up the origins of this term on the Web.
* Answer:
* **차이점**: Multi-byte 데이터를 메모리에 저장할 때, 최상위 바이트(MSB)를 낮은 주소부터 저장하는 방식을 **빅 엔디안**, 최하위 바이트(LSB)를 낮은 주소부터 저장하는 방식을 **리틀 엔디안**이라고 합니다.
* **기원**: 조나단 스위프트의 소설 《걸리버 여행기》에서 계란을 깰 때 뾰족한 끝(little end)을 먼저 깨야 하는지, 뭉툭한 끝(big end)을 먼저 깨야 하는지를 두고 벌어진 파벌 싸움에서 유래했습니다. 1980년 대니 코헨(Danny Cohen)이 컴퓨터 네트워크 및 아키텍처의 바이트 순서 논쟁에 이 비유를 처음 적용했습니다.




6. 코드에서 정수 리터럴 대신 심볼릭 상수(symbolic constant)를 사용하는 이유는 무엇인가요?
* Why might you use a symbolic constant rather than an integer literal in your code?
* Answer: 코드의 가독성을 높이고 유지보수를 용이하게 만들기 위해서입니다. 상수의 값이 변경될 때 여러 곳의 정수 리터럴을 일일이 수정할 필요 없이 정의된 상수 값 하나만 변경하면 됩니다.


7. 소스 파일(source file)과 리스팅 파일(listing file)은 어떻게 다른가요?
* How is a source file different from a listing file?
* Answer: 소스 파일(`.asm`)은 프로그래머가 직접 작성한 텍스트 파일입니다. 반면, 리스팅 파일(`.lst`)은 어셈블러가 생성하는 파일로, 소스 코드와 함께 대응되는 메모리 주소, 변환된 기계어 헥사 코드, 심볼 테이블 등의 상세한 어셈블 정보가 포함되어 있습니다.


8. 데이터 레이블(data label)과 코드 레이블(code label)은 어떻게 다른가요?
* How are data labels and code labels different?
* Answer: 데이터 레이블은 변수의 위치(메모리 주소)를 참조하기 위해 사용되며 뒤에 콜론(`:`)을 붙이지 않습니다(예: `myVar DWORD 10`). 반면, 코드 레이블은 실행할 명령어의 위치(점프 target 등)를 나타내며 이름 뒤에 콜론(`:`)이 붙습니다(예: `target:`).


9. (참/거짓): 식별자(identifier)는 숫자로 시작할 수 없습니다.
* (True/False): An identifier cannot begin with a numeric digit.
* Answer: True


10. (참/거짓): 16진수 리터럴은 0x3A와 같이 쓸 수 있습니다.
* (True/False): A hexadecimal literal may be written as 0x3A.
* Answer: True (MASM 표준에서는 `3Ah` 형태를 주로 사용하지만, C 언어 스타일의 `0x3A` 표기법도 지원합니다.)


11. (참/거짓): 어셈블리 언어 지시어(directive)는 런타임(실행 시점)에 실행됩니다.
* (True/False): Assembly language directives execute at runtime.
* Answer: False (지시어는 어셈블러가 코드를 번역할 때 처리하며, 런타임에 실행되지 않습니다.)


12. (참/거짓): 어셈블리 언어 지시어는 대소문자를 자유롭게 조합하여 쓸 수 있습니다.
* (True/False): Assembly language directives can be written in any combination of uppercase and lowercase letters.
* Answer: True (어셈블러는 기본적으로 대소문자를 구분하지 않습니다.)


13. 어셈블리 언어 명령어의 기본 4가지 구성을 제시하세요.
* Name the four basic parts of an assembly language instruction.
* Answer: 레이블(Label), 니모닉/명령어(Mnemonic), 피연산자(Operand), 주석(Comment)


14. (참/거짓): MOV는 명령어 니모닉의 한 예입니다.
* (True/False): MOV is an example of an instruction mnemonic.
* Answer: True


15. (참/거짓): 코드 레이블 뒤에는 콜론(:)이 붙지만, 데이터 레이블 뒤에는 콜론이 붙지 않습니다.
* (True/False): A code label is followed by a colon (:), but a data label does not end with a colon.
* Answer: True


16. 블록 주석(block comment)의 예시를 보여주세요.
* Show an example of a block comment.
* Answer:
```assembly
COMMENT !
   이 부분은 여러 줄 주석입니다.
   어셈블러에 의해 무시됩니다.
!

```




17. 변수에 접근하는 명령어를 작성할 때 숫자 주소(numeric address)를 직접 사용하는 것이 좋지 않은 이유는 무엇인가요?
* Why is it not a good idea to use numeric addresses when writing instructions that access variables?
* Answer: 코드가 수정되어 데이터의 위치가 바뀌면 하드코딩된 숫자 주소가 무효화되어 오류가 발생하기 쉽고, 코드의 가독성과 재사용성이 크게 떨어지기 때문입니다.


18. ExitProcess 프로시저에는 어떤 유형의 인수를 전달해야 하나요?
* What type of argument must be passed to the ExitProcess procedure?
* Answer: 프로세스의 종료 상태를 나타내는 32비트 정수 반환 코드(Return Code, 보통 정상 종료 시 `0`)를 전달해야 합니다.


19. 프로시저를 종료하는 지시어는 무엇인가요?
* Which directive ends a procedure?
* Answer: `ENDP`


20. 32비트 모드에서 END 지시어 뒤에 오는 식별자의 목적은 무엇인가요?
* In 32-bit mode, what is the purpose of the identifier in the END directive?
* Answer: 프로그램의 진입점(Entry Point, 실행 시작 위치)을 어셈블러에게 알리는 역할을 합니다. (예: `END main`)


21. PROTO 지시어의 목적은 무엇인가요?
* What is the purpose of the PROTO directive?
* Answer: 호출할 프로시저의 프로토타입(함수 원형)을 선언하여, 매개변수의 개수와 타입을 검증할 수 있도록 설정합니다.


22. (참/거짓): 오브젝트 파일(Object file)은 링커(Linker)에 의해 생성됩니다.
* (True/False): An Object file is produced by the Linker.
* Answer: False (오브젝트 파일은 어셈블러에 의해 생성되며, 링커는 실행 파일(`.exe`)을 생성합니다.)


23. (참/거짓): 리스팅 파일(Listing file)은 어셈블러(Assembler)에 의해 생성됩니다.
* (True/False): A Listing file is produced by the Assembler.
* Answer: True


24. (참/거짓): 링크 라이브러리는 실행 파일(Executable file)이 생성되기 바로 직전에 프로그램에 추가됩니다.
* (True/False): A link library is added to a program just before producing an Executable file.
* Answer: True (링킹 과정에서 결합됩니다.)


25. 32비트 부호 있는 정수 변수를 생성하는 데이터 지시어는 무엇인가요?
* Which data directive creates a 32-bit signed integer variable?
* Answer: `SDWORD` (또는 `DWORD`)


26. 16비트 부호 있는 정수 변수를 생성하는 데이터 지시어는 무엇인가요?
* Which data directive creates a 16-bit signed integer variable?
* Answer: `SWORD` (또는 `WORD`)


27. 64비트 부호 없는 정수 변수를 생성하는 데이터 지시어는 무엇인가요?
* Which data directive creates a 64-bit unsigned integer variable?
* Answer: `QWORD`


28. 8비트 부호 있는 정수 변수를 생성하는 데이터 지시어는 무엇인가요?
* Which data directive creates an 8-bit signed integer variable?
* Answer: `SBYTE` (또는 `BYTE`)


29. 10바이트 팩 BCD(packed BCD) 변수를 생성하는 데이터 지시어는 무엇인가요?
* Which data directive creates a 10-byte packed BCD variable?
* Answer: `TBYTE`