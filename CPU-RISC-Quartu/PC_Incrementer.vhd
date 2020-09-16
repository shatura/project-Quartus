LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 
ENTITY PC_Incrementer 
IS PORT --инициализация портов
( clk : IN std_logic; 
	clk_enable : IN std_logic; 
	reset : IN std_logic; 
	func : IN std_logic_vector(1 DOWNTO 0); 
	addr : IN std_logic_vector(7 DOWNTO 0); 
	PC_curr : IN std_logic_vector(7 DOWNTO 0); 
	PC_next : OUT std_logic_vector(7 DOWNTO 0); 
	Temp : OUT std_logic_vector(7 DOWNTO 0)); 
END PC_Incrementer; 
		--архитектура пропись
ARCHITECTURE fsm_SFHDL OF PC_Incrementer IS 
	SIGNAL PC_Temp : unsigned(7 DOWNTO 0); 
	SIGNAL PC_Temp_next : unsigned(7 DOWNTO 0);
	BEGIN 
initialize_PC_Incrementer : PROCESS (reset, clk) --процессы спроса и синхросигнала
		-- локальные переменные
BEGIN 
	IF reset = '1' THEN 
		PC_Temp <= to_unsigned(0, 8); 
	ELSIF clk'EVENT AND clk= '1' THEN 
		IF clk_enable= '1' THEN 
			PC_Temp <= PC_Temp_next; 
		END IF; 
	END IF; 	
END PROCESS initialize_PC_Incrementer; 

PC_Incrementer : PROCESS (PC_Temp, func, addr, PC_curr) --процессы функций
		-- локальные переменные
	VARIABLE PC_Temp_temp : unsigned(7 DOWNTO 0); 
BEGIN PC_Temp_temp := PC_Temp; 
	-- func = 0 => reset PC_Inc 
	-- func = 1 => store into PC_Inc when JMP, JMPZ, CALL 
	-- func = 2 => load from PC_Inc when RET 
	PC_next <= PC_curr; 
	Temp <= std_logic_vector(to_unsigned(0, 8)); 
CASE func IS 
WHEN "00" => 
	-- перезагрузка вх данных
	PC_next <= std_logic_vector(to_unsigned(0, 8)); 
WHEN "01" => 
	-- хранение PC_Inc when JMP, JMPZ, CALL 
	PC_next <= addr; 
	PC_Temp_temp := unsigned(PC_curr); 
	Temp <= std_logic_vector(PC_Temp_temp); 
WHEN "10" => 
	-- закрузка PC_Inc when RET 
PC_next <= std_logic_vector(PC_Temp); 
WHEN OTHERS => 
	NULL;
	END CASE; PC_Temp_next <= PC_Temp_temp; 
	END PROCESS PC_Incrementer; 
	END fsm_SFHDL;