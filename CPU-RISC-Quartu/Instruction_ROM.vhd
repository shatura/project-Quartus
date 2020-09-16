LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 
ENTITY Instruction_ROM IS -- постоянная память
	PORT ( 
			clk : IN std_logic; 
			clk_enable : IN std_logic;
			reset : IN std_logic; 
			addr : IN std_logic_vector(7 DOWNTO 0); 
			read : IN std_logic; 	
			instr_out : OUT std_logic_vector(15 DOWNTO 0));
		END Instruction_ROM;
		
	ARCHITECTURE fsm_SFHDL OF Instruction_ROM IS
	-- активация программы перевода ром данных в сигнал
	FUNCTION tmw_to_signed(arg: unsigned; width: integer) RETURN signed IS
		BEGIN
			IF arg(arg'right) = 'U' OR arg(arg'right) = 'X' THEN
				RETURN to_signed(1, width);
			END IF;
			RETURN to_signed(to_integer(arg), width);
		END FUNCTION;
	-- активация приема данных 
	TYPE T_UFIX_16_256 IS ARRAY (255 DOWNTO 0) of unsigned(15 DOWNTO 0);
				SIGNAL data : T_UFIX_16_256; 
				SIGNAL data_next : T_UFIX_16_256; 
		BEGIN
			initialize_Instruction_ROM : PROCESS (reset, clk)
			--локальные операторы
			VARIABLE b_0 : INTEGER; BEGIN 
			IF reset = '1' THEN 
				FOR b IN 0 TO 255 LOOP 
					data(b) <= to_unsigned(0, 16); 
				END LOOP;
			ELSIF clk'EVENT AND clk= '1' THEN
				IF clk_enable= '1' THEN
					FOR b_0 IN 0 TO 255 LOOP
						data(b_0) <= data_next(b_0);
					END LOOP;
				END IF;
			END IF;
		END PROCESS initialize_Instruction_ROM;
		Instruction_ROM : PROCESS (data, addr, read)
		--локальные переменные
		VARIABLE data_temp : T_UFIX_16_256;
		BEGIN 
			FOR b IN 0 TO 255 LOOP
			data_temp(b) := data(b);
		END LOOP;
		data_temp(0) := to_unsigned(1036, 16); --инициализация ячеек памяти
		data_temp(1) := to_unsigned(1303, 16); 
		data_temp(2) := to_unsigned(1540, 16); 
		data_temp(3) := to_unsigned(1545, 16); 
		data_temp(4) := to_unsigned(1358, 16); 
		data_temp(5) := to_unsigned(1539, 16); 
		data_temp(6) := to_unsigned(1541, 16); 
		data_temp(7) := to_unsigned(1545, 16); 
		data_temp(8) := to_unsigned(1542, 16); 
		data_temp(9) := to_unsigned(523, 16); 
		data_temp(10) := to_unsigned(263, 16); 
		data_temp(11) := to_unsigned(1037, 16); 
		data_temp(12) := to_unsigned(1397, 16); 
		data_temp(13) := to_unsigned(1543, 16); 
		data_temp(14) := to_unsigned(1539, 16); 
		data_temp(15) := to_unsigned(1544, 16); 
		data_temp(16) := to_unsigned(277, 16); 
		data_temp(17) := to_unsigned(1135, 16); 
		data_temp(18) := to_unsigned(1480, 16); 
		data_temp(19) := to_unsigned(1542, 16); 
		data_temp(20) := to_unsigned(1536, 16); 
		data_temp(21) := to_unsigned(785, 16); 
		data_temp(22) := to_unsigned(0, 16);
		IF read = '1' THEN
			instr_out <= std_logic_vector(data_temp(to_integer(tmw_to_signed(unsigned(addr) + 1, 32) - 1))); 
				ELSE
					instr_out <= std_logic_vector(to_unsigned(0, 16));
				END IF;
				FOR c IN 0 TO 255 LOOP
					data_next(c) <= data_temp(c);
				END LOOP; 
			END PROCESS Instruction_ROM; 
		END fsm_SFHDL;