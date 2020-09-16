LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 								-- подключение математических библиотек 
ENTITY CPU_Controller IS 								-- инициализация устройства
	PORT 												-- инициализация портов
		( clk : IN std_logic;							-- порт синхронного сигнала
		clk_enable : IN std_logic; 						-- порт синхсигнала разрешающего
		reset : IN std_logic; 							-- порт перезагрузки
		master_rst : IN std_logic; 						-- порт разрешение перезагрузки
		IR_in : IN std_logic_vector(15 DOWNTO 0); 		-- входные данные  
		Reg_A : IN std_logic_vector(7 DOWNTO 0); 		-- входные данные из регистра А
		ALU_func : OUT std_logic_vector(3 DOWNTO 0); 	-- выходные данные по выбранному действию 
		IR_func : OUT std_logic_vector(1 DOWNTO 0); 	-- выходные данные
		PC_inc_func : OUT std_logic_vector(1 DOWNTO 0); -- выходной сигнал упраления счета
		PC_func : OUT std_logic_vector(1 DOWNTO 0);		-- упр сигнал счетчика фун
		addr_inc : OUT std_logic_vector(7 DOWNTO 0); 	-- инициализация обращения к адресу
		IM_read : OUT std_logic; 						-- выходной порт разрештя чтения с памятью 
		RegA_func : OUT std_logic_vector(2 DOWNTO 0); 	-- выходной сигнал подачи функции на рег А
		RegB_func : OUT std_logic_vector(2 DOWNTO 0); 	-- выходной сигнал подачи функции на рег В
		Reg_OutA : OUT std_logic_vector(7 DOWNTO 0); 	-- выходной сигнал на рег А
		Reg_OutB : OUT std_logic_vector(7 DOWNTO 0)); 	-- выходной сигнал на рег В
	END CPU_Controller;
	
	ARCHITECTURE fsm_SFHDL OF CPU_Controller IS			-- описание архетектуры 
	
		SIGNAL CPU_state : unsigned(7 DOWNTO 0); 		-- первый такт
		SIGNAL major_opcode : unsigned(3 DOWNTO 0); 	-- круаный сигнал
		SIGNAL main_opcode : unsigned(15 DOWNTO 0); 	-- основной код операции
		SIGNAL minor_opcode : unsigned(3 DOWNTO 0); 	-- мелкий сигнал
		SIGNAL address_data : unsigned(7 DOWNTO 0); 	-- сигнал адреса
		SIGNAL CPU_state_next : unsigned(7 DOWNTO 0); 	-- второй такт
		SIGNAL major_opcode_next : unsigned(3 DOWNTO 0); 
		SIGNAL main_opcode_next : unsigned(15 DOWNTO 0); 
		SIGNAL minor_opcode_next : unsigned(3 DOWNTO 0); 
		SIGNAL address_data_next : unsigned(7 DOWNTO 0);
	BEGIN 												-- начало
		initialize_CPU_Controller : PROCESS (reset, clk)-- инициал процессов 
														-- локальные переменные 
		BEGIN IF reset = '1' THEN 						-- когда пришел сигнал на перезагрузку "1" , тогда сигналы сбросить
		CPU_state <= to_unsigned(0, 8); 
		main_opcode <= to_unsigned(0, 16); 
		major_opcode <= to_unsigned(0, 4);
		minor_opcode <= to_unsigned(0, 4); 
		address_data <= to_unsigned(0, 8);
		ELSIF clk'EVENT AND clk= '1' THEN 				-- если синхросигнал равен "1", то выполнить операцию от первого такста до второго
			IF clk_enable= '1' THEN 
				CPU_state <= CPU_state_next; 
				major_opcode <= major_opcode_next; 
				main_opcode <= main_opcode_next; 
				minor_opcode <= minor_opcode_next; 
				address_data <= address_data_next; 
			END IF; 
		END IF; 
	END PROCESS initialize_CPU_Controller;				-- закончить инициализацию 
	
	CPU_Controller : PROCESS (CPU_state, major_opcode, 	-- инициализация процессов
	main_opcode, minor_opcode, 
	address_data, master_rst, IR_in, Reg_A)
														-- локальные переменные 
		VARIABLE c_uint : unsigned(15 DOWNTO 0); 		-- переменные 
		VARIABLE b_c_uint : unsigned(3 DOWNTO 0); 
		VARIABLE cr : unsigned(15 DOWNTO 0); 
		VARIABLE CPU_state_temp : unsigned(7 DOWNTO 0); 
		VARIABLE major_opcode_temp : unsigned(3 DOWNTO 0); 
		VARIABLE main_opcode_temp : unsigned(15 DOWNTO 0); 
		VARIABLE reg_a_0 : unsigned(7 DOWNTO 0); 
	BEGIN 												-- начало присваивания 
		minor_opcode_next <= minor_opcode; 
		address_data_next <= address_data; 
		CPU_state_temp := CPU_state; 
		major_opcode_temp := major_opcode; 
		main_opcode_temp := main_opcode; 
	-- CPU Controller 
	-- 16-bit соответствие кодировки:
	-- -------------minor_opcode--------- 
	-- NOP: 00000 000 <00000000> 
	-- JMP: 00000 001 <8-bit> 
	-- JMPZ: 00000 010 <8-bit> 
	-- CALL: 00000 011 <8-bit>
	-- MOV A,xx: 00000 100 <8-bit> 
	-- MOV B,xx: 00000 101 <8-bit> 
	-- RET: 00000 110 <00000000> 
	-- --------------------------------------- 
	-- MOV A,B: 00000 110 <00000001> 
	-- MOV B,A: 00000 110 <00000010> 
	-- XCHG A,B: 00000 110 <00000011> 
	-- ADD A,B: 00000 110 <00000100> 
	-- SUB A,B: 00000 110 <00000101> 
	-- AND A,B: 00000 110 <00000110> 
	-- OR A,B: 00000 110 <00000111> 
	-- XOR A,B: 00000 110 <00001000> 
	-- DEC A: 00000 110 <00001001>	
	IF master_rst /= '0' THEN 							-- если разр сброса  = 0, то
		CPU_state_temp := to_unsigned(0, 8); 			-- то запустить основной сигнал
	END IF;
		PC_inc_func <= std_logic_vector(to_unsigned(0, 2)); 
		IR_func <= std_logic_vector(to_unsigned(3, 2)); 
		PC_func <= std_logic_vector(to_unsigned(3, 2)); 
		IM_read <= '0'; 
		addr_inc <= std_logic_vector(to_unsigned(0, 8)); 
		Reg_OutA <= std_logic_vector(to_unsigned(0, 8)); 
		Reg_OutB <= std_logic_vector(to_unsigned(0, 8)); 
		RegA_func <= std_logic_vector(to_unsigned(4, 3)); 
		RegB_func <= std_logic_vector(to_unsigned(4, 3)); 
		ALU_func <= std_logic_vector(to_unsigned(9, 4));
	-- NOP -- main_code: <16..1> 
	-- major_opcode: <16..9> 
	-- minor_opcode: <12..9> 
	-- address_data: <8..1> 
	CASE CPU_state_temp IS								-- оператор выбора 
	WHEN "00000000" => 
	--------------------------------------	 
		-- результат первичного присваивания
	--------------------------------------	 
	PC_inc_func <= std_logic_vector(to_unsigned(0, 2));
	PC_func <= std_logic_vector(to_unsigned(0, 2)); 
	IR_func <= std_logic_vector(to_unsigned(0, 2)); 
	RegA_func <= std_logic_vector(to_unsigned(0, 3)); 
	RegB_func <= std_logic_vector(to_unsigned(0, 3)); 
	CPU_state_temp := to_unsigned(1, 8); 
	--------------------------------------
		-- далее 
	--------------------------------------	
	WHEN "00000001" => 
		 
		IM_read <= '1'; 								-- читать IM (ROM)
		 PC_func <= std_logic_vector(to_unsigned(2, 2));-- PC увеличения значения для счета 
		IR_func <= std_logic_vector(to_unsigned(1, 2)); -- функция хранения передачи в IR(в передатчик данных) 
		CPU_state_temp := to_unsigned(2, 8);
	WHEN "00000010" => 
		IR_func <= std_logic_vector(to_unsigned(2, 2));-- читать в передатчик данных
		CPU_state_temp := to_unsigned(3, 8); 		   -- задержка для передачи данных
	WHEN "00000011" =>
		main_opcode_temp := unsigned(IR_in); 		   -- передатчик данных полн
		cr := main_opcode_temp srl 8; 				   -- передатчик данных половина
	IF cr(15 DOWNTO 4) /= "000000000000" THEN 
		major_opcode_temp := "1111"; 
	ELSE 
		major_opcode_temp := cr(3 DOWNTO 0); 
	END IF;
					-- для инструкций NOP,JMP,JMPZ,CALL,MOV A,xx MOV B,xx,RET
		-- IR_in <12..9> 
		b_c_uint := major_opcode_temp AND to_unsigned(15, 4);
		minor_opcode_next <= b_c_uint; 
		-- IR_in <8..1> 
		c_uint := main_opcode_temp AND to_unsigned(255, 16);
	IF c_uint(15 DOWNTO 8) /= "00000000" THEN 
		address_data_next <= "11111111"; 
	ELSE 
		address_data_next <= c_uint(7 DOWNTO 0); 
	END IF; 
		-- Перейти к стадии декодирования
	CPU_state_temp := to_unsigned(4, 8);
	--------------------------------------
	--выполнить и декодировать
	--------------------------------------
	WHEN "00000100" => 
		CASE minor_opcode IS
			WHEN "0000" => 
				-- NOP задержка
				CPU_state_temp := to_unsigned(1, 8); 
			WHEN "0001" => 
				-- JMP переход по адресу
				addr_inc <= std_logic_vector(address_data); 
				PC_inc_func <= std_logic_vector(to_unsigned(1, 2)); 
				PC_func <= std_logic_vector(to_unsigned(1, 2)); 
				CPU_state_temp := to_unsigned(1, 8); 
			WHEN "0010" =>
				--JMPZ переход по адресу заданный младшим байтом
			reg_a_0 := unsigned(Reg_A); 
			IF reg_a_0 = 0 THEN 
				addr_inc <= std_logic_vector(address_data); 
				PC_inc_func <= std_logic_vector(to_unsigned(1, 2)); 
				PC_func <= std_logic_vector(to_unsigned(1, 2)); 
			END IF; 
			CPU_state_temp := to_unsigned(1, 8); 
		WHEN "0011" => 
				-- CALL вызвать функцию
			addr_inc <= std_logic_vector(address_data); 
			PC_inc_func <= std_logic_vector(to_unsigned(1, 2));
			 PC_func <= std_logic_vector(to_unsigned(1, 2));
			  CPU_state_temp := to_unsigned(1, 8); 
		WHEN "0100" =>
				--MOV A,xx  внести
			Reg_OutA <= std_logic_vector(address_data); 
			RegA_func <= std_logic_vector(to_unsigned(1, 3)); 
			CPU_state_temp := to_unsigned(1, 8); 
		WHEN "0101" => 
				--MOV B,xx  внести
			Reg_OutB <= std_logic_vector(address_data); 
			RegB_func <= std_logic_vector(to_unsigned(1, 3)); 
			CPU_state_temp := to_unsigned(1, 8); 
		WHEN "0110" =>
			CASE address_data IS 
				WHEN "00000000" => 
					--RET возврат ближайшей процедуры
				PC_inc_func <= std_logic_vector(to_unsigned(2, 2));
					PC_func <= std_logic_vector(to_unsigned(2, 2)); 
					CPU_state_temp := to_unsigned(5, 8);
				WHEN "00000001" =>
					--MOV A,B копировать 
					ALU_func <= std_logic_vector(to_unsigned(0, 4)); 
					RegA_func <= std_logic_vector(to_unsigned(2, 3)); 
					RegB_func <= std_logic_vector(to_unsigned(2, 3)); 
					CPU_state_temp := to_unsigned(5, 8);
				WHEN "00000010" =>
					--MOV B,A копировать
					ALU_func <= std_logic_vector(to_unsigned(1, 4)); 
					RegA_func <= std_logic_vector(to_unsigned(2, 3));
					 RegB_func <= std_logic_vector(to_unsigned(2, 3)); 
					CPU_state_temp := to_unsigned(5, 8);
				WHEN "00000011" =>
					--XCHG A,B команда перессылки данных
					ALU_func <= std_logic_vector(to_unsigned(2, 4)); 
					RegA_func <= std_logic_vector(to_unsigned(2, 3)); 
					RegB_func <= std_logic_vector(to_unsigned(2, 3)); 
					CPU_state_temp := to_unsigned(5, 8);
				WHEN "00000100" =>
					--ADD A,B сложение
					ALU_func <= std_logic_vector(to_unsigned(3, 4));
					RegA_func <= std_logic_vector(to_unsigned(2, 3)); 
					RegB_func <= std_logic_vector(to_unsigned(2, 3)); 
					CPU_state_temp := to_unsigned(5, 8); 
				WHEN "00000101" => 
					--SUB A,B вычитание
					ALU_func <= std_logic_vector(to_unsigned(4, 4));
					RegA_func <= std_logic_vector(to_unsigned(2, 3)); 
					RegB_func <= std_logic_vector(to_unsigned(2, 3)); 
					CPU_state_temp := to_unsigned(5, 8); 
				WHEN "00000110" => 
					--AND A,B лог И
					ALU_func <= std_logic_vector(to_unsigned(5, 4)); 
					RegA_func <= std_logic_vector(to_unsigned(2, 3)); 
					RegB_func <= std_logic_vector(to_unsigned(2, 3)); 
					CPU_state_temp := to_unsigned(5, 8); 
				WHEN "00000111" => 
					--OR A,B лог ИЛИ
					ALU_func <= std_logic_vector(to_unsigned(6, 4)); 
					RegA_func <= std_logic_vector(to_unsigned(2, 3)); 
					RegB_func <= std_logic_vector(to_unsigned(2, 3)); 
					CPU_state_temp := to_unsigned(5, 8); 
				WHEN "00001000" => 
					--XOR A,B 
					ALU_func <= std_logic_vector(to_unsigned(7, 4)); 
					RegA_func <= std_logic_vector(to_unsigned(2, 3)); 
					RegB_func <= std_logic_vector(to_unsigned(2, 3)); 
					CPU_state_temp := to_unsigned(5, 8); 
				WHEN "00001001" => 
					--DEC A декремент
					ALU_func <= std_logic_vector(to_unsigned(8, 4)); 
					RegA_func <= std_logic_vector(to_unsigned(2, 3)); 
					CPU_state_temp := to_unsigned(5, 8); 
				WHEN OTHERS => 
			NULL; 
		END CASE; 
		WHEN OTHERS => 
		NULL;
		END CASE; 
		WHEN "00000101" => 
					RegA_func <= std_logic_vector(to_unsigned(2, 3)); 
					RegB_func <= std_logic_vector(to_unsigned(2, 3)); 
					CPU_state_temp := to_unsigned(1, 8); 
				WHEN OTHERS => 
					NULL; 
		END CASE; 
		CPU_state_next <= CPU_state_temp; 
		major_opcode_next <= major_opcode_temp; 
		main_opcode_next <= main_opcode_temp; 
	END PROCESS CPU_Controller; 
END fsm_SFHDL;