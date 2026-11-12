#-----------------------------------------------------------
# avg.s
# 정수 5개를 입력받아 합계와 평균을 출력하는 프로그램
# 환경 : macOS, x86-64 (Apple Silicon에서는 Rosetta 2로 실행)
# 문법 : Intel 문법 (.intel_syntax noprefix)
# 빌드 : clang -arch x86_64 avg.s -o avg
# 실행 : ./avg
#-----------------------------------------------------------
    .intel_syntax noprefix

COUNT = 5                               # 입력받을 숫자 개수

#------------------- 문자열 상수 -------------------
    .section __TEXT,__cstring
prompt:   .asciz "Enter number %d: "
fmtIn:    .asciz "%d"
fmtSum:   .asciz "\nSum     = %d\n"
fmtAvg:   .asciz "Average = %d (remainder %d) = %.2f\n"

#------------------- 데이터 -------------------
    .section __DATA,__data
    .p2align 2
nums:     .space COUNT * 4              # DWORD 배열 5개

#------------------- 코드 -------------------
    .section __TEXT,__text
    .globl _main
_main:
    push  rbp                           # 스택 프레임 생성
    mov   rbp, rsp
    push  rbx                           # rbx = 반복 인덱스 i
    push  r12                           # r12 = 합계 sum
                                        # (push 3번 → RSP 16바이트 정렬)
    xor   ebx, ebx                      # i = 0
    xor   r12d, r12d                    # sum = 0

#---- 1. 숫자 5개 입력 ----
InputLoop:
    lea   rdi, [rip + prompt]           # printf("Enter number %d: ", i+1)
    lea   esi, [rbx + 1]
    xor   eax, eax                      # 가변 인자 함수: AL = 사용한 XMM 개수
    call  _printf

    lea   rdi, [rip + fmtIn]            # scanf("%d", &nums[i])
    lea   rsi, [rip + nums]
    lea   rsi, [rsi + rbx*4]            # 주소 = nums + i * 4
    xor   eax, eax
    call  _scanf

    lea   rcx, [rip + nums]
    add   r12d, DWORD PTR [rcx + rbx*4] # sum += nums[i]

    inc   ebx                           # i++
    cmp   ebx, COUNT
    jl    InputLoop                     # i < 5 이면 반복

#---- 2. 합계 출력 ----
    lea   rdi, [rip + fmtSum]           # printf("Sum = %d", sum)
    mov   esi, r12d
    xor   eax, eax
    call  _printf

#---- 3. 평균 계산 ----
    mov   eax, r12d                     # EDX:EAX = sum (부호 확장)
    cdq
    mov   ecx, COUNT
    idiv  ecx                           # EAX = 몫, EDX = 나머지

    cvtsi2sd xmm0, r12d                 # xmm0 = (double)sum
    cvtsi2sd xmm1, ecx                  # xmm1 = 5.0
    divsd    xmm0, xmm1                 # xmm0 = sum / 5.0

#---- 4. 평균 출력 ----
    lea   rdi, [rip + fmtAvg]           # printf(fmt, 몫, 나머지, 실수 평균)
    mov   esi, eax
    # EDX(나머지)는 그대로 세 번째 인자
    mov   eax, 1                        # XMM 레지스터 1개 사용
    call  _printf

#---- 종료 ----
    xor   eax, eax                      # return 0
    pop   r12
    pop   rbx
    pop   rbp
    ret
