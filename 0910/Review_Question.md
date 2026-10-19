# Review Question and Exercises
## 2.8 Review Questions

1. 32비트 모드에서 스택 포인터(ESP) 외에 스택의 변수를 가리키는 레지스터는 무엇인가요?
   - In 32-bit mode, aside from the stack pointer (ESP), what other register points to variables on the stack?
   - Answer: EBP (Extended Base Pointer, 프레임 포인터)

2. CPU 상태 플래그를 최소 4개 이상 말하세요.
   - Name at least four CPU status flags.
   - Answer: Carry(CF), Overflow(OF), Sign(SF), Zero(ZF), Auxiliary Carry(AC), Parity(PF)

3. 부호 없는 산술 연산의 결과가 목적지에 들어가기에 너무 클 때 설정되는 플래그는 무엇인가요?
   - Which flag is set when the result of an unsigned arithmetic operation is too large to fit into the destination?
   - Answer: Carry 플래그 (CF)

4. 부호 있는 산술 연산의 결과가 목적지에 들어가기에 너무 크거나 작을 때 설정되는 플래그는 무엇인가요?
   - Which flag is set when the result of a signed arithmetic operation is either too large or too small to fit into the destination?
   - Answer: Overflow 플래그 (OF)

5. (참/거짓): 레지스터 피연산자 크기가 32비트이고 REX 접두사를 사용하면, 프로그램에서 R8D 레지스터를 사용할 수 있다.
   - (True/False): When a register operand size is 32 bits and the REX prefix is used, the R8D register is available for programs to use.
   - Answer: True

6. 산술 또는 논리 연산의 결과가 음수일 때 설정되는 플래그는 무엇인가요?
   - Which flag is set when an arithmetic or logical operation generates a negative result?
   - Answer: Sign 플래그 (SF)

7. CPU의 어느 부분이 부동소수점 연산을 수행하나요?
   - Which part of the CPU performs floating-point arithmetic?
   - Answer: FPU (Floating-Point Unit, 부동소수점 장치)

8. 32비트 프로세서에서 각 부동소수점 데이터 레지스터는 몇 비트인가요?
   - On a 32-bit processor, how many bits are contained in each floating-point data register?
   - Answer: 80비트

9. (참/거짓): x86-64 명령어 집합은 x86 명령어 집합과 하위 호환된다.
   - (True/False): The x86-64 instruction set is backward-compatible with the x86 instruction set.
   - Answer: True

10. (참/거짓): 현재의 64비트 칩 구현에서는 주소 지정에 64비트 전부를 사용한다.
    - (True/False): In current 64-bit chip implementations, all 64 bits are used for addressing.
    - Answer: False (현재는 하위 48비트만 주소 지정에 사용)

11. (참/거짓): Itanium 명령어 집합은 x86 명령어 집합과 완전히 다르다.
    - (True/False): The Itanium instruction set is completely different from the x86 instruction set.
    - Answer: True

12. (참/거짓): Static RAM은 보통 Dynamic RAM보다 저렴하다.
    - (True/False): Static RAM is usually less expensive than dynamic RAM.
    - Answer: False (SRAM이 더 빠르고 비쌈 → 주로 캐시에 사용)

13. (참/거짓): REX 접두사를 사용하면 64비트 RDI 레지스터를 사용할 수 있다.
    - (True/False): The 64-bit RDI register is available when the REX prefix is used.
    - Answer: True

14. (참/거짓): 네이티브 64비트 모드에서는 16비트 리얼 모드는 사용할 수 있지만 가상-8086 모드는 사용할 수 없다.
    - (True/False): In native 64-bit mode, you can use 16-bit real mode, but not the virtual-8086 mode.
    - Answer: False (네이티브 64비트 모드는 리얼 모드와 가상-8086 모드 둘 다 지원하지 않음)

15. (참/거짓): x86-64 프로세서는 x86 프로세서보다 범용 레지스터가 4개 더 많다.
    - (True/False): The x86-64 processors have 4 more general-purpose registers than the x86 processors.
    - Answer: False (8개 더 많음: 8개 → 16개, R8~R15 추가)

16. (참/거짓): 64비트 버전 Microsoft Windows는 가상-8086 모드를 지원하지 않는다.
    - (True/False): The 64-bit version of Microsoft Windows does not support virtual-8086 mode.
    - Answer: True

17. (참/거짓): DRAM은 자외선으로만 지울 수 있다.
    - (True/False): DRAM can only be erased using ultraviolet light.
    - Answer: False (자외선으로 지우는 것은 EPROM)

18. (참/거짓): 64비트 모드에서는 최대 8개의 부동소수점 레지스터를 사용할 수 있다.
    - (True/False): In 64-bit mode, you can use up to eight floating-point registers.
    - Answer: True (80비트 부동소수점 레지스터 ST(0)~ST(7))

19. (참/거짓): 버스는 양 끝이 메인보드에 연결된 플라스틱 케이블이며, 메인보드 위에 직접 놓이지 않는다.
    - (True/False): A bus is a plastic cable that is attached to the motherboard at both ends, but does not sit directly on the motherboard.
    - Answer: False (버스는 메인보드에 새겨진 병렬 회로 배선)

20. (참/거짓): CMOS RAM은 Static RAM과 같아서 추가 전원이나 리프레시 없이 값을 유지한다.
    - (True/False): CMOS RAM is the same as static RAM, meaning that it holds its value without any extra power or refresh cycles.
    - Answer: False (CMOS RAM은 메인보드 배터리로 전원을 공급받아 값을 유지)

21. (참/거짓): PCI 커넥터는 그래픽 카드와 사운드 카드에 사용된다.
    - (True/False): PCI connectors are used for graphics cards and sound cards.
    - Answer: True

22. (참/거짓): 8259A는 하드웨어 장치의 외부 인터럽트를 처리하는 컨트롤러이다.
    - (True/False): The 8259A is a controller that handles external interrupts from hardware devices.
    - Answer: True (8259A PIC: Programmable Interrupt Controller)

23. (참/거짓): PCI는 programmable component interface의 약자이다.
    - (True/False): The acronym PCI stands for programmable component interface.
    - Answer: False (Peripheral Component Interconnect)

24. (참/거짓): VRAM은 virtual random access memory의 약자이다.
    - (True/False): VRAM stands for virtual random access memory.
    - Answer: False (Video Random Access Memory)

25. 어셈블리 언어 프로그램은 어떤 레벨에서 입출력을 다룰 수 있나요?
    - At which level(s) can an assembly language program manipulate input/output?
    - Answer: 세 레벨 모두 가능
      - 고수준 언어/운영체제 함수 호출 레벨 (OS API)
      - BIOS 레벨 (BIOS 함수 호출)
      - 하드웨어 레벨 (I/O 포트에 직접 접근)

26. 게임 프로그램은 왜 사운드 출력을 사운드 카드의 하드웨어 포트로 직접 보내는 경우가 많나요?
    - Why do game programs often send their sound output directly to the sound card's hardware ports?
    - Answer: 속도 때문. OS·BIOS 계층을 거치지 않고 하드웨어에 직접 접근하면 지연이 줄어 더 빠르고 정밀하게 사운드를 제어할 수 있음
