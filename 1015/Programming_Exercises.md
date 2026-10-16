# Review Question and Exercises

## Programming Exercises

### Suggestions for Testing Your Code

* We have a few suggestions on how you can test the code you write for the programming exercises in this chapter, and in future chapters.
* **해석:** 이 장과 이후 장의 프로그래밍 연습 문제에서 작성한 코드를 테스트하는 방법에 대한 몇 가지 제안입니다.
  * 처음 테스트할 때는 항상 디버거로 한 단계씩 실행하세요. 작은 부분을 놓치기 쉬운데, 디버거를 쓰면 무슨 일이 일어나는지 정확히 볼 수 있습니다.
  * 명세에서 부호 있는 배열을 요구한다면 음수 값도 반드시 포함하세요.
  * 입력값의 범위가 주어지면 경계값의 앞, 경계값 자체, 경계값의 뒤에 해당하는 테스트 데이터를 포함하세요.
  * 길이가 다른 배열들로 여러 테스트 케이스를 만드세요.
  * 배열에 값을 쓰는 프로그램이라면 Visual Studio 디버거의 Memory 창으로 배열을 16진수나 10진수로 확인하는 것이 가장 좋습니다.
  * 테스트할 프로시저를 호출한 직후 한 번 더 호출하여 프로시저가 모든 레지스터를 보존하는지 확인하세요. 반환값이 들어가는 EAX는 보존할 수 없으므로, 보통 EAX를 입력 매개변수로 쓰지 않는 것이 좋습니다.
  * 프로시저에 여러 배열을 전달할 계획이라면 프로시저 안에서 배열 이름을 직접 쓰지 말고, 호출 전에 ESI나 EDI에 배열의 오프셋을 넣고 프로시저 안에서는 `[esi]`, `[edi]` 같은 간접 주소 지정 방식을 사용하세요.
  * 프로시저 안에서만 쓰는 변수는 프로시저 안에 `.data`로 선언한 뒤 `.code`로 돌아오면 됩니다. 이 변수는 여전히 전역으로 보이지만 다른 곳에서 쓰지 않겠다는 의도가 드러납니다. 프로시저를 여러 번 호출하므로 이런 변수는 반드시 실행 시간 명령어로 초기화해야 합니다.
```assembly
mov  esi,OFFSET array
mov  ecx,count
call CalcSum          ; returns sum in EAX
call CalcSum          ; call second time to see if registers are preserved

MyCoolProcedure PROC
.data
sum SDWORD ?
.code
    mov sum,0
    (etc.)

```




1. 배열 채우기 (Filling an Array)
* Create a procedure that fills an array of doublewords with N random integers, making sure the values fall within the range j...k, inclusive. When calling the procedure, pass a pointer to the array that will hold the data, pass N, and pass the values of j and k. Preserve all register values between calls to the procedure. Write a test program that calls the procedure twice, using different values for j and k. Verify your results using a debugger.
* **해석:** doubleword 배열을 N개의 난수로 채우되, 값이 j...k 범위(양 끝 포함)에 들어가도록 하는 프로시저를 만드세요. 프로시저를 호출할 때 데이터를 저장할 배열의 포인터, N, j와 k 값을 전달하세요. 프로시저 호출 전후로 모든 레지스터 값을 보존하세요. j와 k를 다르게 하여 프로시저를 두 번 호출하는 테스트 프로그램을 작성하고, 디버거로 결과를 확인하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

N = 20

.data
array1 DWORD N DUP(?)
array2 DWORD N DUP(?)

.code
main PROC
    call Randomize                     ; 난수 시드 초기화

    mov esi, OFFSET array1             ; ESI = 배열 주소
    mov ecx, N                         ; ECX = 개수
    mov ebx, 10                        ; EBX = j
    mov edx, 20                        ; EDX = k
    call FillArray                     ; array1 = 10 ~ 20 사이의 난수

    mov esi, OFFSET array2
    mov ecx, N
    mov ebx, -50                       ; j = -50
    mov edx, 50                        ; k = 50
    call FillArray                     ; array2 = -50 ~ 50 사이의 난수

    exit
main ENDP

;-----------------------------------------------------
; FillArray
;
; Fills an array with N random integers in the range j...k.
; Receives: ESI = pointer to an array of doublewords
;           ECX = N (number of values)
;           EBX = j (lower bound), EDX = k (upper bound)
; Returns:  nothing
;-----------------------------------------------------
FillArray PROC USES eax ecx esi
L1:
    mov eax, edx                       ; EAX = k
    sub eax, ebx                       ; EAX = k - j
    inc eax                            ; EAX = k - j + 1 (범위의 크기)
    call RandomRange                   ; EAX = 0 ~ (k - j)
    add eax, ebx                       ; EAX = j ~ k
    mov [esi], eax                     ; 배열에 저장
    add esi, TYPE DWORD                ; 다음 요소로 이동
    loop L1
    ret
FillArray ENDP
END main

```




2. 범위 안의 배열 요소 합계 (Summing Array Elements in a Range)
* Create a procedure that returns the sum of all array elements falling within the range j...k (inclusive). Write a test program that calls the procedure twice, passing a pointer to a signed doubleword array, the size of the array, and the values of j and k. Return the sum in the EAX register, and preserve all other register values between calls to the procedure.
* **해석:** j...k 범위(양 끝 포함)에 들어가는 모든 배열 요소의 합을 반환하는 프로시저를 만드세요. 부호 있는 doubleword 배열의 포인터, 배열의 크기, j와 k 값을 전달하여 프로시저를 두 번 호출하는 테스트 프로그램을 작성하세요. 합계는 EAX 레지스터로 반환하고, 나머지 레지스터 값은 모두 보존하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
array SDWORD 10, -20, 30, 5, -3, 45, 17, 0, -8, 22

.code
main PROC
    mov esi, OFFSET array              ; ESI = 배열 주소
    mov ecx, LENGTHOF array            ; ECX = 배열 크기
    mov ebx, 0                         ; j = 0
    mov edx, 20                        ; k = 20
    call SumInRange                    ; 10 + 5 + 17 + 0 = 32
    call WriteInt
    call Crlf

    mov ebx, -10                       ; j = -10
    mov edx, 10                        ; k = 10
    call SumInRange                    ; 10 + 5 + (-3) + 0 + (-8) = 4
    call WriteInt
    call Crlf

    exit
main ENDP

;-----------------------------------------------------
; SumInRange
;
; Returns the sum of all array elements in the range j...k.
; Receives: ESI = pointer to a signed doubleword array
;           ECX = number of elements
;           EBX = j (lower bound), EDX = k (upper bound)
; Returns:  EAX = sum
;-----------------------------------------------------
SumInRange PROC USES ecx esi
    mov eax, 0                         ; 합계 = 0
    jecxz quit                         ; 배열이 비어 있으면 종료

L1:
    cmp SDWORD PTR [esi], ebx          ; 요소 < j 이면 건너뜀
    jl  next
    cmp SDWORD PTR [esi], edx          ; 요소 > k 이면 건너뜀
    jg  next
    add eax, [esi]                     ; 범위 안: 합계에 더함
next:
    add esi, TYPE SDWORD               ; 다음 요소로 이동
    loop L1

quit:
    ret
SumInRange ENDP
END main

```




3. 시험 점수 평가 (Test Score Evaluation)
* Create a procedure named CalcGrade that receives an integer value between 0 and 100, and returns a single capital letter in the AL register. Preserve all other register values between calls to the procedure. The letter returned by the procedure should be according to the following ranges:

| Score Range | Letter Grade |
| --- | --- |
| 90 to 100 | A |
| 80 to 89 | B |
| 70 to 79 | C |
| 60 to 69 | D |
| 0 to 59 | F |

* Write a test program that generates 10 random integers between 50 and 100, inclusive. Each time an integer is generated, pass it to the CalcGrade procedure. You can test your program using a debugger, or if you prefer to use the book's library, you can display each integer and its corresponding letter grade.
* **해석:** 0부터 100 사이의 정수를 받아 대문자 하나를 AL 레지스터로 반환하는 CalcGrade 프로시저를 만드세요. 나머지 레지스터 값은 모두 보존하세요. 반환하는 문자는 위 표의 범위를 따릅니다. 50부터 100 사이(양 끝 포함)의 난수 10개를 생성하고, 생성할 때마다 CalcGrade에 전달하는 테스트 프로그램을 작성하세요. 디버거로 확인하거나, 책의 라이브러리를 사용해 각 정수와 학점을 출력해도 됩니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
separator BYTE " : ",0

.code
main PROC
    call Randomize                     ; 난수 시드 초기화
    mov ecx, 10                        ; 10번 반복

L1:
    mov eax, 51                        ; 0 ~ 50 사이의 난수
    call RandomRange
    add eax, 50                        ; 50 ~ 100 사이로 변환
    call WriteDec                      ; 점수 출력
    mov edx, OFFSET separator
    call WriteString
    call CalcGrade                     ; AL = 학점
    call WriteChar                     ; 학점 출력
    call Crlf
    loop L1

    exit
main ENDP

;-----------------------------------------------------
; CalcGrade
;
; Returns the letter grade for a test score.
; Receives: EAX = score (0 ~ 100)
; Returns:  AL = letter grade ('A', 'B', 'C', 'D', 'F')
;-----------------------------------------------------
CalcGrade PROC
    cmp eax, 90
    jb  L1
    mov al, 'A'                        ; 90 ~ 100
    ret
L1:
    cmp eax, 80
    jb  L2
    mov al, 'B'                        ; 80 ~ 89
    ret
L2:
    cmp eax, 70
    jb  L3
    mov al, 'C'                        ; 70 ~ 79
    ret
L3:
    cmp eax, 60
    jb  L4
    mov al, 'D'                        ; 60 ~ 69
    ret
L4:
    mov al, 'F'                        ; 0 ~ 59
    ret
CalcGrade ENDP
END main

```




4. 수강 신청 (College Registration)
* Using the College Registration example from Section 6.7.3 as a starting point, do the following:
  * Recode the logic using CMP and conditional jump instructions (instead of the .IF and .ELSEIF directives).
  * Perform range checking on the credits value; it cannot be less than 1 or greater than 30. If an invalid entry is discovered, display an appropriate error message.
  * Prompt the user for the grade average and credits values.
  * Display a message that shows the outcome of the evaluation, such as "The student can register" or "The student cannot register".
* **해석:** 6.7.3절의 수강 신청 예제를 출발점으로 다음을 수행하세요.
  * .IF와 .ELSEIF 지시어 대신 CMP와 조건 점프 명령어로 로직을 다시 작성하세요.
  * credits 값의 범위를 검사하세요. 1보다 작거나 30보다 클 수 없습니다. 잘못된 값이 입력되면 적절한 오류 메시지를 출력하세요.
  * 사용자에게 평균 학점(grade average)과 신청 학점(credits)을 입력받으세요.
  * "The student can register" 또는 "The student cannot register"처럼 평가 결과를 보여주는 메시지를 출력하세요.
* 참고: 6.7.3절의 원본 예제
```assembly
.data
TRUE = 1
FALSE = 0
gradeAverage  WORD 275              ; test value
credits       WORD 12               ; test value
OkToRegister  BYTE ?
.code
    mov OkToRegister,FALSE
    .IF gradeAverage > 350
        mov OkToRegister,TRUE
    .ELSEIF (gradeAverage > 250) && (credits <= 16)
        mov OkToRegister,TRUE
    .ELSEIF (credits <= 12)
        mov OkToRegister,TRUE
    .ENDIF

```
* Answer:
```assembly
INCLUDE Irvine32.inc

TRUE  = 1
FALSE = 0

.data
gradeAverage DWORD ?
credits      DWORD ?
OkToRegister BYTE  ?
promptGrade  BYTE "Enter the grade average (0-400): ",0
promptCredit BYTE "Enter the number of credits (1-30): ",0
msgError     BYTE "Error: credits must be between 1 and 30.",0
msgCan       BYTE "The student can register.",0
msgCannot    BYTE "The student cannot register.",0

.code
main PROC
    ; 평균 학점과 신청 학점 입력
    mov  edx, OFFSET promptGrade
    call WriteString
    call ReadInt
    mov  gradeAverage, eax

    mov  edx, OFFSET promptCredit
    call WriteString
    call ReadInt
    mov  credits, eax

    ; credits 범위 검사 (1 ~ 30)
    cmp  credits, 1
    jl   invalid
    cmp  credits, 30
    jg   invalid

    ; 등록 가능 여부 판단
    mov  OkToRegister, FALSE
    cmp  gradeAverage, 350             ; IF gradeAverage > 350
    jle  L1
    mov  OkToRegister, TRUE
    jmp  L3
L1:
    cmp  gradeAverage, 250             ; ELSEIF (gradeAverage > 250)
    jle  L2
    cmp  credits, 16                   ;        && (credits <= 16)
    jg   L2
    mov  OkToRegister, TRUE
    jmp  L3
L2:
    cmp  credits, 12                   ; ELSEIF (credits <= 12)
    jg   L3
    mov  OkToRegister, TRUE
L3:
    ; 결과 출력
    cmp  OkToRegister, TRUE
    jne  cannot
    mov  edx, OFFSET msgCan
    jmp  display
cannot:
    mov  edx, OFFSET msgCannot
    jmp  display
invalid:
    mov  edx, OFFSET msgError
display:
    call WriteString
    call Crlf
    exit
main ENDP
END main

```


* **설명:** ReadInt는 음수도 입력받을 수 있으므로, 원본의 부호 없는 점프(`jbe`, `ja`) 대신 부호 있는 점프(`jle`, `jg`)를 사용했습니다.




5. 불리언 계산기 (1) (Boolean Calculator (1))
* Create a program that functions as a simple boolean calculator for 32-bit integers. It should display a menu that asks the user to make a selection from the following list:
```
1. x AND y
2. x OR y
3. NOT x
4. x XOR y
5. Exit program
```
* When the user makes a choice, call a procedure that displays the name of the operation about to be performed. You must implement this procedure using the Table-Driven Selection technique, shown in Section 6.5.4. (You will implement the operations in Exercise 6.)
* **해석:** 32비트 정수를 위한 간단한 불리언 계산기 프로그램을 만드세요. 위 목록에서 하나를 선택하도록 메뉴를 출력해야 합니다. 사용자가 선택하면 수행할 연산의 이름을 출력하는 프로시저를 호출하세요. 이 프로시저는 6.5.4절의 테이블 기반 선택(Table-Driven Selection) 기법으로 구현해야 합니다. (실제 연산은 6번 문제에서 구현합니다.)
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
CaseTable BYTE  '1'                    ; 조회 값
          DWORD AND_op                 ; 프로시저 주소
EntrySize = ($ - CaseTable)
          BYTE  '2'
          DWORD OR_op
          BYTE  '3'
          DWORD NOT_op
          BYTE  '4'
          DWORD XOR_op
          BYTE  '5'
          DWORD ExitProgram
NumberOfEntries = ($ - CaseTable) / EntrySize

menu BYTE "---- Boolean Calculator ----",0Dh,0Ah
     BYTE "1. x AND y",0Dh,0Ah
     BYTE "2. x OR y",0Dh,0Ah
     BYTE "3. NOT x",0Dh,0Ah
     BYTE "4. x XOR y",0Dh,0Ah
     BYTE "5. Exit program",0Dh,0Ah
     BYTE "Enter your choice: ",0
msgAND     BYTE "x AND y",0
msgOR      BYTE "x OR y",0
msgNOT     BYTE "NOT x",0
msgXOR     BYTE "x XOR y",0
msgExit    BYTE "Exit program",0
msgInvalid BYTE "Invalid choice. Try again.",0

.code
main PROC
L1:
    mov  edx, OFFSET menu              ; 메뉴 출력
    call WriteString
    call ReadChar                      ; AL = 선택한 문자
    call WriteChar                     ; 입력한 문자 표시
    call Crlf
    call ChooseProcedure               ; 테이블에서 프로시저 찾아 호출
    call Crlf
    jmp  L1                            ; 메뉴 반복 (5를 고르면 종료)
main ENDP

;-----------------------------------------------------
; ChooseProcedure
;
; Searches the CaseTable for the user's choice and calls
; the matching procedure (table-driven selection).
; Receives: AL = user's choice ('1' ~ '5')
; Returns:  nothing
;-----------------------------------------------------
ChooseProcedure PROC USES ebx ecx edx
    mov  ebx, OFFSET CaseTable         ; EBX가 테이블을 가리킴
    mov  ecx, NumberOfEntries          ; 루프 카운터
L1:
    cmp  al, [ebx]                     ; 일치하는가?
    jne  L2                            ; no: 다음 항목
    call NEAR PTR [ebx + 1]            ; yes: 프로시저 호출
    jmp  L3
L2:
    add  ebx, EntrySize                ; 다음 항목을 가리킴
    loop L1

    mov  edx, OFFSET msgInvalid        ; 일치하는 항목 없음
    call WriteString
    call Crlf
L3:
    ret
ChooseProcedure ENDP

;-----------------------------------------------------
; AND_op, OR_op, NOT_op, XOR_op
;
; Display the name of the operation to be performed.
; Receives: nothing
; Returns:  nothing
;-----------------------------------------------------
AND_op PROC
    mov  edx, OFFSET msgAND
    call WriteString
    call Crlf
    ret
AND_op ENDP

OR_op PROC
    mov  edx, OFFSET msgOR
    call WriteString
    call Crlf
    ret
OR_op ENDP

NOT_op PROC
    mov  edx, OFFSET msgNOT
    call WriteString
    call Crlf
    ret
NOT_op ENDP

XOR_op PROC
    mov  edx, OFFSET msgXOR
    call WriteString
    call Crlf
    ret
XOR_op ENDP

;-----------------------------------------------------
; ExitProgram
;
; Displays the exit message and ends the program.
;-----------------------------------------------------
ExitProgram PROC
    mov  edx, OFFSET msgExit
    call WriteString
    call Crlf
    exit
ExitProgram ENDP
END main

```




6. 불리언 계산기 (2) (Boolean Calculator (2))
* Continue the solution program from Exercise 5 by implementing the following procedures:
  * AND_op: Prompt the user for two hexadecimal integers. AND them together and display the result in hexadecimal.
  * OR_op: Prompt the user for two hexadecimal integers. OR them together and display the result in hexadecimal.
  * NOT_op: Prompt the user for a hexadecimal integer. NOT the integer and display the result in hexadecimal.
  * XOR_op: Prompt the user for two hexadecimal integers. Exclusive-OR them together and display the result in hexadecimal.
* **해석:** 5번 문제의 풀이 프로그램에 이어서 다음 프로시저들을 구현하세요.
  * AND_op: 사용자에게 16진수 정수 두 개를 입력받아 AND한 결과를 16진수로 출력합니다.
  * OR_op: 사용자에게 16진수 정수 두 개를 입력받아 OR한 결과를 16진수로 출력합니다.
  * NOT_op: 사용자에게 16진수 정수 하나를 입력받아 NOT한 결과를 16진수로 출력합니다.
  * XOR_op: 사용자에게 16진수 정수 두 개를 입력받아 XOR한 결과를 16진수로 출력합니다.
* Answer: 5번 프로그램의 `main`, `ChooseProcedure`, `ExitProgram`, 데이터 정의는 그대로 두고, 아래 데이터와 프로시저를 추가/교체합니다.
```assembly
.data
promptX   BYTE "Enter x (hexadecimal): ",0
promptY   BYTE "Enter y (hexadecimal): ",0
msgResult BYTE "Result: ",0

.code
;-----------------------------------------------------
; AND_op
;
; Inputs two hexadecimal integers, ANDs them together,
; and displays the result in hexadecimal.
; Receives: nothing
; Returns:  nothing
;-----------------------------------------------------
AND_op PROC USES eax ebx edx
    mov  edx, OFFSET msgAND            ; 연산 이름 출력
    call WriteString
    call Crlf
    call ReadTwoHex                    ; EBX = x, EAX = y
    and  eax, ebx                      ; x AND y
    call ShowResult
    ret
AND_op ENDP

;-----------------------------------------------------
; OR_op
;
; Inputs two hexadecimal integers, ORs them together,
; and displays the result in hexadecimal.
;-----------------------------------------------------
OR_op PROC USES eax ebx edx
    mov  edx, OFFSET msgOR
    call WriteString
    call Crlf
    call ReadTwoHex                    ; EBX = x, EAX = y
    or   eax, ebx                      ; x OR y
    call ShowResult
    ret
OR_op ENDP

;-----------------------------------------------------
; NOT_op
;
; Inputs a hexadecimal integer, NOTs it, and displays
; the result in hexadecimal.
;-----------------------------------------------------
NOT_op PROC USES eax edx
    mov  edx, OFFSET msgNOT
    call WriteString
    call Crlf
    mov  edx, OFFSET promptX
    call WriteString
    call ReadHex                       ; EAX = x
    not  eax                           ; NOT x
    call ShowResult
    ret
NOT_op ENDP

;-----------------------------------------------------
; XOR_op
;
; Inputs two hexadecimal integers, XORs them together,
; and displays the result in hexadecimal.
;-----------------------------------------------------
XOR_op PROC USES eax ebx edx
    mov  edx, OFFSET msgXOR
    call WriteString
    call Crlf
    call ReadTwoHex                    ; EBX = x, EAX = y
    xor  eax, ebx                      ; x XOR y
    call ShowResult
    ret
XOR_op ENDP

;-----------------------------------------------------
; ReadTwoHex
;
; Prompts the user for two hexadecimal integers.
; Receives: nothing
; Returns:  EBX = x, EAX = y
;-----------------------------------------------------
ReadTwoHex PROC USES edx
    mov  edx, OFFSET promptX
    call WriteString
    call ReadHex
    mov  ebx, eax                      ; EBX = x
    mov  edx, OFFSET promptY
    call WriteString
    call ReadHex                       ; EAX = y
    ret
ReadTwoHex ENDP

;-----------------------------------------------------
; ShowResult
;
; Displays "Result: " followed by EAX in hexadecimal.
; Receives: EAX = result
; Returns:  nothing
;-----------------------------------------------------
ShowResult PROC USES edx
    mov  edx, OFFSET msgResult
    call WriteString
    call WriteHex
    call Crlf
    ret
ShowResult ENDP

```


* **설명:** 각 연산 프로시저는 USES로 사용하는 레지스터를 보존하므로, `ChooseProcedure`에서 전달한 AL 등 호출자의 레지스터가 바뀌지 않습니다.




7. 확률과 색상 (Probabilities and Colors)
* Write a program that randomly chooses among three different colors for displaying text on the screen. Use a loop to display 20 lines of text, each with a randomly chosen color. The probabilities for each color are to be as follows: white = 30%, blue = 10%, green = 60%. Suggestion: Generate a random integer between 0 and 9. If the resulting integer falls in the range 0 to 2 (inclusive), choose white. If the integer equals 3, choose blue. If the integer falls in the range 4 to 9 (inclusive), choose green. Test your program by running it ten times, each time observing whether the distribution of line colors appears to match the required probabilities.
* **해석:** 화면에 텍스트를 출력할 색상을 세 가지 중에서 무작위로 고르는 프로그램을 작성하세요. 루프를 사용하여 20줄의 텍스트를 출력하고, 각 줄은 무작위로 고른 색상으로 출력합니다. 각 색상의 확률은 white = 30%, blue = 10%, green = 60%입니다. 제안: 0부터 9 사이의 난수를 생성하여 0~2이면 white, 3이면 blue, 4~9이면 green을 고르세요. 프로그램을 10번 실행하면서 줄 색상의 분포가 요구된 확률과 맞는지 관찰하여 테스트하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
message BYTE "Probabilities and Colors",0

.code
main PROC
    call Randomize                     ; 난수 시드 초기화
    mov ecx, 20                        ; 20줄 출력

L1:
    call ChooseColor                   ; EAX = 무작위 색상
    call SetTextColor
    mov edx, OFFSET message
    call WriteString
    call Crlf
    loop L1

    mov eax, lightGray + (black * 16)  ; 기본 색상으로 복원
    call SetTextColor
    exit
main ENDP

;-----------------------------------------------------
; ChooseColor
;
; Chooses a text color: white 30%, blue 10%, green 60%.
; Receives: nothing
; Returns:  EAX = color
;-----------------------------------------------------
ChooseColor PROC
    mov eax, 10
    call RandomRange                   ; EAX = 0 ~ 9
    cmp eax, 2
    ja  L1
    mov eax, white                     ; 0 ~ 2 (30%)
    ret
L1:
    cmp eax, 3
    ja  L2
    mov eax, blue                      ; 3 (10%)
    ret
L2:
    mov eax, green                     ; 4 ~ 9 (60%)
    ret
ChooseColor ENDP
END main

```




8. 메시지 암호화 (Message Encryption)
* Revise the encryption program in Section 6.3.4 in the following manner: Create an encryption key consisting of multiple characters. Use this key to encrypt and decrypt the plaintext by XORing each character of the key against a corresponding byte in the message. Repeat the key as many times as necessary until all plain text bytes are translated. Suppose, for example, the key were equal to "ABXmv#7". This is how the key would align with the plain text bytes:
```
Plain text  T h i s   i s   a   P l a i n t e x t   m e s s a g e   (etc.)
Key         A B X m v # 7 A B X m v # 7 A B X m v # 7 A B X m v # 7 A
(The key repeats until it equals the length of the plain text...)
```
* **해석:** 6.3.4절의 암호화 프로그램을 다음과 같이 수정하세요. 여러 문자로 이루어진 암호화 키를 만드세요. 키의 각 문자를 메시지의 대응하는 바이트와 XOR하여 평문을 암호화하고 복호화합니다. 모든 평문 바이트가 변환될 때까지 필요한 만큼 키를 반복하세요. 예를 들어 키가 "ABXmv#7"이라면 위와 같이 평문 바이트와 정렬됩니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

BUFMAX = 128                           ; 최대 버퍼 크기

.data
key      BYTE "ABXmv#7"                ; 여러 문자로 된 키
KEY_LEN  = ($ - key)                   ; 키 길이 = 7
sPrompt  BYTE "Enter the plain text: ",0
sEncrypt BYTE "Cipher text:          ",0
sDecrypt BYTE "Decrypted:            ",0
buffer   BYTE BUFMAX+1 DUP(0)
bufSize  DWORD ?

.code
main PROC
    call InputTheString                ; 평문 입력
    call TranslateBuffer               ; 버퍼 암호화
    mov  edx, OFFSET sEncrypt          ; 암호문 출력
    call DisplayMessage
    call TranslateBuffer               ; 버퍼 복호화
    mov  edx, OFFSET sDecrypt          ; 복호화된 메시지 출력
    call DisplayMessage
    exit
main ENDP

;-----------------------------------------------------
; InputTheString
;
; Prompts user for a plaintext string. Saves the string
; and its length.
; Receives: nothing
; Returns:  nothing
;-----------------------------------------------------
InputTheString PROC
    pushad
    mov  edx, OFFSET sPrompt
    call WriteString
    mov  ecx, BUFMAX                   ; 최대 문자 수
    mov  edx, OFFSET buffer
    call ReadString
    mov  bufSize, eax                  ; 길이 저장
    call Crlf
    popad
    ret
InputTheString ENDP

;-----------------------------------------------------
; DisplayMessage
;
; Displays the encrypted or decrypted message.
; Receives: EDX points to the message
; Returns:  nothing
;-----------------------------------------------------
DisplayMessage PROC
    pushad
    call WriteString
    mov  edx, OFFSET buffer
    call WriteString
    call Crlf
    call Crlf
    popad
    ret
DisplayMessage ENDP

;-----------------------------------------------------
; TranslateBuffer
;
; Translates the string by exclusive-ORing each byte
; with the corresponding byte of the multi-character key.
; The key repeats until all bytes are translated.
; Receives: nothing
; Returns:  nothing
;-----------------------------------------------------
TranslateBuffer PROC
    pushad
    mov  ecx, bufSize                  ; 루프 카운터
    jecxz done                         ; 빈 문자열이면 종료
    mov  esi, 0                        ; 버퍼 인덱스
    mov  edi, 0                        ; 키 인덱스

L1:
    mov  al, key[edi]                  ; 현재 키 문자
    xor  buffer[esi], al               ; 바이트 하나 변환
    inc  esi                           ; 다음 바이트
    inc  edi                           ; 다음 키 문자
    cmp  edi, KEY_LEN                  ; 키 끝에 도달했는가?
    jb   L2
    mov  edi, 0                        ; 키를 처음부터 반복
L2:
    loop L1

done:
    popad
    ret
TranslateBuffer ENDP
END main

```


* **설명:** 평문 문자와 키 문자가 같으면 XOR 결과가 0이 되어, 암호문을 WriteString으로 출력할 때 그 위치에서 문자열이 끊겨 보일 수 있습니다. 버퍼 내용 자체는 정상이므로 복호화 결과는 올바르게 출력됩니다.




9. PIN 검증 (Validating a PIN)
* Banks use a Personal Identification Number (PIN) to uniquely identify each customer. Let us assume that our bank has a specified range of acceptable values for each digit in its customers' 5-digit PINs. The table shown below contains the acceptable ranges, where digits are numbered from left to right in the PIN. Then we can see that the PIN 52413 is valid. But the PIN 43534 is invalid because the first digit is out of range. Similarly, 64535 is invalid because of its last digit.

| Digit Number | Range |
| --- | --- |
| 1 | 5 to 9 |
| 2 | 2 to 5 |
| 3 | 4 to 8 |
| 4 | 1 to 4 |
| 5 | 3 to 6 |

* Your task is to create a procedure named Validate_PIN that receives a pointer to an array of byte containing a 5-digit PIN. Declare two arrays to hold the minimum and maximum range values, and use these arrays to validate each digit of the PIN that was passed to the procedure. If any digit is found to be outside its valid range, immediately return the digit's position (between 1 and 5) in the EAX register. If the entire PIN is valid, return 0 in EAX. Preserve all other register values between calls to the procedure. Write a test program that calls Validate_PIN at least four times, using both valid and invalid byte arrays. By running the program in a debugger, verify that the return value in EAX after each procedure call is valid. Or, if you prefer to use the book's library, you can display "Valid" or "Invalid" on the console after each procedure call.
* **해석:** 은행은 각 고객을 고유하게 식별하기 위해 PIN(개인 식별 번호)을 사용합니다. 우리 은행은 고객의 5자리 PIN의 각 자릿수마다 허용 범위가 정해져 있다고 가정합니다. 위 표는 PIN의 왼쪽부터 번호를 매긴 각 자릿수의 허용 범위입니다. 따라서 PIN 52413은 유효합니다. 하지만 43534는 첫 번째 자릿수가 범위를 벗어나므로 유효하지 않고, 64535는 마지막 자릿수 때문에 유효하지 않습니다.
  * 5자리 PIN이 담긴 바이트 배열의 포인터를 받는 Validate_PIN 프로시저를 만드세요. 최솟값과 최댓값을 담는 두 배열을 선언하고, 이 배열들로 전달받은 PIN의 각 자릿수를 검증하세요. 범위를 벗어난 자릿수를 발견하면 즉시 그 위치(1~5)를 EAX로 반환하고, PIN 전체가 유효하면 EAX에 0을 반환하세요. 나머지 레지스터 값은 모두 보존하세요.
  * 유효한 배열과 유효하지 않은 배열을 사용하여 Validate_PIN을 최소 4번 호출하는 테스트 프로그램을 작성하세요. 디버거로 각 호출 후 EAX의 반환값을 확인하거나, 책의 라이브러리로 호출할 때마다 "Valid" 또는 "Invalid"를 출력해도 됩니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

PIN_LENGTH = 5

.data
minDigit BYTE 5, 2, 4, 1, 3            ; 각 자릿수의 최솟값
maxDigit BYTE 9, 5, 8, 4, 6            ; 각 자릿수의 최댓값

pin1 BYTE 5, 2, 4, 1, 3                ; 유효       → EAX = 0
pin2 BYTE 4, 3, 5, 3, 4                ; 1번째 무효 → EAX = 1
pin3 BYTE 6, 4, 5, 3, 5                ; 5번째 무효 → EAX = 5
pin4 BYTE 5, 9, 2, 1, 3                ; 2번째 무효 → EAX = 2
pin5 BYTE 7, 5, 8, 4, 6                ; 유효       → EAX = 0

msgValid   BYTE "Valid",0
msgInvalid BYTE "Invalid (digit ",0
msgClose   BYTE ")",0

.code
main PROC
    mov esi, OFFSET pin1
    call TestPIN
    mov esi, OFFSET pin2
    call TestPIN
    mov esi, OFFSET pin3
    call TestPIN
    mov esi, OFFSET pin4
    call TestPIN
    mov esi, OFFSET pin5
    call TestPIN
    exit
main ENDP

;-----------------------------------------------------
; TestPIN
;
; Calls Validate_PIN and displays "Valid" or "Invalid".
; Receives: ESI = pointer to a 5-digit PIN
; Returns:  nothing
;-----------------------------------------------------
TestPIN PROC USES eax edx
    call Validate_PIN                  ; EAX = 0 또는 잘못된 자릿수 위치
    cmp  eax, 0
    jne  L1
    mov  edx, OFFSET msgValid
    call WriteString
    jmp  L2
L1:
    mov  edx, OFFSET msgInvalid
    call WriteString
    call WriteDec                      ; 잘못된 자릿수 위치 출력
    mov  edx, OFFSET msgClose
    call WriteString
L2:
    call Crlf
    ret
TestPIN ENDP

;-----------------------------------------------------
; Validate_PIN
;
; Validates each digit of a 5-digit PIN against the
; minDigit and maxDigit range arrays.
; Receives: ESI = pointer to an array of byte (the PIN)
; Returns:  EAX = 0 if valid, otherwise the position
;           (1 ~ 5) of the first invalid digit
;-----------------------------------------------------
Validate_PIN PROC USES ebx ecx
    mov ebx, 0                         ; 자릿수 인덱스
    mov ecx, PIN_LENGTH                ; 5자리 검사

L1:
    mov al, [esi + ebx]                ; 현재 자릿수
    cmp al, minDigit[ebx]
    jb  invalid                        ; 최솟값보다 작음
    cmp al, maxDigit[ebx]
    ja  invalid                        ; 최댓값보다 큼
    inc ebx
    loop L1

    mov eax, 0                         ; 모든 자릿수가 유효
    ret

invalid:
    mov eax, ebx                       ; 인덱스(0 ~ 4)를
    inc eax                            ; 위치(1 ~ 5)로 변환
    ret
Validate_PIN ENDP
END main

```




10. 패리티 검사 (Parity Checking)
* Data transmission systems and file subsystems often use a form of error detection that relies on calculating the parity (even or odd) of blocks of data. Your task is to create a procedure that returns True in the EAX register if the bytes in an array contain even parity, or False if the parity is odd. In other words, if you count all the bits in the entire array, their count will be even or odd. Preserve all other register values between calls to the procedure. Write a test program that calls your procedure twice, each time passing it a pointer to an array and the length of the array. The procedure's return value in EAX should be 1 (True) or 0 (False). For test data, create two arrays containing at least 10 bytes, one having even parity, and another having odd parity.
* Tip: Earlier in this chapter, we showed how you can repeatedly apply the XOR instruction to a sequence of byte values to determine their parity. So, this suggests the use of a loop. But be careful, since some machine instructions affect the Parity flag, and others do not. You can find this out by looking at the individual instructions in Appendix B. The code in your loop that checks the parity will have to carefully save and restore the state of the Parity flag to avoid having it unintentionally modified by your code.
* **해석:** 데이터 전송 시스템과 파일 서브시스템은 데이터 블록의 패리티(짝수 또는 홀수)를 계산하는 오류 검출 방식을 자주 사용합니다. 배열의 바이트들이 짝수 패리티이면 EAX에 True를, 홀수 패리티이면 False를 반환하는 프로시저를 만드세요. 즉, 배열 전체의 1인 비트 개수가 짝수인지 홀수인지를 판단합니다. 나머지 레지스터 값은 모두 보존하세요. 배열의 포인터와 길이를 전달하여 프로시저를 두 번 호출하는 테스트 프로그램을 작성하세요. 반환값은 1(True) 또는 0(False)이어야 합니다. 테스트 데이터로 최소 10바이트짜리 배열 두 개(짝수 패리티 하나, 홀수 패리티 하나)를 만드세요.
* **팁 해석:** 이 장 앞부분에서 바이트 값들에 XOR를 반복 적용하여 패리티를 구하는 방법을 보였으므로 루프를 사용하면 됩니다. 단, 어떤 명령어는 Parity 플래그에 영향을 주고 어떤 명령어는 주지 않으므로 주의하세요. 루프 안의 코드가 의도치 않게 Parity 플래그를 바꾸지 않도록 플래그 상태를 잘 저장하고 복원해야 합니다.
* Answer:
```assembly
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

TRUE  = 1
FALSE = 0

.data
evenArray BYTE 1,2,3,4,5,6,7,8,9,11    ; 1인 비트 18개 → 짝수 패리티
oddArray  BYTE 1,2,3,4,5,6,7,8,9,10    ; 1인 비트 17개 → 홀수 패리티

.code
main proc
    mov esi, OFFSET evenArray
    mov ecx, LENGTHOF evenArray
    call CheckParity                   ; EAX = 1 (True)

    mov esi, OFFSET oddArray
    mov ecx, LENGTHOF oddArray
    call CheckParity                   ; EAX = 0 (False)

    invoke ExitProcess, 0
main endp

;-----------------------------------------------------
; CheckParity
;
; Determines whether all bits in a byte array have
; even parity.
; Receives: ESI = pointer to a byte array
;           ECX = length of the array
; Returns:  EAX = TRUE (1) if even parity, FALSE (0) if odd
;-----------------------------------------------------
CheckParity proc USES ecx esi
    mov al, 0                          ; 누적 XOR 값

L1:
    xor al, [esi]                      ; 모든 바이트를 XOR로 누적
    inc esi
    loop L1

    test al, al                        ; 루프가 끝난 뒤 한 번만 PF 설정
    mov  eax, TRUE                     ; MOV는 플래그를 바꾸지 않음
    jp   done                          ; PF = 1 → 짝수 패리티
    mov  eax, FALSE                    ; PF = 0 → 홀수 패리티
done:
    ret
CheckParity endp
end main

```


* **설명:** 모든 바이트를 XOR한 결과의 1인 비트 개수는 배열 전체의 1인 비트 개수와 홀짝이 같습니다. 루프 안의 `inc`는 Parity 플래그를 바꾸므로, 루프 안에서 플래그를 저장하고 복원하는 대신 **AL에 XOR 결과를 누적하고 루프가 끝난 뒤 `test al,al`로 한 번만 PF를 검사**했습니다.
