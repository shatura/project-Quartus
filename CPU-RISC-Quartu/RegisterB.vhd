LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all;

ENTITY RegisterB IS 
PORT ( 
	clk : IN std_logic; 
	clk_enable : IN std_logic; 
	reset : IN std_logic; 
	func : IN std_logic_vector(2 DOWNTO 0); 
	Reg_in_B_1 : IN std_logic_vector(7 DOWNTO 0); 
	Reg_in_B_2 : IN std_logic_vector(7 DOWNTO 0); 
	Reg_out_B : OUT std_logic_vector(7 DOWNTO 0)); 
END RegisterB;

ARCHITECTURE fsm_SFHDL OF RegisterB IS

	SIGNAL Reg_value : unsigned(7 DOWNTO 0); 
	SIGNAL Reg_value_next : unsigned(7 DOWNTO 0);
	
BEGIN

	initialize_RegisterB : PROCESS (reset, clk)
	BEGIN
		IF reset = '1' THEN 
			Reg_value <= to_unsigned(0, 8); 
		ELSIF clk'EVENT AND clk= '1' THEN 
			IF clk_enable= '1' THEN 
				Reg_value <= Reg_value_next; 
			END IF; 
		END IF; 
	END PROCESS initialize_RegisterB;
	
	RegisterB : PROCESS (Reg_value, func, Reg_in_B_1, Reg_in_B_2)

	BEGIN
		Reg_value_next <= Reg_value;
			-- func == 0 => reset; 
			-- func == 1 => store into RegisterA from port 1; 
			-- func == 2 => store into RegisterA from port 2; 
			-- func == 3 => read from RegisterA;
		Reg_out_B <= std_logic_vector(Reg_value);
		CASE func IS
			WHEN "000" =>
			--  перезапуск
			Reg_value_next <= to_unsigned(0, 8); 
			WHEN "001" => 
			-- сох дан Reg_B пр1 
			Reg_value_next <= unsigned(Reg_in_B_1); 
			WHEN "010" => 
			-- сох дан Reg_B пр2 
			Reg_value_next <= unsigned(Reg_in_B_2); 
			WHEN "011" => 
			-- чтение Reg_B 
			Reg_out_B <= std_logic_vector(Reg_value); 
		WHEN OTHERS => 
	NULL;
END CASE; 
END PROCESS RegisterB; 
END fsm_SFHDL;