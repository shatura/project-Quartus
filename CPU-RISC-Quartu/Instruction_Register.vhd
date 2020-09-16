LIBRARY ieee;
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all;

	ENTITY Instruction_Register IS --������� ������
		PORT (	clk : IN std_logic; 
				clk_enable : IN std_logic; 
				reset : IN std_logic; 
				func : IN std_logic_vector(1 DOWNTO 0); 
				IR_in : IN std_logic_vector(15 DOWNTO 0); 
				IR_out : OUT std_logic_vector(15 DOWNTO 0)); 
		END Instruction_Register;
		
	ARCHITECTURE fsm_SFHDL OF Instruction_Register IS
		SIGNAL IR_value : unsigned(15 DOWNTO 0); 
		SIGNAL IR_value_next : unsigned(15 DOWNTO 0);
	BEGIN
		initialize_Instruction_Register : PROCESS (reset, clk) 
		--��������� ���������� 
		BEGIN
			IF reset = '1' THEN
				IR_value <= to_unsigned(0, 16);
				ELSIF clk'EVENT AND clk= '1' THEN
					IF clk_enable= '1' THEN
						IR_value <= IR_value_next;
				END IF; 
			END IF;
		END PROCESS initialize_Instruction_Register;
		
		Instruction_Register : PROCESS (IR_value, func, IR_in)
		--����� ����
		BEGIN
		IR_value_next <= IR_value;
		-- A 16-bit Instruction Register (IR) ����������� �������: 
		-- func == 0 => reset 
		-- func == 1 => store into IR 
		-- func == 2 => read from IR; 
		-- otherwise, preserve old value and return 0 
		IR_out <= std_logic_vector(to_unsigned(0, 16)); 
		CASE func IS 
		WHEN "00" =>
		--������������
		IR_value_next <= to_unsigned(0, 16); 
		WHEN "01" => 
		-- ����������
		IR_value_next <= unsigned(IR_in); 
		WHEN "10" => 
		--  ������ 
		IR_out <= std_logic_vector(IR_value); 
		WHEN OTHERS => NULL; 
		END CASE; 
	END PROCESS Instruction_Register; 
END fsm_SFHDL;