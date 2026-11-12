# Review Question and Exercises

## Short Answer

1. 문자열 기본 명령어를 실행할 때 인덱스 레지스터가 메모리를 거꾸로(뒤쪽으로) 이동하게 만드는 Direction 플래그 설정은 무엇인가요?
* Which Direction flag setting causes index registers to move backward through memory when executing string primitives?
* Answer: Direction 플래그 = 1 (set), 즉 `STD` 명령어를 실행한 상태입니다. 이때 ESI와 EDI가 감소하여 높은 주소 → 낮은 주소 방향으로 진행합니다.




2. STOSW에 반복 접두사를 사용할 때, 인덱스 레지스터에 더하거나 빼는 값은 얼마인가요?
* When a repeat prefix is used with STOSW, what value is added to or subtracted from the index register?
* Answer: 2 (STOSW는 워드(2바이트) 단위이므로 반복할 때마다 EDI가 2씩 증가 또는 감소합니다.)




3. CMPS 명령어는 어떤 점에서 모호한가요?
* In what way is the CMPS instruction ambiguous?
* Answer: CMPS는 **source(ESI)에서 destination(EDI)을 빼는** 방식으로 플래그를 설정합니다. 일반 `CMP destination, source` 는 destination − source를 계산하므로 **피연산자 순서가 반대**여서 헷갈리기 쉽습니다. 예를 들어 `cmpsd` 후 `ja` 는 "[ESI] > [EDI]" 일 때 점프합니다.
* 또한 두 피연산자가 모두 메모리이고 암묵적이므로 크기를 알 수 없어, `CMPSB / CMPSW / CMPSD` 처럼 크기를 명시한 형태를 사용해야 합니다.




4. Direction 플래그가 clear이고 SCASB가 일치하는 문자를 찾았을 때, EDI는 어디를 가리키나요?
* When the Direction flag is clear and SCASB has found a matching character, where does EDI point?
* Answer: 일치한 문자의 **바로 다음 위치(한 바이트 뒤)** 를 가리킵니다. SCASB는 비교 후에도 EDI를 증가시키므로, 일치한 문자의 위치를 구하려면 `dec edi` 를 해야 합니다.




5. 배열에서 특정 문자가 처음 나타나는 위치를 찾을 때 가장 적합한 반복 접두사는 무엇인가요?
* When scanning an array for the first occurrence of a particular character, which repeat prefix would be best?
* Answer: `REPNE` (또는 `REPNZ`) — 값이 일치하지 않는 동안 스캔을 반복하다가 일치하는 값을 만나면 멈춥니다.




6. 9.3절의 Str_trim 프로시저에서는 어떤 Direction 플래그 설정을 사용하나요?
* What Direction flag setting is used in the Str_trim procedure from Section 9.3?
* Answer: 사용하지 않습니다 (어느 쪽이든 상관없음). Str_trim은 문자열 기본 명령어를 쓰지 않고 `dec edi` 로 직접 EDI를 감소시키며 문자열 끝에서 앞으로 스캔하므로 Direction 플래그의 영향을 받지 않습니다.




7. 9.3절의 Str_trim 프로시저는 왜 JNE 명령어를 사용하나요?
* Why does the Str_trim procedure from Section 9.3 use the JNE instruction?
* Answer: 끝에서부터 거꾸로 스캔하다가 **제거할 문자(delimiter)가 아닌 첫 문자**를 만나면 루프를 빠져나가기 위해서입니다. `cmp al,char` 결과가 같지 않으면(JNE) L2로 점프하여 그 문자 바로 다음 위치(`[edi+1]`)에 널 바이트를 넣습니다.




8. 9.3절의 Str_ucase 프로시저에서 대상 문자열에 숫자가 있으면 어떻게 되나요?
* What happens in the Str_ucase procedure from Section 9.3 if the target string contains a digit?
* Answer: 숫자는 바뀌지 않습니다. Str_ucase는 `'a'` ~ `'z'` 범위의 문자만 변환하는데, 숫자(`'0'` ~ `'9'` = 30h ~ 39h)는 `'a'`(61h)보다 작아 `jb L2` 로 건너뜁니다.




9. 9.3절의 Str_length 프로시저가 SCASB를 사용한다면 어떤 반복 접두사가 가장 적절한가요?
* If the Str_length procedure from Section 9.3 used SCASB, which repeat prefix would be most appropriate?
* Answer: `REPNE` (또는 `REPNZ`) — AL = 0으로 두고, 널 바이트와 일치하지 않는 동안 스캔하다가 널 바이트를 만나면 멈춥니다.




10. 9.3절의 Str_length 프로시저가 SCASB를 사용한다면 문자열 길이를 어떻게 계산하여 반환하나요?
* If the Str_length procedure from Section 9.3 used SCASB, how would it calculate and return the string length?
* Answer: `REPNE SCASB` 가 끝나면 EDI는 널 바이트의 한 칸 뒤를 가리키므로, **(EDI − 시작 주소) − 1** 이 길이입니다.
```assembly
Str_length PROC USES ecx edi,
    pString:PTR BYTE
    mov   edi,pString
    mov   al,0                  ; 찾을 값 = 널 바이트
    mov   ecx,0FFFFFFFFh        ; 최대 반복 횟수
    cld
    repne scasb                 ; 널 바이트를 찾을 때까지 스캔
    mov   eax,edi
    sub   eax,pString           ; 널 바이트 다음까지의 거리
    dec   eax                   ; 널 바이트는 제외
    ret
Str_length ENDP

```
* (ECX를 이용해 `not ecx` / `dec ecx` 로 계산하는 방법도 있습니다.)




11. 배열에 1,024개의 원소가 있을 때 이진 검색 알고리즘에 필요한 최대 비교 횟수는 얼마인가요?
* What is the maximum number of comparisons needed by the binary search algorithm when an array contains 1,024 elements?
* Answer: 11번 (1024 = 2¹⁰ 이므로 범위를 절반씩 10번 줄이면 원소 1개가 남고, 마지막 1번을 더 비교합니다. `log₂n + 1`)




12. 9.5절 이진 검색 예제의 FillArray 프로시저에서 왜 CLD 명령어로 Direction 플래그를 지워야 하나요?
* In the FillArray procedure from the Binary Search example in Section 9.5, why must the Direction flag be cleared by the CLD instruction?
* Answer: FillArray는 `STOSD` 로 배열에 값을 저장하는데, STOSD는 Direction 플래그에 따라 EDI를 증가 또는 감소시킵니다. 배열의 시작부터 끝까지 **정방향(낮은 주소 → 높은 주소)** 으로 채우려면 DF = 0이어야 하므로 CLD를 실행합니다. (DF = 1이면 EDI가 감소하여 배열 앞쪽 메모리를 덮어씁니다.)




13. 9.5절의 BinarySearch 프로시저에서 레이블 L2의 문장을 제거해도 결과에 영향이 없는 이유는 무엇인가요?
* In the BinarySearch procedure from Section 9.5, why could the statement at label L2 be removed without affecting the outcome?
* Answer: L2의 `cmp edx,edi` 는 바로 앞의 `cmp edx,edi` 와 **같은 비교**입니다. 그 사이의 `jge L2` 는 플래그를 바꾸지 않으므로, L2에 도착했을 때 앞의 비교 결과 플래그가 그대로 남아 있어 다시 비교할 필요가 없습니다.




14. 9.5절의 BinarySearch 프로시저에서 레이블 L4의 문장은 어떻게 없앨 수 있나요?
* In the BinarySearch procedure from Section 9.5, how might the statement at label L4 be eliminated?
* Answer: L4는 `jmp L1` 한 줄뿐이므로, L4로 점프하는 두 곳의 `jmp L4` 를 **`jmp L1` 으로 바꾸면** L4가 필요 없어집니다.
```assembly
    mov   first,eax
    jmp   L1                    ; jmp L4 대신
    ...
    mov   last,eax
    jmp   L1                    ; jmp L4 대신

```
