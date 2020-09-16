LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 
ENTITY ALU IS 
PORT ( 
clk : IN std_logic; 
clk_enable : IN std_logic; 
reset : IN std_logic; 
func : IN std_logic_vector(3 DOWNTO 0); 
inA : IN std_logic_vector(7 DOWNTO 0); 
inB : IN std_logic_vector(7 DOWNTO 0); 
outA : OUT std_logic_vector(7 DOWNTO 0); 
outB : OUT std_logic_vector(7 DOWNTO 0)); 
END ALU;

ARCHITECTURE fsm_SFHDL OF ALU IS
--запуск команды считывания (расшифровки)
FUNCTION tmw_to_signed(arg: unsigned; width: integer) RETURN signed 
IS
BEGIN
	IF arg(arg'right) = 'U' OR arg(arg'right) = 'X' THEN
		RETURN to_signed(1, width);
	END IF;
	RETURN to_signed(to_integer(arg), width);
END FUNCTION;

--запус команды зашифровки
FUNCTION tmw_to_unsigned(arg: signed; width: integer) RETURN unsigned
IS
CONSTANT ARG_LEFT: INTEGER := ARG'LENGTH-1; 
ALIAS XARG: SIGNED(ARG_LEFT downto 0) is ARG; 
VARIABLE result : unsigned(width-1 DOWNTO 0); 
VARIABLE argSize : integer; 
BEGIN 
IF XARG(XARG'high-1) = 'U' OR arg(arg'right) = 'X' THEN 
RETURN to_unsigned(1, width);

END IF;
IF (ARG_LEFT < width-1) THEN
result := (OTHERS => XARG(ARG_LEFT)); 
result(ARG_LEFT downto 0) := unsigned(XARG); 
ELSE 
result(width-1 downto 0) := unsigned(XARG(width-1 downto 0)); 
END IF; 
RETURN result; 
END FUNCTION;
BEGIN
ALU : PROCESS (func, inA, inB)
VARIABLE X_temp : unsigned(7 DOWNTO 0); 
VARIABLE ina_0 : unsigned(7 DOWNTO 0); 
VARIABLE ina_1 : signed(8 DOWNTO 0);
VARIABLE ina_2 : signed(8 DOWNTO 0);
BEGIN
-- MOV, XCHG, ADD, SUB, AND, OR, XOR, DEC 
-- func = 0 => MOV A,B 
-- func = 1 => MOV B,A 
-- func = 2 => XCHG A,B 
-- func = 3 => ADD A,B 
-- func = 4 => SUB A,B 
-- func = 5 => AND A,B 
-- func = 6 => OR A,B 
-- func = 7 => XOR A,B 
-- func = 8 => DEC A 

outA <= inA;
outB <= inB;

CASE func IS WHEN "0000" => 
--MOV A,B 
outA <= inB; 
WHEN "0001" => 
--MOV B,A 
outB <= inA; 
WHEN "0010" => 
--XCHG A,B
X_temp := unsigned(inB); 
outB <= inA; 
outA <= std_logic_vector(X_temp); 
WHEN "0011" => 
--ADD A,B 
ina_0 := unsigned(inA) + unsigned(inB); 
outA <= std_logic_vector(ina_0); 
WHEN "0100" => 
--SUB A,B 
ina_1 := tmw_to_signed(unsigned(inA), 9) - tmw_to_signed(unsigned(inB), 9); 
IF ina_1(8) = '1' THEN 
outA <= "00000000"; 
ELSE outA <= std_logic_vector(resize(unsigned(ina_1(7 DOWNTO 0)), 8));
END IF; 
WHEN "0101" => 
--AND A,B 
outA <= std_logic_vector(tmw_to_unsigned(tmw_to_signed(unsigned(inA), 32) AND tmw_to_signed(unsigned(inB), 32), 8)); 
WHEN "0110" => 
--OR A,B 
outA <= std_logic_vector(tmw_to_unsigned(tmw_to_signed(unsigned(inA), 32) OR tmw_to_signed(unsigned(inB), 32), 8)); 
WHEN "0111" => 
--XOR A,B 
outA <= std_logic_vector(tmw_to_unsigned(tmw_to_signed(unsigned(inA), 32) XOR tmw_to_signed(unsigned(inB), 32), 8)); 
WHEN "1000" => 
--DEC A 
ina_2 := tmw_to_signed(unsigned(inA), 9) - 1; 
IF ina_2(8) = '1' THEN 
outA <= "00000000"; 
ELSE 
outA <= std_logic_vector(resize(unsigned(ina_2(7 DOWNTO 0)), 8)); 
END IF; 
WHEN OTHERS => NULL; 
END CASE; 
END PROCESS ALU; 
END fsm_SFHDL;