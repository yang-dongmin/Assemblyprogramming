#-----------------------------------------------------------
# info.s
# 학번과 이름을 입력받아 출력하는 프로그램
# 환경 : macOS, x86-64 (Apple Silicon에서는 Rosetta 2로 실행)
# 문법 : Intel 문법 (.intel_syntax noprefix)
# 빌드 : clang -arch x86_64 info.s -o info
# 실행 : ./info
#-----------------------------------------------------------
    .intel_syntax noprefix

BUF_SIZE = 64                           # 입력 버퍼 크기

#------------------- 문자열 상수 -------------------
    .section __TEXT,__cstring
promptId:   .asciz "학번을 입력하세요 : "
promptName: .asciz "이름을 입력하세요 : "
fmtIn:      .asciz " %63[^\n]"          # 앞 공백/개행 건너뛰고 줄 끝까지 최대 63자
fmtOut:     .asciz "\n학번 : %s\n이름 : %s\n"

#------------------- 데이터 -------------------
    .section __DATA,__data
studentId:  .space BUF_SIZE             # 학번 입력 버퍼
name:       .space BUF_SIZE             # 이름 입력 버퍼

#------------------- 코드 -------------------
    .section __TEXT,__text
    .globl _main
_main:
    push  rbp                           # 스택 프레임 생성
    mov   rbp, rsp                      # (RSP 16바이트 정렬)

#---- 1. 학번 입력 ----
    lea   rdi, [rip + promptId]         # printf("학번을 입력하세요 : ")
    xor   eax, eax                      # 가변 인자 함수: AL = 사용한 XMM 개수 (0)
    call  _printf

    lea   rdi, [rip + fmtIn]            # scanf(" %63[^\n]", studentId)
    lea   rsi, [rip + studentId]
    xor   eax, eax
    call  _scanf

#---- 2. 이름 입력 ----
    lea   rdi, [rip + promptName]       # printf("이름을 입력하세요 : ")
    xor   eax, eax
    call  _printf

    lea   rdi, [rip + fmtIn]            # scanf(" %63[^\n]", name)
    lea   rsi, [rip + name]
    xor   eax, eax
    call  _scanf

#---- 3. 출력 ----
    lea   rdi, [rip + fmtOut]           # 1번째 인자: 형식 문자열
    lea   rsi, [rip + studentId]        # 2번째 인자: 학번
    lea   rdx, [rip + name]             # 3번째 인자: 이름
    xor   eax, eax
    call  _printf                       # printf(fmtOut, studentId, name)

    xor   eax, eax                      # return 0
    pop   rbp
    ret
