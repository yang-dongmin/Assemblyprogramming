# Review Question and Exercises

## Programming Exercises

* The following exercises can be done in either 32-bit mode or 64-bit mode. Each string-handling procedure assumes the use of null-terminated strings. Even when not explicitly requested, write a short driver program for each exercise solution that tests your new procedure.
* **해석:** 다음 연습 문제는 32비트 모드와 64비트 모드 중 어느 쪽으로 풀어도 됩니다. 모든 문자열 처리 프로시저는 널 종료 문자열을 사용한다고 가정합니다. 따로 요구하지 않더라도 각 문제마다 새 프로시저를 테스트하는 짧은 드라이버 프로그램을 작성하세요.
* 아래 풀이는 모두 **32비트 모드(Irvine32)** 로 작성했습니다. 문자열을 `[` `]` 로 감싸 출력하는 다음 보조 프로시저를 여러 문제에서 사용합니다.
```assembly
;-----------------------------------------------------
; ShowStr
; Displays a string surrounded by brackets: [string]
; Receives: pString = pointer to the string
;-----------------------------------------------------
ShowStr PROC USES eax edx,
    pString:PTR BYTE
    mov  al,'['
    call WriteChar
    mov  edx,pString
    call WriteString
    mov  al,']'
    call WriteChar
    call Crlf
    ret
ShowStr ENDP

```




1. 개선된 Str_copy 프로시저 (Improved Str_copy Procedure)
* The Str_copy procedure shown in this chapter does not limit the number of characters to be copied. Create a new version (named Str_copyN) that receives an additional input parameter indicating the maximum number of characters to be copied.
* **해석:** 이 장의 Str_copy 프로시저는 복사할 문자 수를 제한하지 않습니다. 복사할 최대 문자 수를 나타내는 입력 파라미터를 하나 더 받는 새 버전(Str_copyN)을 만드세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

Str_copyN PROTO, source:PTR BYTE, target:PTR BYTE, maxChars:DWORD
ShowStr   PROTO, pString:PTR BYTE

.data
sourceStr BYTE "ABCDEFGHIJ",0
targetStr BYTE 21 DUP(0)                ; 최대 20문자 + null

.code
main PROC
    INVOKE Str_copyN, ADDR sourceStr, ADDR targetStr, 5
    INVOKE ShowStr, ADDR targetStr       ; [ABCDE]

    INVOKE Str_copyN, ADDR sourceStr, ADDR targetStr, 3
    INVOKE ShowStr, ADDR targetStr       ; [ABC]

    INVOKE Str_copyN, ADDR sourceStr, ADDR targetStr, 20
    INVOKE ShowStr, ADDR targetStr       ; [ABCDEFGHIJ] (원본이 더 짧음)

    INVOKE Str_copyN, ADDR sourceStr, ADDR targetStr, 0
    INVOKE ShowStr, ADDR targetStr       ; []
    exit
main ENDP

;-----------------------------------------------------
; Str_copyN
; Copies at most maxChars characters from source to
; target, and appends a null byte.
; Requires: target must hold maxChars + 1 bytes.
;-----------------------------------------------------
Str_copyN PROC USES eax ecx esi edi,
    source:PTR BYTE,
    target:PTR BYTE,
    maxChars:DWORD

    INVOKE Str_length, source           ; EAX = source 길이
    cmp   eax,maxChars
    jbe   L1                            ; 길이 <= 최대값 이면 그대로
    mov   eax,maxChars                  ; 아니면 최대값만큼만
L1: mov   ecx,eax                       ; REP count
    mov   esi,source
    mov   edi,target
    cld
    rep   movsb                         ; ECX 문자 복사
    mov   BYTE PTR [edi],0              ; null 종료
    ret
Str_copyN ENDP

; ShowStr PROC 은 위의 보조 프로시저와 동일
END main

```


* **설명:** 원래 Str_copy는 `length + 1` 바이트(널 포함)를 복사합니다. Str_copyN은 복사할 문자 수를 `min(length, maxChars)` 로 제한하고, 잘린 경우에도 문자열이 끝나도록 **마지막에 널 바이트를 직접 붙입니다**. `rep movsb` 후 EDI는 마지막으로 복사한 문자 다음을 가리키므로 그 자리에 0을 넣으면 됩니다.
* **실행 결과:**
```
[ABCDE]
[ABC]
[ABCDEFGHIJ]
[]
```




2. Str_concat 프로시저 (Str_concat Procedure)
* Write a procedure named Str_concat that concatenates a source string to the end of a target string. Sufficient space must exist in the target string to accommodate the new characters. Pass pointers to the source and target strings. Here is a sample call:
```assembly
.data
targetStr BYTE "ABCDE",10 DUP(0)
sourceStr BYTE "FGH",0
.code
INVOKE Str_concat, ADDR targetStr, ADDR sourceStr

```
* **해석:** source 문자열을 target 문자열의 끝에 이어 붙이는 Str_concat 프로시저를 작성하세요. target 문자열에는 새 문자를 담을 충분한 공간이 있어야 합니다. source와 target 문자열의 포인터를 전달합니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

Str_concat PROTO, target:PTR BYTE, source:PTR BYTE
ShowStr    PROTO, pString:PTR BYTE

.data
targetStr BYTE "ABCDE",10 DUP(0)
sourceStr BYTE "FGH",0
source2   BYTE "IJ",0

.code
main PROC
    INVOKE Str_concat, ADDR targetStr, ADDR sourceStr
    INVOKE ShowStr, ADDR targetStr       ; [ABCDEFGH]

    INVOKE Str_concat, ADDR targetStr, ADDR source2
    INVOKE ShowStr, ADDR targetStr       ; [ABCDEFGHIJ]
    exit
main ENDP

;-----------------------------------------------------
; Str_concat
; Appends the source string to the end of the target.
; Requires: target must have enough space.
;-----------------------------------------------------
Str_concat PROC USES eax ecx esi edi,
    target:PTR BYTE,
    source:PTR BYTE

    INVOKE Str_length, target           ; EAX = target 길이
    mov   edi,target
    add   edi,eax                       ; EDI = target의 null 위치
    INVOKE Str_length, source           ; EAX = source 길이
    mov   ecx,eax
    inc   ecx                           ; null 바이트까지 복사
    mov   esi,source
    cld
    rep   movsb                         ; target 끝에 source 복사
    ret
Str_concat ENDP

; ShowStr PROC 은 위의 보조 프로시저와 동일
END main

```


* **설명:** target의 널 바이트 위치(시작 + 길이)부터 source를 널 바이트까지 복사하면, target의 원래 널 바이트가 덮어써지고 새 문자열 끝에 널이 붙습니다. Str_length는 `USES edi` 로 EDI를 보존하므로 두 번째 호출 후에도 EDI가 유지됩니다.
* **실행 결과:**
```
[ABCDEFGH]
[ABCDEFGHIJ]
```




3. Str_remove 프로시저 (Str_remove Procedure)
* Write a procedure named Str_remove that removes n characters from a string. Pass a pointer to the position in the string where the characters are to be removed. Pass an integer specifying the number of characters to remove. The following code, for example, shows how to remove "xxxx" from target:
```assembly
.data
target BYTE "abcxxxxdefghijklmop",0
.code
INVOKE Str_remove, ADDR [target+3], 4

```
* **해석:** 문자열에서 n개의 문자를 제거하는 Str_remove 프로시저를 작성하세요. 문자를 제거할 문자열 안의 위치에 대한 포인터와, 제거할 문자 수를 정수로 전달합니다. 위 코드는 target에서 "xxxx"를 제거하는 예입니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

Str_remove PROTO, pStart:PTR BYTE, nChars:DWORD
ShowStr    PROTO, pString:PTR BYTE

.data
target  BYTE "abcxxxxdefghijklmop",0
target2 BYTE "Hello World",0

.code
main PROC
    INVOKE Str_remove, ADDR [target+3], 4
    INVOKE ShowStr, ADDR target          ; [abcdefghijklmop]

    INVOKE Str_remove, ADDR [target2+5], 100
    INVOKE ShowStr, ADDR target2         ; [Hello] (남은 길이보다 많이 제거)
    exit
main ENDP

;-----------------------------------------------------
; Str_remove
; Removes nChars characters starting at pStart.
; Receives: pStart = position to remove from
;           nChars = number of characters to remove
;-----------------------------------------------------
Str_remove PROC USES eax ecx esi edi,
    pStart:PTR BYTE,
    nChars:DWORD

    INVOKE Str_length, pStart           ; EAX = pStart부터 끝까지의 길이
    mov   ecx,nChars
    cmp   ecx,eax
    jbe   L1
    mov   ecx,eax                       ; 남은 길이보다 크면 남은 만큼만
L1: mov   edi,pStart                    ; EDI = 제거할 위치
    lea   esi,[edi + ecx]               ; ESI = 제거 구간 다음 문자
    sub   eax,ecx                       ; EAX = 뒤에 남는 문자 수
    mov   ecx,eax
    inc   ecx                           ; null 바이트까지
    cld
    rep   movsb                         ; 뒷부분을 앞으로 당김
    ret
Str_remove ENDP

; ShowStr PROC 은 위의 보조 프로시저와 동일
END main

```


* **설명:** 제거 구간 바로 뒤(`pStart + n`)부터 널 바이트까지를 `pStart` 위치로 앞으로 당겨 복사합니다. 복사 방향이 낮은 주소 쪽(목적지 < 원본)이므로 정방향(`cld`) 복사를 해도 아직 읽지 않은 데이터를 덮어쓰지 않습니다.
```
 제거 전:  a b c x x x x d e f g h i j k l m o p 0
                 ▲       ▲
               EDI      ESI (= EDI + 4)
 제거 후:  a b c d e f g h i j k l m o p 0 ...
```
* **실행 결과:**
```
[abcdefghijklmop]
[Hello]
```




4. Str_find 프로시저 (Str_find Procedure)
* Write a procedure named Str_find that searches for the first matching occurrence of a source string inside a target string and returns the matching position. The input parameters should be a pointer to the source string and a pointer to the target string. If a match is found, the procedure sets the Zero flag and EAX points to the matching position in the target string. Otherwise, the Zero flag is clear and EAX is undefined. The following code, for example, searches for "ABC" and returns with EAX pointing to the "A" in the target string:
```assembly
.data
target BYTE "123ABC342432",0
source BYTE "ABC",0
pos    DWORD ?
.code
INVOKE Str_find, ADDR source, ADDR target
jnz    notFound
mov    pos,eax              ; store the position value

```
* **해석:** target 문자열 안에서 source 문자열이 처음 나타나는 위치를 찾아 반환하는 Str_find 프로시저를 작성하세요. 입력 파라미터는 source 문자열과 target 문자열의 포인터입니다. 찾으면 Zero 플래그를 설정하고 EAX가 target 문자열 안의 일치 위치를 가리키게 합니다. 못 찾으면 Zero 플래그를 지우며 EAX는 정의되지 않습니다. 위 코드는 "ABC"를 찾아 EAX가 target의 "A"를 가리키는 예입니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

Str_find PROTO, pSource:PTR BYTE, pTarget:PTR BYTE

.data
target  BYTE "123ABC342432",0
source  BYTE "ABC",0
source2 BYTE "XYZ",0
pos     DWORD ?
msgPos  BYTE "Found at index ",0
msgNot  BYTE "Not found",0

.code
main PROC
    INVOKE Str_find, ADDR source, ADDR target
    call  ShowResult                    ; Found at index 3

    INVOKE Str_find, ADDR source2, ADDR target
    call  ShowResult                    ; Not found
    exit
main ENDP

;-----------------------------------------------------
; ShowResult
; ZF = 1 이면 target 안의 위치(인덱스)를, 아니면
; "Not found" 를 출력한다.
;-----------------------------------------------------
ShowResult PROC USES edx
    jnz   notFound
    mov   pos,eax                       ; store the position value
    mov   edx,OFFSET msgPos
    call  WriteString
    mov   eax,pos
    sub   eax,OFFSET target             ; 주소 → 인덱스
    call  WriteDec
    jmp   done
notFound:
    mov   edx,OFFSET msgNot
    call  WriteString
done:
    call  Crlf
    ret
ShowResult ENDP

;-----------------------------------------------------
; Str_find
; Finds the first occurrence of source inside target.
; Returns: ZF = 1 and EAX = matching position if found,
;          otherwise ZF = 0 (EAX undefined)
;-----------------------------------------------------
Str_find PROC USES ebx ecx edx esi edi,
    pSource:PTR BYTE,
    pTarget:PTR BYTE

    INVOKE Str_length, pSource
    mov   ebx,eax                       ; EBX = source 길이
    INVOKE Str_length, pTarget          ; EAX = target 길이
    cmp   eax,ebx
    jb    notFound                      ; target이 더 짧으면 실패
    sub   eax,ebx
    inc   eax
    mov   edx,eax                       ; EDX = 비교할 시작 위치 개수
    mov   edi,pTarget                   ; EDI = 현재 시작 위치
    cld

L1: mov   esi,pSource
    push  edi                           ; 시작 위치 저장
    mov   ecx,ebx
    repe  cmpsb                         ; source 길이만큼 비교
    pop   edi                           ; 시작 위치 복원 (플래그 불변)
    je    found                         ; 모두 같으면 찾음
    inc   edi                           ; 다음 시작 위치
    dec   edx
    jnz   L1

notFound:
    or    eax,1                         ; ZF = 0
    jmp   done
found:
    mov   eax,edi                       ; EAX = 일치 위치
    cmp   eax,eax                       ; ZF = 1
done:
    ret
Str_find ENDP
END main

```


* **설명:** target의 각 위치에서 `REPE CMPSB` 로 source 길이만큼 비교합니다. 모든 바이트가 같으면 ZF = 1로 끝나고, 하나라도 다르면 ZF = 0입니다. 비교할 시작 위치는 `target 길이 − source 길이 + 1` 개면 충분합니다. 결과 플래그는 `or eax,1`(ZF = 0)과 `cmp eax,eax`(ZF = 1)로 명확히 설정하며, 이후의 `pop`, `ret` 은 플래그를 바꾸지 않습니다. (source가 빈 문자열인 경우는 고려하지 않았습니다.)
* **실행 결과:**
```
Found at index 3
Not found
```




5. Str_nextWord 프로시저 (Str_nextWord Procedure)
* Write a procedure called Str_nextWord that scans a string for the first occurrence of a certain delimiter character and replaces the delimiter with a null byte. There are two input parameters: a pointer to the string and the delimiter character. After the call, if the delimiter was found, the Zero flag is set and EAX contains the offset of the next character beyond the delimiter. Otherwise, the Zero flag is clear and EAX is undefined. The following example code passes the address of target and a comma as the delimiter:
```assembly
.data
target BYTE "Johnson,Calvin",0
.code
INVOKE Str_nextWord, ADDR target, ','
jnz notFound

```
* In Figure 9-5, after calling Str_nextWord, EAX points to the character following the position where the comma was found (and replaced).
```
Figure 9-5. Str_nextWord example

 J  o  h  n  s  o  n  0  C  a  l  v  i  n  0
                      ▲  ▲                 ▲
                      │  └─ EAX            │
                      └──── Null bytes ────┘
```
* **해석:** 문자열에서 특정 구분 문자가 처음 나타나는 위치를 찾아 그 구분 문자를 널 바이트로 바꾸는 Str_nextWord 프로시저를 작성하세요. 입력 파라미터는 문자열의 포인터와 구분 문자 두 개입니다. 호출 후 구분 문자를 찾았으면 Zero 플래그가 설정되고 EAX에는 구분 문자 다음 문자의 오프셋이 들어갑니다. 못 찾으면 Zero 플래그가 지워지고 EAX는 정의되지 않습니다. Figure 9-5처럼 호출 후 EAX는 쉼표가 있던(그리고 널로 바뀐) 위치의 다음 문자를 가리킵니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

Str_nextWord PROTO, pString:PTR BYTE, delimiter:BYTE

.data
target BYTE "Johnson,Calvin,Smith",0

.code
main PROC
    mov   esi,OFFSET target             ; ESI = 현재 단어 시작
L1:
    INVOKE Str_nextWord, esi, ','
    jnz   lastWord                      ; 더 이상 구분 문자 없음
    mov   ebx,eax                       ; EBX = 다음 단어 시작
    mov   edx,esi
    call  WriteString                   ; 현재 단어 출력
    call  Crlf
    mov   esi,ebx                       ; 다음 단어로
    jmp   L1
lastWord:
    mov   edx,esi
    call  WriteString                   ; 마지막 단어 출력
    call  Crlf
    exit
main ENDP

;-----------------------------------------------------
; Str_nextWord
; Replaces the first delimiter with a null byte.
; Returns: ZF = 1 and EAX = offset of the character after
;          the delimiter if found, otherwise ZF = 0
;-----------------------------------------------------
Str_nextWord PROC USES ecx edi,
    pString:PTR BYTE,
    delimiter:BYTE

    INVOKE Str_length, pString
    mov   ecx,eax                       ; ECX = 검색할 문자 수
    cmp   ecx,0
    je    notFound                      ; 빈 문자열
    mov   edi,pString
    mov   al,delimiter
    cld
    repne scasb                         ; 구분 문자 검색
    jnz   notFound
    mov   BYTE PTR [edi-1],0            ; 구분 문자 → null (ZF 유지)
    mov   eax,edi                       ; EAX = 구분 문자 다음 위치
    jmp   done
notFound:
    or    eax,1                         ; ZF = 0
done:
    ret
Str_nextWord ENDP
END main

```


* **설명:** `REPNE SCASB` 로 구분 문자를 찾으면 EDI는 구분 문자의 한 칸 뒤를 가리키므로, `[edi-1]` 에 널 바이트를 넣고 EDI를 그대로 EAX로 반환합니다. `MOV` 는 플래그를 바꾸지 않으므로 SCASB가 남긴 ZF = 1이 유지됩니다. 드라이버는 반환된 EAX를 다음 호출의 시작 위치로 넘기며 문자열을 단어 단위로 나눕니다.
* **실행 결과:**
```
Johnson
Calvin
Smith
```




6. 빈도표 만들기 (Constructing a Frequency Table)
* Write a procedure named Get_frequencies that constructs a character frequency table. Input to the procedure should be a pointer to a string and a pointer to an array of 256 doublewords initialized to all zeros. Each array position is indexed by its corresponding ASCII code. When the procedure returns, each entry in the array contains a count of how many times the corresponding character occurred in the string. For example,
```assembly
.data
target    BYTE "AAEBDCFBBC",0
freqTable DWORD 256 DUP(0)
.code
INVOKE Get_frequencies, ADDR target, ADDR freqTable

```
* Figure 9-6 shows a picture of the string and entries 41 (hexadecimal) through 4B in the frequency table. Position 41 contains the value 2 because the letter A (ASCII code 41h) occurred twice in the string. Similar counts are shown for other characters. Frequency tables are useful in data compression and other applications involving character processing. The Huffman encoding algorithm, for example, stores the most frequently occurring characters in fewer bits than other characters that occur less often.
```
Figure 9-6. Sample character frequency table

Target string:   A   A   E   B   D   C   F   B   B   C   0
ASCII code:     41  41  45  42  44  43  46  42  42  43   0

Frequency table: 2   3   2   1   1   1   0   0   0   0   0  etc.
Index:          41  42  43  44  45  46  47  48  49  4A  4B
```
* **해석:** 문자 빈도표를 만드는 Get_frequencies 프로시저를 작성하세요. 입력은 문자열의 포인터와, 0으로 초기화된 doubleword 256개 배열의 포인터입니다. 배열의 각 위치는 해당 ASCII 코드로 인덱싱됩니다. 프로시저가 반환되면 배열의 각 원소에는 해당 문자가 문자열에 나타난 횟수가 들어 있어야 합니다. Figure 9-6은 문자열과 빈도표의 41h ~ 4Bh 원소를 보여 줍니다. 문자 A(41h)가 두 번 나오므로 41번 위치의 값은 2입니다. 빈도표는 데이터 압축 등 문자 처리 응용에 유용하며, 예를 들어 허프만 부호화는 자주 나오는 문자를 더 적은 비트로 저장합니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

Get_frequencies PROTO, pString:PTR BYTE, pTable:PTR DWORD

.data
target    BYTE "AAEBDCFBBC",0
freqTable DWORD 256 DUP(0)
sep       BYTE " : ",0

.code
main PROC
    INVOKE Get_frequencies, ADDR target, ADDR freqTable

    ; 41h('A') ~ 4Bh('K') 출력
    mov   esi,41h
L1: mov   eax,esi
    call  WriteChar                     ; 문자
    mov   edx,OFFSET sep
    call  WriteString
    mov   eax,freqTable[esi*TYPE freqTable]
    call  WriteDec                      ; 빈도
    call  Crlf
    inc   esi
    cmp   esi,4Bh
    jbe   L1
    exit
main ENDP

;-----------------------------------------------------
; Get_frequencies
; Counts how many times each character occurs.
; Receives: pString = pointer to the string
;           pTable  = pointer to 256 DWORDs (all zero)
; Returns:  nothing (table is filled)
;-----------------------------------------------------
Get_frequencies PROC USES eax esi edi,
    pString:PTR BYTE,
    pTable:PTR DWORD

    mov   esi,pString
    mov   edi,pTable
    cld
L1: lodsb                               ; AL = 다음 문자, ESI++
    cmp   al,0
    je    done                          ; 문자열 끝
    movzx eax,al                        ; EAX = ASCII 코드 (인덱스)
    inc   DWORD PTR [edi + eax*4]       ; table[code]++
    jmp   L1
done:
    ret
Get_frequencies ENDP
END main

```


* **설명:** `LODSB` 로 한 문자씩 읽고, ASCII 코드를 그대로 배열 인덱스로 사용하여 `[edi + eax*4]` (DWORD이므로 스케일 4) 원소를 1 증가시킵니다. 메모리 피연산자에 바로 `INC` 를 할 수 있으므로 값을 레지스터로 옮길 필요가 없습니다.
* **실행 결과:**
```
A : 2
B : 3
C : 2
D : 1
E : 1
F : 1
G : 0
H : 0
I : 0
J : 0
K : 0
```




7. 에라토스테네스의 체 (Sieve of Eratosthenes)
* The Sieve of Eratosthenes, invented by the Greek mathematician of the same name, provides a quick way to find all prime numbers within a given range. The algorithm involves creating an array of bytes in which positions are "marked" by inserting 1s in the following manner: Beginning with position 2 (which is a prime number), insert a 1 in each array position that is a multiple of 2. Then do the same thing for multiples of 3, the next prime number. Find the next prime number after 3, which is 5, and mark all positions that are multiples of 5. Proceed in this manner until all multiples of primes have been found. The remaining positions of the array that are unmarked indicate which numbers are prime. For this program, create a 65,000-element array and display all primes between 2 and 65,000. Declare the array in an uninitialized data segment (see Section 3.4.11) and use STOSB to fill it with zeros.
* **해석:** 같은 이름의 그리스 수학자가 고안한 에라토스테네스의 체는 주어진 범위의 모든 소수를 빠르게 찾는 방법입니다. 바이트 배열을 만들고 다음과 같이 1을 넣어 위치를 "표시"합니다. 소수인 2부터 시작하여 2의 배수 위치에 모두 1을 넣고, 다음 소수인 3의 배수에도 똑같이 합니다. 3 다음 소수인 5를 찾아 5의 배수를 모두 표시하고, 이런 식으로 모든 소수의 배수를 표시할 때까지 계속합니다. 표시되지 않고 남은 위치가 소수입니다. 65,000개 원소 배열을 만들어 2부터 65,000 사이의 모든 소수를 출력하세요. 배열은 초기화되지 않은 데이터 세그먼트(3.4.11절)에 선언하고 STOSB로 0을 채우세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

N = 65000

.data?                                  ; 초기화되지 않은 데이터 세그먼트
sieve BYTE (N + 1) DUP(?)               ; 0 = 소수 후보, 1 = 합성수

.code
main PROC
    ; STOSB 로 배열 전체를 0으로 채우기
    mov   edi,OFFSET sieve
    mov   ecx,N + 1
    mov   al,0
    cld
    rep   stosb

    ; 체 만들기
    mov   esi,2                         ; i = 2
outer:
    mov   eax,esi
    mul   esi                           ; EAX = i * i
    cmp   eax,N
    ja    display                       ; i * i > N 이면 완료
    cmp   sieve[esi],0
    jne   nextI                         ; 이미 표시된 수(합성수)는 건너뜀
    mov   edi,eax                       ; j = i * i
inner:
    cmp   edi,N
    ja    nextI
    mov   sieve[edi],1                  ; i의 배수 표시
    add   edi,esi                       ; j += i
    jmp   inner
nextI:
    inc   esi
    jmp   outer

    ; 표시되지 않은 수(소수) 출력
display:
    mov   esi,2
L1: cmp   sieve[esi],0
    jne   next
    mov   eax,esi
    call  WriteDec
    mov   al,' '
    call  WriteChar
next:
    inc   esi
    cmp   esi,N
    jbe   L1

    call  Crlf
    exit
main ENDP
END main

```


* **설명:** `.data?` 세그먼트에 선언한 배열은 실행 파일에 공간을 차지하지 않으며 초기값이 정해지지 않으므로, 시작할 때 `REP STOSB` 로 0을 채웁니다. 소수 i의 배수 중 i보다 작은 배수(2i, 3i, ...)는 이미 더 작은 소수에서 표시되었으므로 `i * i` 부터 표시하면 되고, `i * i > N` 이 되면 체가 완성됩니다. 2 ~ 65,000 사이의 소수는 모두 **6,493개**입니다.
* **실행 결과:**
```
2 3 5 7 11 13 17 19 23 29 31 37 41 ... 64927 64937 64951 64969 64997
```




8. 버블 정렬 (Bubble Sort)
* Add a variable to the BubbleSort procedure in Section 9.5.1 that is set to 1 whenever a pair of values is exchanged within the inner loop. Use this variable to exit the sort before its normal completion if you discover that no exchanges took place during a complete pass through the array. (This variable is commonly known as an exchange flag.)
* **해석:** 9.5.1절의 BubbleSort 프로시저에 안쪽 루프에서 값의 쌍을 교환할 때마다 1로 설정되는 변수를 추가하세요. 배열을 한 번 완전히 훑는 동안 교환이 한 번도 없었다면, 이 변수를 사용하여 정상 종료 전에 정렬을 끝내세요. (이 변수를 보통 교환 플래그(exchange flag)라고 합니다.)
* Answer:
```assembly
INCLUDE Irvine32.inc

BubbleSort   PROTO, pArray:PTR DWORD, Count:DWORD
DisplayArray PROTO, pArray:PTR DWORD, Count:DWORD

.data
array1 SDWORD 3, 1, 7, 5, 2, 9, 4, 3
array2 SDWORD 1, 2, 3, 5, 4, 6, 7, 8         ; 거의 정렬됨 → 2패스 후 종료

.code
main PROC
    INVOKE BubbleSort, ADDR array1, LENGTHOF array1
    INVOKE DisplayArray, ADDR array1, LENGTHOF array1

    INVOKE BubbleSort, ADDR array2, LENGTHOF array2
    INVOKE DisplayArray, ADDR array2, LENGTHOF array2
    exit
main ENDP

;------------------------------------------------------
; BubbleSort
; Sort an array of 32-bit signed integers in ascending
; order, using the bubble sort algorithm with an
; exchange flag.
; Receives: pointer to array, array size
; Returns: nothing
;------------------------------------------------------
BubbleSort PROC USES eax ecx esi,
    pArray:PTR DWORD,                   ; pointer to array
    Count:DWORD                         ; array size
    LOCAL exchangeFlag:DWORD            ; 교환 플래그

    mov   ecx,Count
    dec   ecx                           ; decrement count by 1
    jle   L4                            ; 원소가 1개 이하면 종료
L1: push  ecx                           ; save outer loop count
    mov   exchangeFlag,0                ; 이번 패스의 교환 플래그 초기화
    mov   esi,pArray                    ; point to first value
L2: mov   eax,[esi]                     ; get array value
    cmp   [esi+4],eax                   ; compare a pair of values
    jge   L3                            ; if [ESI] <= [ESI+4], no exchange
    xchg  eax,[esi+4]                   ; exchange the pair
    mov   [esi],eax
    mov   exchangeFlag,1                ; 교환 발생
L3: add   esi,4                         ; move both pointers forward
    loop  L2                            ; inner loop
    pop   ecx                           ; retrieve outer loop count
    cmp   exchangeFlag,0
    je    L4                            ; 교환이 없었으면 이미 정렬됨 → 조기 종료
    loop  L1                            ; else repeat outer loop
L4: ret
BubbleSort ENDP

;------------------------------------------------------
; DisplayArray
; Displays an array of signed integers on one line.
;------------------------------------------------------
DisplayArray PROC USES eax ecx esi,
    pArray:PTR DWORD,
    Count:DWORD
    mov   esi,pArray
    mov   ecx,Count
L1: mov   eax,[esi]
    call  WriteInt
    mov   al,' '
    call  WriteChar
    add   esi,TYPE DWORD
    loop  L1
    call  Crlf
    ret
DisplayArray ENDP
END main

```


* **설명:** 패스를 시작할 때 `exchangeFlag` 를 0으로 두고, 교환이 일어나면 1로 설정합니다. 한 패스가 끝났는데 플래그가 0이면 모든 인접 쌍이 이미 순서대로라는 뜻이므로 남은 패스를 건너뛰고 종료합니다. 원래 코드의 `JG` 는 같은 값도 교환하므로, 같은 값이 있으면 교환 플래그가 매번 1이 되어 조기 종료가 일어나지 않습니다. 그래서 **`JGE`** 로 바꿔 같은 값은 교환하지 않게 했습니다. array2는 첫 패스에서 5와 4만 교환하고, 두 번째 패스에서 교환이 없어 바로 끝납니다 (원래는 7패스).
* **실행 결과:**
```
+1 +2 +3 +3 +4 +5 +7 +9
+1 +2 +3 +4 +5 +6 +7 +8
```




9. 이진 검색 (Binary Search)
* Rewrite the binary search procedure shown in this chapter by using registers for mid, first, and last. Add comments to clarify the registers' usage.
* **해석:** 이 장의 이진 검색 프로시저를 mid, first, last에 레지스터를 사용하도록 다시 작성하세요. 레지스터의 용도를 명확히 하는 주석을 추가하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

BinarySearch PROTO, pArray:PTR DWORD, Count:DWORD, searchVal:DWORD

.data
values SDWORD -50, -20, 3, 7, 15, 28, 40, 66    ; 정렬된 배열
tests  SDWORD 28, -50, 66, 10
msg1   BYTE "Search ",0
msg2   BYTE " -> ",0

.code
main PROC
    mov   esi,OFFSET tests
    mov   ecx,LENGTHOF tests
L1: mov   edx,OFFSET msg1
    call  WriteString
    mov   eax,[esi]
    call  WriteInt                      ; 찾을 값
    mov   edx,OFFSET msg2
    call  WriteString
    INVOKE BinarySearch, ADDR values, LENGTHOF values, DWORD PTR [esi]
    call  WriteInt                      ; 결과 위치 (-1 = 없음)
    call  Crlf
    add   esi,TYPE tests
    loop  L1
    exit
main ENDP

;-------------------------------------------------------------
; BinarySearch
; Searches an array of signed integers for a single value.
; Receives: Pointer to array, array size, search value.
; Returns: If a match is found, EAX = the array position of the
;          matching element; otherwise, EAX = -1.
;
; Register usage:
;   EBX = pointer to the array
;   ECX = searchVal
;   ESI = first
;   EDI = last
;   EDX = mid
;   EAX = values[mid] (비교용), 반환값
;-------------------------------------------------------------
BinarySearch PROC USES ebx ecx edx esi edi,
    pArray:PTR DWORD,                   ; pointer to array
    Count:DWORD,                        ; array size
    searchVal:DWORD                     ; search value

    mov   ebx,pArray                    ; EBX = 배열 주소
    mov   ecx,searchVal                 ; ECX = 찾을 값
    mov   esi,0                         ; ESI = first = 0
    mov   edi,Count
    dec   edi                           ; EDI = last = count - 1

L1: cmp   esi,edi                       ; while first <= last
    jg    L5                            ; first > last 이면 실패

    mov   edx,esi
    add   edx,edi
    shr   edx,1                         ; EDX = mid = (first + last) / 2

    mov   eax,[ebx + edx*4]             ; EAX = values[mid]
    cmp   eax,ecx                       ; values[mid] 와 searchVal 비교
    jl    L2                            ; values[mid] < searchVal
    jg    L3                            ; values[mid] > searchVal
    mov   eax,edx                       ; 같으면 EAX = mid
    jmp   L9

L2: lea   esi,[edx + 1]                 ; first = mid + 1
    jmp   L1
L3: lea   edi,[edx - 1]                 ; last = mid - 1
    jmp   L1

L5: mov   eax,-1                        ; search failed
L9: ret
BinarySearch ENDP
END main

```


* **설명:** LOCAL 변수(first, last, mid) 대신 ESI, EDI, EDX를 사용하므로 메모리 접근이 줄어 더 빠릅니다. 스케일 팩터를 쓰는 `[ebx + edx*4]` 로 `shl` 없이 바로 원소에 접근하고, `LEA` 로 `mid ± 1` 을 플래그 변화 없이 한 명령어로 계산합니다. 한 번의 `CMP` 뒤에 `JL`, `JG` 를 연달아 사용하므로 원래 코드의 두 번째 비교(L2)와 L4도 필요 없습니다.
* **실행 결과:**
```
Search +28 -> +5
Search -50 -> +0
Search +66 -> +7
Search +10 -> -1
```




10. 문자 행렬 (Letter Matrix)
* Create a procedure that generates a four-by-four matrix of randomly chosen capital letters. When choosing the letters, there must be a 50% probability that the chosen letter is a vowel. Write a test program with a loop that calls your procedure five times and displays each matrix in the console window. Following is sample output for the first three matrices:
```
D W A L        K X S V        P O A Z
S I V W        N U U O        A E A U
U I O L        O R Q O        G K A E
L A I I        A U U T        I A G D
```
* **해석:** 무작위로 고른 대문자로 이루어진 4 × 4 행렬을 생성하는 프로시저를 만드세요. 문자를 고를 때 모음일 확률이 50%가 되어야 합니다. 프로시저를 다섯 번 호출하고 각 행렬을 콘솔 창에 출력하는 루프가 있는 테스트 프로그램을 작성하세요. 위는 처음 세 행렬의 출력 예입니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

MakeMatrix PROTO, pMatrix:PTR BYTE
ShowMatrix PROTO, pMatrix:PTR BYTE

.data
vowels     BYTE "AEIOU"                         ; 5개
consonants BYTE "BCDFGHJKLMNPQRSTVWXYZ"         ; 21개
matrix     BYTE 16 DUP(?)                       ; 4 x 4

.code
main PROC
    call  Randomize                     ; 난수 시드 초기화
    mov   ecx,5                         ; 5번 반복
L1: INVOKE MakeMatrix, ADDR matrix
    INVOKE ShowMatrix, ADDR matrix
    loop  L1
    exit
main ENDP

;-----------------------------------------------------
; MakeMatrix
; Fills a 4 x 4 matrix with random capital letters.
; Each letter has a 50% chance of being a vowel.
;-----------------------------------------------------
MakeMatrix PROC USES eax ecx esi,
    pMatrix:PTR BYTE

    mov   esi,pMatrix
    mov   ecx,16                        ; 원소 16개
L1: mov   eax,2
    call  RandomRange                   ; EAX = 0 또는 1 (각 50%)
    cmp   eax,0
    jne   consonant
    mov   eax,LENGTHOF vowels
    call  RandomRange                   ; 모음 중 하나
    mov   al,vowels[eax]
    jmp   store
consonant:
    mov   eax,LENGTHOF consonants
    call  RandomRange                   ; 자음 중 하나
    mov   al,consonants[eax]
store:
    mov   [esi],al
    inc   esi
    loop  L1
    ret
MakeMatrix ENDP

;-----------------------------------------------------
; ShowMatrix
; Displays a 4 x 4 letter matrix, followed by a blank line.
;-----------------------------------------------------
ShowMatrix PROC USES eax ebx ecx esi,
    pMatrix:PTR BYTE

    mov   esi,pMatrix
    mov   ebx,4                         ; 4행
rowLoop:
    mov   ecx,4                         ; 4열
colLoop:
    mov   al,[esi]
    call  WriteChar
    mov   al,' '
    call  WriteChar
    inc   esi
    loop  colLoop
    call  Crlf
    dec   ebx
    jnz   rowLoop
    call  Crlf                          ; 행렬 사이 빈 줄
    ret
ShowMatrix ENDP
END main

```


* **설명:** 먼저 `RandomRange(2)` 로 모음/자음을 50% 확률로 정한 뒤, 고른 그룹 안에서 다시 `RandomRange` 로 문자를 고릅니다. 모음은 5개, 자음은 21개라 모든 문자 중에서 고르면 모음 확률이 약 19%밖에 안 되므로, 이렇게 **두 단계로 골라야** 50%가 됩니다. 행렬은 16바이트 1차원 배열에 행 우선으로 저장합니다.
* **실행 결과:** (난수이므로 실행할 때마다 다름)
```
D W A L
S I V W
U I O L
L A I I

K X S V
N U U O
O R Q O
A U U T

... (총 5개)
```




11. 문자 행렬 / 모음이 있는 집합 (Letter Matrix/Sets with Vowels)
* Use the letter matrix generated in the previous programming exercise as a starting point for this program. Generate a single random four-by-four letter matrix in which each letter has a 50% probability of being a vowel. Traverse each matrix row, column, and diagonal, generating sets of letters. Display only four-letter sets containing exactly two vowels. Suppose, for example, the following matrix was generated:
```
P O A Z
A E A U
G K A E
I A G D
```
* Then the four-letter sets displayed by the program would be POAZ, GKAE, IAGD, PAGI, ZUED, PEAD, and ZAKI. The order of letters within each set is unimportant.
* **해석:** 앞 문제에서 만든 문자 행렬을 출발점으로 사용합니다. 각 문자가 50% 확률로 모음인 4 × 4 무작위 문자 행렬을 하나 생성하세요. 행렬의 각 행, 열, 대각선을 따라가며 문자 집합을 만들고, **모음이 정확히 2개**인 4글자 집합만 출력하세요. 예를 들어 위 행렬이면 POAZ, GKAE, IAGD, PAGI, ZUED, PEAD, ZAKI가 출력됩니다. 집합 안의 문자 순서는 상관없습니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

MakeMatrix PROTO, pMatrix:PTR BYTE
ShowMatrix PROTO, pMatrix:PTR BYTE
CheckSet   PROTO, pMatrix:PTR BYTE, startIdx:DWORD, step:DWORD
FindSets   PROTO, pMatrix:PTR BYTE

.data
vowels     BYTE "AEIOU"
consonants BYTE "BCDFGHJKLMNPQRSTVWXYZ"
testMatrix BYTE "POAZ","AEAU","GKAE","IAGD"     ; 교재 예시 행렬
matrix     BYTE 16 DUP(?)
setBuf     BYTE 5 DUP(0)                        ; 4글자 + null

.code
main PROC
    ; 1) 교재 예시 행렬로 확인
    INVOKE ShowMatrix, ADDR testMatrix
    INVOKE FindSets, ADDR testMatrix

    ; 2) 무작위 행렬
    call  Randomize
    INVOKE MakeMatrix, ADDR matrix
    INVOKE ShowMatrix, ADDR matrix
    INVOKE FindSets, ADDR matrix
    exit
main ENDP

;-----------------------------------------------------
; FindSets
; Checks all rows, columns and diagonals of a 4 x 4
; matrix and displays sets with exactly two vowels.
;-----------------------------------------------------
FindSets PROC USES ebx ecx,
    pMatrix:PTR BYTE

    ; 행: 시작 = r * 4, 간격 = 1
    mov   ebx,0
    mov   ecx,4
rows:
    INVOKE CheckSet, pMatrix, ebx, 1
    add   ebx,4
    loop  rows

    ; 열: 시작 = c, 간격 = 4
    mov   ebx,0
    mov   ecx,4
cols:
    INVOKE CheckSet, pMatrix, ebx, 4
    inc   ebx
    loop  cols

    ; 대각선: 0,5,10,15 (간격 5) / 3,6,9,12 (간격 3)
    INVOKE CheckSet, pMatrix, 0, 5
    INVOKE CheckSet, pMatrix, 3, 3

    call  Crlf
    ret
FindSets ENDP

;-----------------------------------------------------
; CheckSet
; Collects 4 letters: matrix[startIdx + k*step] (k = 0..3).
; Displays the set if it contains exactly two vowels.
;-----------------------------------------------------
CheckSet PROC USES eax ebx ecx edx esi,
    pMatrix:PTR BYTE,
    startIdx:DWORD,
    step:DWORD

    mov   esi,pMatrix
    add   esi,startIdx                  ; ESI = 첫 문자
    mov   edx,OFFSET setBuf             ; EDX = 집합 버퍼
    mov   ebx,0                         ; EBX = 모음 개수
    mov   ecx,4
L1: mov   al,[esi]
    mov   [edx],al                      ; 집합에 문자 저장
    call  IsVowel
    jne   notVowel
    inc   ebx                           ; 모음이면 개수 증가
notVowel:
    add   esi,step                      ; 다음 문자 위치
    inc   edx
    loop  L1

    cmp   ebx,2                         ; 모음이 정확히 2개?
    jne   done
    mov   edx,OFFSET setBuf
    call  WriteString
    mov   al,' '
    call  WriteChar
done:
    ret
CheckSet ENDP

;-----------------------------------------------------
; IsVowel
; Receives: AL = character
; Returns:  ZF = 1 if AL is a vowel
;-----------------------------------------------------
IsVowel PROC USES ecx edi
    mov   edi,OFFSET vowels
    mov   ecx,LENGTHOF vowels
    cld
    repne scasb                         ; 모음 목록에서 AL 검색
    ret
IsVowel ENDP

; MakeMatrix, ShowMatrix 는 연습 문제 10과 동일
MakeMatrix PROC USES eax ecx esi,
    pMatrix:PTR BYTE
    mov   esi,pMatrix
    mov   ecx,16
L1: mov   eax,2
    call  RandomRange
    cmp   eax,0
    jne   consonant
    mov   eax,LENGTHOF vowels
    call  RandomRange
    mov   al,vowels[eax]
    jmp   store
consonant:
    mov   eax,LENGTHOF consonants
    call  RandomRange
    mov   al,consonants[eax]
store:
    mov   [esi],al
    inc   esi
    loop  L1
    ret
MakeMatrix ENDP

ShowMatrix PROC USES eax ebx ecx esi,
    pMatrix:PTR BYTE
    mov   esi,pMatrix
    mov   ebx,4
rowLoop:
    mov   ecx,4
colLoop:
    mov   al,[esi]
    call  WriteChar
    mov   al,' '
    call  WriteChar
    inc   esi
    loop  colLoop
    call  Crlf
    dec   ebx
    jnz   rowLoop
    call  Crlf
    ret
ShowMatrix ENDP
END main

```


* **설명:** 4 × 4 행렬을 1차원 배열(인덱스 0 ~ 15)로 보면, 모든 행·열·대각선은 **시작 인덱스와 간격**으로 표현할 수 있습니다. 모음 판별은 이 장의 `REPNE SCASB` 로 모음 목록 "AEIOU"에서 문자를 검색하여 ZF로 알려 줍니다.

| 집합 | 시작 | 간격 | 인덱스 |
| --- | --- | --- | --- |
| r행 (r = 0 ~ 3) | r × 4 | 1 | r×4, r×4+1, r×4+2, r×4+3 |
| c열 (c = 0 ~ 3) | c | 4 | c, c+4, c+8, c+12 |
| 주대각선 | 0 | 5 | 0, 5, 10, 15 |
| 반대각선 | 3 | 3 | 3, 6, 9, 12 |

* 교재 예시 행렬의 판정:

| 집합 | 문자 | 모음 수 | 출력 |
| --- | --- | --- | --- |
| 0행 | POAZ | 2 (O, A) | O |
| 1행 | AEAU | 4 | X |
| 2행 | GKAE | 2 (A, E) | O |
| 3행 | IAGD | 2 (I, A) | O |
| 0열 | PAGI | 2 (A, I) | O |
| 1열 | OEKA | 3 | X |
| 2열 | AAAG | 3 | X |
| 3열 | ZUED | 2 (U, E) | O |
| 주대각선 | PEAD | 2 (E, A) | O |
| 반대각선 | ZAKI | 2 (A, I) | O |

* **실행 결과:** (두 번째 행렬은 난수이므로 실행할 때마다 다름)
```
P O A Z
A E A U
G K A E
I A G D

POAZ GKAE IAGD PAGI ZUED PEAD ZAKI
...
```




12. 배열 행의 합 계산 (Calculating the Sum of an Array Row)
* Write a procedure named calc_row_sum that calculates the sum of a single row in a two-dimensional array of bytes, words, or doublewords. The procedure should have the following stack parameters: array offset, row size, array type, row index. It must return the sum in EAX. Use explicit stack parameters, not INVOKE or extended PROC. Write a program that tests your procedure with arrays of byte, word, and doubleword. Prompt the user for the row index, and display the sum of the selected row.
* **해석:** byte, word, doubleword 2차원 배열에서 한 행의 합을 계산하는 calc_row_sum 프로시저를 작성하세요. 스택 파라미터는 배열 오프셋, 행 크기, 배열 타입, 행 인덱스입니다. 합은 EAX로 반환해야 합니다. INVOKE나 확장 PROC가 아니라 명시적 스택 파라미터를 사용하세요. byte, word, doubleword 배열로 프로시저를 테스트하는 프로그램을 작성하고, 사용자에게 행 인덱스를 입력받아 선택한 행의 합을 출력하세요.
* Answer:
```assembly
INCLUDE Irvine32.inc

.data
; 3행 4열 배열 (행 크기 = 원소 4개)
tableB BYTE    1,    2,    3,    4
       BYTE    5,    6,    7,    8
       BYTE    9,   10,   11,   12
tableW WORD  100,  200,  300,  400
       WORD  500,  600,  700,  800
       WORD  900, 1000, 1100, 1200
tableD DWORD 10000, 20000, 30000, 40000
       DWORD 50000, 60000, 70000, 80000
       DWORD 90000,100000,110000,120000
ROW_SIZE = 4                            ; 한 행의 원소 개수

prompt BYTE "Enter a row index (0-2): ",0
msgB   BYTE "BYTE  row sum = ",0
msgW   BYTE "WORD  row sum = ",0
msgD   BYTE "DWORD row sum = ",0

.code
main PROC
    mov   edx,OFFSET prompt
    call  WriteString
    call  ReadDec                       ; EAX = 행 인덱스
    mov   ebx,eax                       ; EBX = 행 인덱스

    ; BYTE 배열
    push  ebx                           ; row index
    push  TYPE tableB                   ; array type (1)
    push  ROW_SIZE                      ; row size
    push  OFFSET tableB                 ; array offset
    call  calc_row_sum
    mov   edx,OFFSET msgB
    call  WriteString
    call  WriteDec
    call  Crlf

    ; WORD 배열
    push  ebx
    push  TYPE tableW                   ; 2
    push  ROW_SIZE
    push  OFFSET tableW
    call  calc_row_sum
    mov   edx,OFFSET msgW
    call  WriteString
    call  WriteDec
    call  Crlf

    ; DWORD 배열
    push  ebx
    push  TYPE tableD                   ; 4
    push  ROW_SIZE
    push  OFFSET tableD
    call  calc_row_sum
    mov   edx,OFFSET msgD
    call  WriteString
    call  WriteDec
    call  Crlf
    exit
main ENDP

;----------------------------------------------------------
; calc_row_sum
; Calculates the sum of a row in a byte, word, or
; doubleword matrix (unsigned values).
; Receives (stack parameters):
;   [ebp+8]  = array offset
;   [ebp+12] = row size (number of elements)
;   [ebp+16] = array type (1, 2, or 4)
;   [ebp+20] = row index
; Returns: EAX = sum of the row
;----------------------------------------------------------
calc_row_sum PROC
    push  ebp
    mov   ebp,esp
    push  ebx
    push  ecx
    push  edx
    push  esi

    mov   eax,[ebp+20]                  ; row index
    mul   DWORD PTR [ebp+12]            ; * row size
    mul   DWORD PTR [ebp+16]            ; * type → 행의 바이트 오프셋
    mov   esi,[ebp+8]
    add   esi,eax                       ; ESI = 행의 시작 주소
    mov   ecx,[ebp+12]                  ; ECX = 원소 개수
    mov   ebx,[ebp+16]                  ; EBX = 원소 크기
    mov   eax,0                         ; 합계

L1: cmp   ebx,1
    je    isByte
    cmp   ebx,2
    je    isWord
    mov   edx,[esi]                     ; DWORD
    jmp   addIt
isByte:
    movzx edx,BYTE PTR [esi]            ; BYTE → 32비트
    jmp   addIt
isWord:
    movzx edx,WORD PTR [esi]            ; WORD → 32비트
addIt:
    add   eax,edx
    add   esi,ebx                       ; 다음 원소
    loop  L1

    pop   esi
    pop   edx
    pop   ecx
    pop   ebx
    pop   ebp
    ret   16                            ; 파라미터 4개 정리
calc_row_sum ENDP
END main

```


* **설명:** 파라미터를 행 인덱스부터 역순으로 push하므로 프로시저 안에서 `[ebp+8]` = 배열 오프셋, `[ebp+12]` = 행 크기, `[ebp+16]` = 타입, `[ebp+20]` = 행 인덱스가 됩니다. 행의 바이트 오프셋은 `행 인덱스 × 행 크기 × 타입` 이며, 원소 크기(1, 2, 4)에 따라 `MOVZX` 로 32비트로 확장해 더합니다. `ret 16` 으로 파라미터 4개(16바이트)를 정리합니다.

```
┌────────────────┐
│   row index    │  [EBP + 20]
├────────────────┤
│   array type   │  [EBP + 16]
├────────────────┤
│    row size    │  [EBP + 12]
├────────────────┤
│  array offset  │  [EBP + 8]
├────────────────┤
│ return address │  [EBP + 4]
├────────────────┤
│      EBP       │  ← EBP
└────────────────┘
```
* **실행 결과:**
```
Enter a row index (0-2): 1
BYTE  row sum = 26
WORD  row sum = 2600
DWORD row sum = 260000
```




13. 앞쪽 문자 제거 (Trimming Leading Characters)
* Create a variant of the Str_trim procedure that lets the caller remove all instances of a leading character from a string. For example, if you were to call it with a pointer to the string "###ABC" and pass it the # character, the resulting string would be "ABC."
* **해석:** 문자열 앞쪽에 붙은 특정 문자를 모두 제거할 수 있는 Str_trim의 변형 프로시저를 만드세요. 예를 들어 "###ABC" 문자열의 포인터와 # 문자를 전달하면 결과 문자열은 "ABC"가 됩니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

Str_trimLeading PROTO, pString:PTR BYTE, char:BYTE
ShowStr         PROTO, pString:PTR BYTE

.data
str1 BYTE "###ABC",0
str2 BYTE "ABC",0
str3 BYTE "###",0
str4 BYTE "#A#",0

.code
main PROC
    INVOKE Str_trimLeading, ADDR str1, '#'
    INVOKE ShowStr, ADDR str1            ; [ABC]
    INVOKE Str_trimLeading, ADDR str2, '#'
    INVOKE ShowStr, ADDR str2            ; [ABC]
    INVOKE Str_trimLeading, ADDR str3, '#'
    INVOKE ShowStr, ADDR str3            ; []
    INVOKE Str_trimLeading, ADDR str4, '#'
    INVOKE ShowStr, ADDR str4            ; [A#]
    exit
main ENDP

;-----------------------------------------------------------
; Str_trimLeading
; Remove all occurrences of a given character from the
; beginning of a string.
; Returns: nothing
;-----------------------------------------------------------
Str_trimLeading PROC USES eax esi,
    pString:PTR BYTE,                   ; points to string
    char:BYTE                           ; character to remove

    mov   esi,pString
    mov   al,char
L1: cmp   BYTE PTR [esi],0              ; 문자열 끝?
    je    L2
    cmp   [esi],al                      ; 제거할 문자인가?
    jne   L2                            ; 아니면 멈춤
    inc   esi                           ; 맞으면 다음 문자로
    jmp   L1

L2: cmp   esi,pString                   ; 제거할 문자가 없었나?
    je    L3
    INVOKE Str_copy, esi, pString       ; 남은 부분을 앞으로 당김
L3: ret
Str_trimLeading ENDP

; ShowStr PROC 은 위의 보조 프로시저와 동일
END main

```


* **설명:** 앞에서부터 제거할 문자가 아닌 첫 위치(ESI)를 찾은 뒤, 그 위치부터 널 바이트까지를 문자열 시작으로 복사합니다. 목적지가 원본보다 앞(낮은 주소)이므로 Str_copy의 정방향 `rep movsb` 로 겹치는 영역을 안전하게 복사할 수 있습니다. 모두 제거할 문자이면 ESI가 널 바이트를 가리키므로 빈 문자열이 복사됩니다.
* **실행 결과:**
```
[ABC]
[ABC]
[]
[A#]
```




14. 문자 집합 제거 (Trimming a Set of Characters)
* Create a variant of the Str_trim procedure that lets the caller remove all instances of a set of characters from the end of a string. For example, if you were to call it with a pointer to the string "ABC#$&" and pass it a pointer to an array of filter characters containing "%#!;$&*", the resulting string would be "ABC".
* **해석:** 문자열 끝에서 특정 문자 집합에 속하는 문자를 모두 제거할 수 있는 Str_trim의 변형 프로시저를 만드세요. 예를 들어 "ABC#$&" 문자열의 포인터와, "%#!;$&*"를 담은 필터 문자 배열의 포인터를 전달하면 결과 문자열은 "ABC"가 됩니다.
* Answer:
```assembly
INCLUDE Irvine32.inc

Str_trimSet PROTO, pString:PTR BYTE, pFilter:PTR BYTE
ShowStr     PROTO, pString:PTR BYTE

.data
filter BYTE "%#!;$&*",0
str1   BYTE "ABC#$&",0
str2   BYTE "#$&",0
str3   BYTE "A#B$",0
str4   BYTE "ABC",0

.code
main PROC
    INVOKE Str_trimSet, ADDR str1, ADDR filter
    INVOKE ShowStr, ADDR str1            ; [ABC]
    INVOKE Str_trimSet, ADDR str2, ADDR filter
    INVOKE ShowStr, ADDR str2            ; []
    INVOKE Str_trimSet, ADDR str3, ADDR filter
    INVOKE ShowStr, ADDR str3            ; [A#B]
    INVOKE Str_trimSet, ADDR str4, ADDR filter
    INVOKE ShowStr, ADDR str4            ; [ABC]
    exit
main ENDP

;-----------------------------------------------------------
; Str_trimSet
; Remove all trailing characters that belong to a set
; of filter characters.
; Receives: pString = pointer to the string
;           pFilter = pointer to the filter characters
; Returns:  nothing
;-----------------------------------------------------------
Str_trimSet PROC USES eax ebx ecx edx esi edi,
    pString:PTR BYTE,
    pFilter:PTR BYTE

    INVOKE Str_length, pFilter
    mov   edx,eax                       ; EDX = 필터 문자 개수
    cmp   edx,0
    je    done                          ; 필터가 비어 있으면 종료
    INVOKE Str_length, pString
    cmp   eax,0
    je    done                          ; 빈 문자열이면 종료
    mov   ebx,eax                       ; EBX = 남은 문자 수
    mov   esi,pString
    add   esi,eax
    dec   esi                           ; ESI = 마지막 문자
    cld

L1: mov   al,[esi]                      ; 현재 문자
    mov   edi,pFilter
    mov   ecx,edx
    repne scasb                         ; 필터 집합에 있는지 검색
    jne   L2                            ; 없으면 여기서 멈춤
    dec   esi                           ; 있으면 계속 뒤로
    dec   ebx
    jnz   L1                            ; 문자열 시작까지

L2: mov   BYTE PTR [esi+1],0            ; insert a null byte
done:
    ret
Str_trimSet ENDP

; ShowStr PROC 은 위의 보조 프로시저와 동일
END main

```


* **설명:** 원래 Str_trim의 `cmp al,char` 비교를 **필터 문자열에 대한 `REPNE SCASB` 검색**으로 바꿨습니다. 끝에서부터 거꾸로 가며 현재 문자가 필터 집합에 있으면(ZF = 1) 계속 뒤로 가고, 없으면(ZF = 0) 그 문자 다음에 널 바이트를 넣습니다. 모든 문자가 필터에 속하면 EBX가 0이 되고 ESI는 문자열 시작 − 1을 가리키므로 `[esi+1]` 에 널이 들어가 빈 문자열이 됩니다.
* **실행 결과:**
```
[ABC]
[]
[A#B]
[ABC]
```
