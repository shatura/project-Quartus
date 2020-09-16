LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 
ENTITY Program_Counter IS --������� ������
	PORT (	clk : IN std_logic; 
			clk_enable : IN std_logic; 
			reset : IN std_logic; 
			func : IN std_logic_vector(1 DOWNTO 0); 		-- ������� ������ ������ ����������������
			addr_in : IN std_logic_vector(7 DOWNTO 0); 		-- ������� ������ ������ ���������� 
			addr_out : OUT std_logic_vector(7 DOWNTO 0));	-- �������� ������ �� ���� �������
	END Program_Counter;
ARCHITECTURE fsm_SFHDL OF Program_Counter IS 
		SIGNAL PC_value : unsigned(7 DOWNTO 0); 			--��������� �������� �������������
		SIGNAL PC_value_next : unsigned(7 DOWNTO 0); 		--���� ���� ����
	BEGIN
	initialize_Program_Counter : PROCESS (reset, clk)		--������������� ���������� ���������  ������ � �������������
	--��������� ����������
	BEGIN
		IF reset = '1' THEN
			PC_value <= to_unsigned(0, 8);
		ELSIF clk'EVENT AND clk= '1' THEN 
			IF clk_enable= '1' THEN 
				PC_value <= PC_value_next; 
			END IF; 
		END IF;
	END PROCESS initialize_Program_Counter;					 
	
	Program_Counter : PROCESS (PC_value, func, addr_in)		--������������� ������� ���� ��������� ��������, ������� � ������
	--��������� ����������
			VARIABLE ain : unsigned(15 DOWNTO 0);
			VARIABLE ain_0 : unsigned(15 DOWNTO 0);
		BEGIN
			PC_value_next <= PC_value;
			-- Program Counter 
			-- func = 0 => reset PC 
			-- func = 1 => load PC 
			-- func = 2 => increment PC
			addr_out <= std_logic_vector(PC_value);
			CASE func IS
				WHEN "00" =>
				--����������
					PC_value_next <= to_unsigned(0, 8);
				WHEN "01" =>
				-- ���� �������� 
					PC_value_next <= unsigned(addr_in);
				WHEN "10" =>
				--���������-��������
					ain := resize(PC_value & '0' & '0' & '0' & '0' & '0' & '0' & '0', 16);
					ain_0 := ain + 128;
			IF (ain_0(15) /= '0') OR (ain_0(14 DOWNTO 7) = "11111111") THEN
					PC_value_next <= "11111111";
				ELSE
					PC_value_next <= ain_0(14 DOWNTO 7) + ("0" & (ain_0(6)));
				
				END IF; 
			WHEN OTHERS => NULL; 
		END CASE; 
	END PROCESS Program_Counter; 
END fsm_SFHDL;