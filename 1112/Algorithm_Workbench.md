# Review Question and Exercises

## Algorithm Workbench

1. 32비트 모드에서 베이스-인덱스 피연산자의 예를 보이세요.
* Show an example of a base-index operand in 32-bit mode.
* Answer:
```assembly
mov eax,[ebx+esi]       ; EBX = base, ESI = index

```




2. 32비트 모드에서 베이스-인덱스-변위 피연산자의 예를 보이세요.
* Show an example of a base-index-displacement operand in 32-bit mode.
* Answer:
```assembly
mov eax,tableD[ebx+esi*TYPE tableD]   ; tableD = displacement
mov eax,[ebx+esi+8]                   ; 8 = displacement

```




3. doubleword로 된 2차원 배열이 논리적으로 3행 4열이라고 가정합니다. ESI와 EDI를 사용하여 두 번째 행의 세 번째 열을 가리키는 식을 작성하세요. (행과 열 번호는 0부터 시작합니다.)
* Suppose a two-dimensional array of doublewords has three logical rows and four logical columns. Write an expression using ESI and EDI that addresses the third column in the second row. (Numbering for rows and columns starts at zero.)
* Answer:
```assembly
.data
table DWORD 3 * 4 DUP(?)            ; 3행 4열
RowSize = 4 * TYPE DWORD            ; 한 행 = 16바이트
.code
mov esi,RowSize * 1                 ; ESI = 행 오프셋 (row 1)
mov edi,2                           ; EDI = 열 인덱스 (column 2)
mov eax,table[esi + edi*TYPE table] ; table + 16 + 8 = table + 24

```


* **설명:** 번호가 0부터 시작하므로 "두 번째 행" = 1행, "세 번째 열" = 2열입니다. 행 오프셋은 `1 × 16 = 16` 바이트, 열 오프셋은 `2 × 4 = 8` 바이트이므로 배열 시작에서 24바이트 떨어진 원소입니다.




4. CMPSW를 사용하여 sourcew와 targetw라는 16비트 값 배열 두 개를 비교하는 명령어를 작성하세요.
* Write instructions using CMPSW that compare two arrays of 16-bit values named sourcew and targetw.
* Answer:
```assembly
.data
sourcew WORD 1000h,2000h,3000h,4000h
targetw WORD 1000h,2000h,3000h,4000h
.code
    mov  esi,OFFSET sourcew
    mov  edi,OFFSET targetw
    mov  ecx,LENGTHOF sourcew       ; 비교할 워드 개수
    cld                             ; direction = forward
    repe cmpsw                      ; 같은 동안 비교 반복
    jne  notEqual                   ; ZF = 0 이면 다른 값이 있음
    ; 두 배열이 같음
    ...
notEqual:
    ; 두 배열이 다름 (ESI, EDI는 다른 원소의 다음 위치)

```




5. SCASW를 사용하여 wordArray라는 배열에서 16비트 값 0100h를 찾고, 일치하는 원소의 오프셋을 EAX 레지스터에 복사하는 명령어를 작성하세요.
* Write instructions that use SCASW to scan for the 16-bit value 0100h in an array named wordArray, and copy the offset of the matching member into the EAX register.
* Answer:
```assembly
.data
wordArray WORD 0010h,0020h,0100h,0200h
.code
    mov    edi,OFFSET wordArray
    mov    ax,0100h                 ; 찾을 값
    mov    ecx,LENGTHOF wordArray
    cld
    repne  scasw                    ; 일치할 때까지 스캔
    jnz    notFound                 ; 못 찾음
    sub    edi,TYPE wordArray       ; 일치한 원소로 되돌림 (2바이트)
    mov    eax,edi                  ; EAX = 일치한 원소의 오프셋
    ...
notFound:

```


* **설명:** SCASW는 비교 후에도 EDI를 2 증가시키므로, 찾은 뒤 EDI에서 2를 빼야 일치한 원소의 주소가 됩니다. 위 데이터에서는 `EAX = OFFSET wordArray + 4` 입니다.




6. Str_compare 프로시저를 사용하여 두 입력 문자열 중 더 큰 것을 판별하고 콘솔 창에 출력하는 명령어를 작성하세요.
* Write a sequence of instructions that use the Str_compare procedure to determine the larger of two input strings and write it to the console window.
* Answer:
```assembly
.data
string1 BYTE "apple",0
string2 BYTE "banana",0
.code
    INVOKE Str_compare, ADDR string1, ADDR string2
    ja    first                     ; string1 > string2
    mov   edx,OFFSET string2        ; string1 <= string2 → string2 출력
    jmp   show
first:
    mov   edx,OFFSET string1
show:
    call  WriteString               ; 더 큰 문자열 출력 → banana
    call  Crlf

```


* **설명:** Str_compare는 CMP와 같은 방식으로 CF와 ZF를 설정하므로(Table 9-3), `JA` 는 string1 > string2일 때 점프합니다. 두 문자열이 같으면 어느 쪽을 출력해도 같습니다.




7. Str_trim 프로시저를 호출하여 문자열 끝의 모든 "@" 문자를 제거하는 방법을 보이세요.
* Show how to call the Str_trim procedure and remove all trailing "@" characters from a string.
* Answer:
```assembly
.data
myString BYTE "Hello@@@",0
.code
INVOKE Str_trim, ADDR myString, '@'     ; myString = "Hello"

```




8. Irvine32 라이브러리의 Str_ucase 프로시저를 수정하여 모든 문자를 소문자로 바꾸도록 만드는 방법을 보이세요.
* Show how to modify the Str_ucase procedure from the Irvine32 library so it changes all characters to lower case.
* Answer:
```assembly
;-----------------------------------------------------------
; Str_lcase
; Converts a null-terminated string to lowercase.
; Returns: nothing
;-----------------------------------------------------------
Str_lcase PROC USES eax esi,
    pString:PTR BYTE

    mov   esi,pString
L1:
    mov   al,[esi]                      ; get char
    cmp   al,0                          ; end of string?
    je    L3                            ; yes: quit
    cmp   al,'A'                        ; below "A"?
    jb    L2
    cmp   al,'Z'                        ; above "Z"?
    ja    L2
    or    BYTE PTR [esi],00100000b      ; 비트 5를 1로 → 소문자
L2: inc   esi                           ; next char
    jmp   L1

L3: ret
Str_lcase ENDP

```


* **설명:** 비교 범위를 `'a'~'z'` 에서 `'A'~'Z'` 로 바꾸고, `AND 11011111b`(비트 5 지우기) 대신 `OR 00100000b`(비트 5 설정)를 사용합니다. (`'A' = 41h = 01000001b` → `'a' = 61h = 01100001b`)




9. Str_trim 프로시저의 64비트 버전을 만드세요.
* Create a 64-bit version of the Str_trim procedure.
* Answer:
```assembly
;-----------------------------------------------------------
; Str_trim (64-bit)
; Remove all occurrences of a given delimiter
; character from the end of a string.
; Receives: RCX = pointer to the string
;           DL  = character to remove
; Returns:  nothing
;-----------------------------------------------------------
Str_trim PROC
    push  rax
    push  rdi

    ; 문자열 길이 구하기 (RAX)
    mov   rax,0
L0: cmp   BYTE PTR [rcx+rax],0          ; end of string?
    je    L1
    inc   rax
    jmp   L0

L1: cmp   rax,0                         ; 빈 문자열이면 종료
    je    L5
    lea   rdi,[rcx+rax-1]               ; RDI = 마지막 문자

L2: cmp   [rdi],dl                      ; delimiter?
    jne   L3                            ; 아니면 그 뒤에 null 삽입
    cmp   rdi,rcx                       ; 문자열 시작까지 왔나?
    je    L4
    dec   rdi                           ; 계속 뒤로
    jmp   L2

L3: mov   BYTE PTR [rdi+1],0            ; insert a null byte
    jmp   L5
L4: mov   BYTE PTR [rdi],0              ; 모두 delimiter → 빈 문자열

L5: pop   rdi
    pop   rax
    ret
Str_trim ENDP

```


* **설명:** 64비트 모드에서는 Microsoft x64 호출 규약에 맞춰 첫 번째 인자를 **RCX**, 두 번째 인자를 **RDX(DL)** 로 받습니다. 포인터와 주소 계산에는 64비트 레지스터(RCX, RDI)를 사용합니다. 호출 예:
```assembly
mov  rcx,OFFSET myString
mov  dl,'#'
call Str_trim

```




10. 64비트 모드에서 베이스-인덱스 피연산자의 예를 보이세요.
* Show an example of a base-index operand in 64-bit mode.
* Answer:
```assembly
mov rax,[rbx+rsi]       ; RBX = base, RSI = index

```




11. EBX에 32비트 정수 2차원 배열 myArray의 행 인덱스가, EDI에 열 인덱스가 들어 있다고 가정합니다. 해당 배열 원소의 내용을 EAX 레지스터로 옮기는 단일 문장을 작성하세요.
* Assuming that EBX contains a row index into a two-dimensional array of 32-bit integers named myArray and EDI contains the index of a column, write a single statement that moves the content of the given array element into the EAX register.
* Answer:
```assembly
mov eax,myArray[ebx + edi*TYPE myArray]

```


* **설명:** 9.4.3절의 방식처럼 EBX에는 **행의 바이트 오프셋**(행 인덱스 × 행 크기)이 들어 있다고 봅니다. 스케일 팩터는 1, 2, 4, 8만 가능하므로 행 크기를 곱하는 것은 한 문장에 넣을 수 없습니다. EBX가 순수한 행 번호라면 먼저 `imul ebx,RowSize` 로 바이트 오프셋으로 바꿔야 합니다.




12. RBX에 64비트 정수 2차원 배열 myArray의 행 인덱스가, RDI에 열 인덱스가 들어 있다고 가정합니다. 해당 배열 원소의 내용을 RAX 레지스터로 옮기는 단일 문장을 작성하세요.
* Assuming that RBX contains a row index into a two-dimensional array of 64-bit integers named myArray and RDI contains the index of a column, write a single statement that moves the content of the given array element into the RAX register.
* Answer:
```assembly
mov rax,myArray[rbx + rdi*TYPE myArray]     ; TYPE myArray = 8

```


* **설명:** 11번과 같은 방식이며, 원소가 QWORD이므로 스케일 팩터가 8이 됩니다. RBX는 행의 바이트 오프셋(행 인덱스 × 행 크기)입니다.
