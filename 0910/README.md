# 0910

## 1. General Concepts (기본 개념)

### 1.1 마이크로컴퓨터 기본 구조 (Basic Microcomputer Design)

* **CPU (중앙처리장치)**: 컴퓨터의 뇌 역할을 수행
* **ALU (Arithmetic Logic Unit)**: 연산 담당
* **CU (Control Unit)**: 제어 담당
* **Clock**: 시스템 동기화
* **Registers**: CPU 내부에 위치한 초고속 기억장치


* **주기억장치 (Memory Storage Unit)**: 프로그램과 데이터를 저장
* **I/O Devices**: 입출력 장치
* **시스템 버스 (Bus)**: 데이터 및 신호 이동 통로
* **Data Bus / I/O Bus**: 데이터 전달
* **Address Bus**: 메모리/장치 주소 전달
* **Control Bus**: 제어 신호 전달



### 1.2 명령어 실행 주기 (Instruction Execution Cycle)

1. **Fetch Instruction**: 주기억장치(RAM)에서 명령어를 CPU로 가져옴
2. **Increment Instruction Pointer (IP/PC)**: 다음 실행할 명령어 주소로 포인터 증가
3. **Decode Instruction**: 명령어의 이진 패턴을 해독 (예: `MOV AX, 1234h` → `B8 34 12`)
4. **Fetch Operands**: 레지스터 또는 메모리에서 피연산자(Operand)를 가져옴
5. **Execute Instruction**: ALU 등을 통해 명령 실행
6. **Update Status Flags**: 실행 결과에 따라 플래그(Zero, Carry, Overflow 등) 업데이트
7. **Store Result**: 결과를 목적지 피연산자에 저장

### 1.3 메모리 읽기 순서 (Memory Read Sequence)

1. **Place Address on Bus**: 주소 버스에 읽고자 하는 메모리 주소 출력
2. **Assert RD Pin**: 프로세서가 `RD` 핀에 읽기 신호 인가
3. **Wait for Response**: 메모리가 응답할 때까지 대기
4. **Copy Data**: 데이터 버스의 데이터를 목적지 피연산자로 복사

### 1.4 프로그램 로딩 및 실행 (Loading and Executing a Program)

1. **Search for Program**: OS가 디렉토리에서 프로그램 파일 검색
2. **Retrieve File Information**: 파일 크기 및 위치 정보 확보
3. **Load Program into Memory**: 메모리에 프로그램 로드 및 공간 할당
4. **Begin Execution**: 프로그램 실행 시작
5. **Track Process**: OS가 프로세스 및 자원 관리
6. **End Process**: 종료 시 메모리에서 프로세스 해제

---

## 2. 32-Bit x86 Processors

### 2.1 동작 모드 (Modes of Operation)

* **Protected Mode (보호 모드)**: 전체 명령어 집합 및 메모리 보호 기능 제공, 4GB 선형 주소 공간 (현대 OS용)
* **Real-Address Mode (실상태 모드)**: 하드웨어 및 메모리에 직접 접근 (1MB 주소 공간 제한, DOS 환경)
* **Virtual-8086 Mode (가상 8086 모드)**: 보호 모드 내에서 안전하게 실상태 모드 소프트웨어를 실행 (프로그램당 1MB 가상 공간)
* **System Management Mode (SMM)**: 전력 관리 및 시스템 보안 전용 모드 (제조사 맞춤형)
* **Extended Physical Addressing**: 최대 64GB까지 물리 주소 확장 가능

### 2.2 기본 실행 레지스터 (Basic Execution Registers)

#### 범용 레지스터 (32-Bit General-Purpose Registers)

* **EAX**: 곱셈/나눗셈 연산, 리턴값 저장
* 하위 16비트: `AX` / 하위 8비트: `AH` (High), `AL` (Low)


* **EBX**: 베이스 지시자 (Base Register)
* **ECX**: 루프 카운터 (Loop Counter)
* **EDX**: 데이터 레지스터 (Data Register)
* **ESP**: 스택 포인터 (스택 내 데이터 주소 지시)
* **EBP**: 스택 프레임 포인터 (함수 매개변수 및 지역 변수 참조)
* **ESI / EDI**: 고속 메모리/문자열 전송 (Source / Destination Index)

#### 세그먼트 레지스터 (16-Bit Segment Registers)

* **CS (Code Segment)**: 실행 코드 명령어
* **DS (Data Segment)**: 변수 및 데이터
* **SS (Stack Segment)**: 스택 프레임 및 지역 변수
* **ES / FS / GS**: 추가 데이터 및 OS 특화 데이터 (Thread-Local Storage, System Call 등)

#### 명령 포인터 및 플래그

* **EIP (Instruction Pointer)**: 다음 실행할 명령어 주소 보유 (`JMP`, `CALL`, `RET` 등에 의해 변경 가능)
* **EFLAGS (Status Flags)**:
* **CF (Carry Flag)**: 부호 없는 연산의 자릿수 올림/내림
* **OF (Overflow Flag)**: 부호 있는 연산의 오버플로우
* **SF (Sign Flag)**: 결과가 음수일 때 셋
* **ZF (Zero Flag)**: 결과가 0일 때 셋
* **AC (Auxiliary Carry Flag)**: 8비트 연산 중 비트 3→4 올림
* **PF (Parity Flag)**: 결과의 1 비트 개수가 짝수일 때 셋



### 2.3 MMX & FPU (부동소수점 장치)

* **MMX**: SIMD (Single Instruction Multiple Data) 지원 64비트 레지스터 8개 (FPU 레지스터 공유)
* **FPU (Floating-Point Unit)**: 부동소수점 및 확장 정수 연산 전용
* 80비트 데이터 레지스터 8개 (`ST(0)` ~ `ST(7)`)
* Intel 486 이후 CPU 내부로 통합됨



---

## 3. 64-Bit x86-64 Processors

### 3.1 주요 특징 및 동작 모드 (IA-32e Mode)

* **64-Bit Mode**: 64비트 주소 공간 및 64비트 정수 피연산자 사용 (네이티브 64비트 앱)
* **Compatibility Mode**: 기존 16비트/32비트 앱을 재컴파일 없이 실행 (16비트 DOS/Windows 앱은 미지원)
* **주소 공간**: 48비트 실제 물리 주소 (최대 256TB RAM 지원) / 64비트 가상 주소 공간

### 3.2 32-Bit vs 64-Bit 차이점 비교

| 항목 | 32-bit | 64-bit |
| --- | --- | --- |
| **주소 크기** | 32 bits | 48 bits (실제) / 64 bits (이론) |
| **범용 레지스터 개수** | 8개 | 16개 (`R8` ~ `R15` 추가) |
| **부동소수점 레지스터** | 80-bit 8개 | 80-bit 8개 |
| **상태 플래그 레지스터** | EFLAGS (32-bit) | RFLAGS (64-bit) |
| **명령 포인터** | EIP (32-bit) | RIP (64-bit) |
| **XMM 레지스터** | 128-bit 8개 | 128-bit 16개 |

---

## 4. Components of a Typical x86 Computer

### 4.1 메인보드 구성 요소 (Motherboard Anatomy)

* **CPU Socket**: 프로세서 장착
* **Chipset (MCH/ICH)**: CPU 조력 및 데이터 흐름 제어 (예: Intel P965 Express Chipset)
* **Main Memory Slots**: DRAM 메모리 슬롯
* **BIOS Chip / CMOS RAM**: 시스템 부팅 소프트웨어 및 설정 저장 (배터리 백업)
* **Expansion Slots & Bus**: PCI, PCI Express (고속 데이터/그래픽 전송)
* **I/O Ports & Connectors**: USB, Mass-Storage(SATA), Network(LAN), Sound, Parallel Port

### 4.2 메모리 유형 (Memory Types)

* **ROM**: 비휘발성, 수정 불가 메모리
* **EPROM**: UV(자외선)로 지우고 재프로그래밍 가능한 메모리
* **SRAM**: 고속 캐시 메모리 (재충전 불필요)
* **DRAM**: 주기억장치 (주기적인 리프레시 필요)
* **VRAM**: 비디오 데이터 전용 메모리
* **CMOS RAM**: 시스템 설정값 유지 메모리

---

## 5. Input-Output (I/O) System

### 5.1 입출력 접근 계층 (Levels of I/O Access)

```text
Level 3: Application Program / High-Level Language (라이브러리 함수 호출)
   ↓
Level 2: OS Function (운영체제 API / 시스템 콜)
   ↓
Level 1: BIOS Subroutine / Function (장치 특화 제어)
   ↓
Level 0: Hardware Port Control (실제 하드웨어 직접 제어)

```

* **어셈블리 언어의 장점**: Level 0부터 Level 3까지 모든 계층의 I/O 접근이 가능함.
* **화면 문자 출력 예시**:
1. App Call (`printf` 등)
2. Library Function (포인터 전달)
3. OS Function
4. BIOS Subroutine (폰트 매핑)
5. Video Controller (화면 피셀 출력)