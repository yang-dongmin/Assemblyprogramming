# Review Question and Exercises
## Algorithm Workbench

1. 16비트 이진수 문자열을 받아 정수 값을 반환하는 함수를 작성하세요.
   - Write a function that receives a string containing a 16-bit binary integer. The function must return the string’s integer value.
   - Answer:
     ```python
     def binary_to_int(bin_str: str) -> int:
         result = 0
         for char in bin_str:
             if char == '1':
                 result = (result << 1) | 1
             elif char == '0':
                 result = result << 1
         return result
     ```

2. 32비트 16진수 문자열을 받아 정수 값을 반환하는 함수를 작성하세요.
   - Write a function that receives a string containing a 32-bit hexadecimal integer. The function must return the string’s integer value.
   - Answer:
     ```python
     def hex_to_int(hex_str: str) -> int:
         result = 0
         for char in hex_str:
             if '0' <= char <= '9':
                 digit = ord(char) - ord('0')
             elif 'A' <= char <= 'F':
                 digit = ord(char) - ord('A') + 10
             elif 'a' <= char <= 'f':
                 digit = ord(char) - ord('a') + 10
             else:
                 continue
             result = (result << 4) | digit
         return result
     ```

3. 정수를 받아 이진수 표현 문자열을 반환하는 함수를 작성하세요.
   - Write a function that receives an integer. The function must return a string containing the binary representation of the integer.
   - Answer:
     ```python
     def int_to_binary(n: int) -> str:
         if n == 0:
             return "0"
         is_negative = n < 0
         if is_negative:
             n = -n
         bits = []
         while n > 0:
             bits.append(str(n % 2))
             n //= 2
         if is_negative:
             bits.append("-")
         bits.reverse()
         return "".join(bits)
     ```

4. 정수를 받아 16진수 표현 문자열을 반환하는 함수를 작성하세요.
   - Write a function that receives an integer. The function must return a string containing the hexadecimal representation of the integer.
   - Answer:
     ```python
     def int_to_hex(n: int) -> str:
         if n == 0:
             return "0"
         hex_chars = "0123456789ABCDEF"
         is_negative = n < 0
         if is_negative:
             n = -n
         digits = []
         while n > 0:
             remainder = n % 16
             digits.append(hex_chars[remainder])
             n //= 16
         if is_negative:
             digits.append("-")
         digits.reverse()
         return "".join(digits)
     ```

5. 2 ~ 10진법 사이의 두 숫자 문자열(최대 1,000자리)을 더하는 함수를 작성하세요.
   - Write a function that adds two digit strings in base b, where 2 <= b <= 10. Each string may contain as many as 1,000 digits. Return the sum in a string that uses the same number base.
   - Answer:
     ```python
     def add_base_b(num1: str, num2: str, b: int) -> str:
         i, j = len(num1) - 1, len(num2) - 1
         carry = 0
         result = []
         while i >= 0 or j >= 0 or carry:
             d1 = ord(num1[i]) - ord('0') if i >= 0 else 0
             d2 = ord(num2[j]) - ord('0') if j >= 0 else 0
             total = d1 + d2 + carry
             carry = total // b
             result.append(str(total % b))
             i -= 1
             j -= 1
         result.reverse()
         return "".join(result)
     ```

6. 최대 1,000자리의 두 16진수 문자열을 더하고, 결과 16진수 문자열을 반환하는 함수를 작성하세요.
   - Write a function that adds two hexadecimal strings, each as long as 1,000 digits. Return a hexadecimal string that represents the sum of the inputs.
   - Answer:
     ```python
     def add_hex_strings(hex1: str, hex2: str) -> str:
         hex_chars = "0123456789ABCDEF"
         def char_to_val(c: str) -> int:
             c = c.upper()
             return ord(c) - ord('0') if '0' <= c <= '9' else ord(c) - ord('A') + 10
         i, j = len(hex1) - 1, len(hex2) - 1
         carry = 0
         result = []
         while i >= 0 or j >= 0 or carry:
             val1 = char_to_val(hex1[i]) if i >= 0 else 0
             val2 = char_to_val(hex2[j]) if j >= 0 else 0
             total = val1 + val2 + carry
             carry = total // 16
             result.append(hex_chars[total % 16])
             i -= 1
             j -= 1
         result.reverse()
         return "".join(result)
     ```

7. 1자리의 16진수와 최대 1,000자리의 16진수 문자열을 곱하는 함수를 작성하세요.
   - Write a function that multiplies a single hexadecimal digit by a hexadecimal digit string as long as 1,000 digits. Return a hexadecimal string that represents the product.
   - Answer:
     ```python
     def multiply_hex_digit_and_string(digit_char: str, hex_str: str) -> str:
         hex_chars = "0123456789ABCDEF"
         def char_to_val(c: str) -> int:
             c = c.upper()
             return ord(c) - ord('0') if '0' <= c <= '9' else ord(c) - ord('A') + 10
         multiplier = char_to_val(digit_char)
         if multiplier == 0 or hex_str == "0":
             return "0"
         carry = 0
         result = []
         for i in range(len(hex_str) - 1, -1, -1):
             val = char_to_val(hex_str[i])
             prod = val * multiplier + carry
             carry = prod // 16
             result.append(hex_chars[prod % 16])
         if carry > 0:
             result.append(hex_chars[carry])
         result.reverse()
         return "".join(result)
     ```

8. 주어진 연산을 포함하는 Java 프로그램을 작성하고, `javap -c` 명령으로 디스어셈블하여 각 줄에 주석을 달아 해석하세요.
   - Write a Java program that contains the calculation shown below. Then, use the javap –c command to disassemble your code. Add comments to each line that provide your best guess as to its purpose.
   - Answer:
     ```bytecode
     public static void main(java.lang.String[]);
       Code:
          0: iconst_5        // 정수 상수 5를 스택에 푸시 (Y의 값)
          1: istore_1        // 스택Top 값(5)을 로컬 변수 1(Y)에 저장
          2: iload_1         // 로컬 변수 1(Y)의 값(5)을 스택에 로드
          3: iconst_4        // 정수 상수 4를 스택에 푸시
          4: iadd            // Y와 4를 더함 (결과: 9)
          5: iconst_3        // 정수 상수 3을 스택에 푸시
          6: imul            // 9와 3을 곱함 (결과: 27)
          7: istore_2        // 최종 결과(27)를 로컬 변수 2(X)에 저장
          8: return          // 메소드 종료 및 리턴
     ```

9. 부호 없는 이진수의 뺄셈 기법을 고안하고 테스트 케이스를 통해 검증하세요.
   - Devise a way of subtracting unsigned binary integers. Test your technique by subtracting binary 00000101 from binary 10001000, producing 10000011. Test your technique with at least two other sets of integers, in which a smaller value is always subtracted from a larger one.
   - Answer:
     - **기법:** 빼는 수(B)의 2의 보수(1의 보수 + 1)를 구한 뒤 피감수(A)에 더하고, 발생한 최상위 캐리(Carry Out)를 버립니다.
     - **구현 코드 (Python):**
       ```python
       def subtract_unsigned_binary(bin1: str, bin2: str) -> str:
           # 1. 자릿수 맞추기 (Zero Padding)
           max_len = max(len(bin1), len(bin2))
           bin1 = bin1.zfill(max_len)
           bin2 = bin2.zfill(max_len)
           
           # 2. 빼는 수(bin2)의 1의 보수(비트 반전) 구하기
           ones_complement = "".join('1' if c == '0' else '0' for c in bin2)
           
           # 3. 1의 보수에 1을 더해 2의 보수 만들기
           twos_complement = []
           carry = 1
           for i in range(max_len - 1, -1, -1):
               digit = ord(ones_complement[i]) - ord('0')
               total = digit + carry
               twos_complement.append(str(total % 2))
               carry = total // 2
           twos_complement.reverse()
           twos_comp_str = "".join(twos_complement)
           
           # 4. 피감수(bin1)와 2의 보수를 더하기
           result = []
           carry = 0
           for i in range(max_len - 1, -1, -1):
               d1 = ord(bin1[i]) - ord('0')
               d2 = ord(twos_comp_str[i]) - ord('0')
               total = d1 + d2 + carry
               result.append(str(total % 2))
               carry = total // 2
           
           # 5. 최상위 캐리(Carry Out) 버리기
           result.reverse()
           return "".join(result)

       # 테스트 실행
       print(subtract_unsigned_binary("10001000", "00000101")) # 출력: "10000011" (136 - 5 = 131)
       print(subtract_unsigned_binary("00110000", "00001100")) # 출력: "00100100" (48 - 12 = 36)
       print(subtract_unsigned_binary("11111111", "01111111")) # 출력: "10000000" (255 - 127 = 128)
       ```