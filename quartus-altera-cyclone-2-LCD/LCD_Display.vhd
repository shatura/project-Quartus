LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY LCD_Display IS
--
	PORT( clk_25Mhz			: IN	STD_LOGIC:='0';
		 data_to_print			: IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
		 lcd_rs, lcd_e				: OUT	STD_LOGIC;
		 data_to_lcd				: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		 char_num					: OUT 	STD_LOGIC_VECTOR(4 DOWNTO 0)
		);
		
END ENTITY LCD_Display;

ARCHITECTURE rtl OF LCD_Display IS

TYPE STATE_TYPE IS 
( init,  setting, DISPLAY_ON, MODE_SET, Print_String,
LINE2, RETURN_HOME, DROP_lcd_e, delay, DISPLAY_OFF, DISPLAY_CLEAR);

SIGNAL state, next_command: STATE_TYPE;
SIGNAL data_to_lcd_VALUE, Next_Char: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL clk_cnt: STD_LOGIC_VECTOR(19 DOWNTO 0);
SIGNAL char_cnt: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL clk_cnt_ena : STD_LOGIC;
BEGIN

	char_num<=char_cnt;
	data_to_lcd <= data_to_lcd_VALUE;
	Next_Char <= data_to_print;
	
PROCESS(clk_25Mhz)
	BEGIN
	 If clk_25Mhz'EVENT AND clk_25Mhz = '1' then 
			IF clk_cnt < X"0EA60" THEN 
			 clk_cnt <= clk_cnt + 1;
			 clk_cnt_ena <= '0';
			ELSE
			 clk_cnt <= X"00000";
			 clk_cnt_ena <= '1';
			END IF;
	END IF;
END PROCESS;

PROCESS (clk_25Mhz)
	BEGIN
	IF clk_25Mhz'EVENT AND clk_25Mhz = '1' THEN
-- State Machine to send commands and data to LCD DISPLAY			
		  IF clk_cnt_ena = '1' THEN
			CASE state IS
				WHEN init =>
						lcd_e <= '1';
						lcd_rs <= '0';
						data_to_lcd_VALUE <= X"38";
						state <= DROP_lcd_e;
						next_command <= delay;
				WHEN delay =>
						lcd_e <= '1';
						lcd_rs <= '0';
						data_to_lcd_VALUE <= X"38";
						state <= DROP_lcd_e;
						next_command <= setting;
-- EXTRA STATES ABOVE ARE NEEDED FOR RELIABLE PUSHBUTTON RESET OF LCD
				WHEN setting =>
						lcd_e <= '1';
						lcd_rs <= '0';
						data_to_lcd_VALUE <= X"38";
						state <= DROP_lcd_e;
						next_command <= DISPLAY_OFF;
-- Turn off Display and Turn off cursor
				WHEN DISPLAY_OFF =>
						lcd_e <= '1';
						lcd_rs <= '0';
						data_to_lcd_VALUE <= X"08";
						state <= DROP_lcd_e;
						next_command <= DISPLAY_CLEAR;
-- Clear Display and Turn off cursor
				WHEN DISPLAY_CLEAR =>
						lcd_e <= '1';
						lcd_rs <= '0';
						data_to_lcd_VALUE <= X"01";
						state <= DROP_lcd_e;
						next_command <= DISPLAY_ON;
-- Turn on Display and Turn off cursor
				WHEN DISPLAY_ON =>
						lcd_e <= '1';
						lcd_rs <= '0';
						
						data_to_lcd_VALUE <= X"0C";
						state <= DROP_lcd_e;
						next_command <= MODE_SET;
-- Set write mode to auto increment address and move cursor to the right
				WHEN MODE_SET =>
						lcd_e <= '1';
						lcd_rs <= '0';
						
						data_to_lcd_VALUE <= X"06";
						state <= DROP_lcd_e;
						next_command <= Print_String;
-- Write ASCII hex character in first LCD character location
				WHEN Print_String =>
						state <= DROP_lcd_e;
						lcd_e <= '1';
						lcd_rs <= '1';
						
-- ASCII character to output
						IF Next_Char(7 DOWNTO  4) /= X"0" THEN
						data_to_lcd_VALUE <= Next_Char;
						ELSE
-- Convert 4-bit value to an ASCII hex digit
							IF Next_Char(3 DOWNTO 0) >9 THEN
-- ASCII A...F
							 data_to_lcd_VALUE <= X"4" & (Next_Char(3 DOWNTO 0)-9);
							ELSE
-- ASCII 0...9
							 data_to_lcd_VALUE <= X"3" & Next_Char(3 DOWNTO 0);
							END IF;
						END IF;
						state <= DROP_lcd_e;
-- Loop to send out 32 characters to LCD Display  (16 by 2 lines)
						IF (char_cnt < 31) AND (Next_Char /= X"FE") THEN 
						 char_cnt <= char_cnt +1;
						ELSE 
						 char_cnt <= "00000"; 
						END IF;
-- Jump to second line?
						IF char_cnt = 15 THEN next_command <= line2;
-- Return to first line?
						ELSIF (char_cnt = 31) OR (Next_Char = X"FE") THEN 
						 next_command <= return_home; 
						ELSE next_command <= Print_String; END IF;
-- Set write address to line 2 character 1
				WHEN LINE2 =>
						lcd_e <= '1';
						lcd_rs <= '0';
						
						data_to_lcd_VALUE <= X"C0";
						state <= DROP_lcd_e;
						next_command <= Print_String;
-- Return write address to first character postion on line 1
				WHEN RETURN_HOME =>
						lcd_e <= '1';
						lcd_rs <= '0';
						
						data_to_lcd_VALUE <= X"80";
						state <= DROP_lcd_e;
						next_command <= Print_String;
-- The next three states occur at the end of each command or data transfer to the LCD
-- Drop LCD E line - falling edge loads inst/data to LCD controller
				WHEN DROP_lcd_e =>
						lcd_e <= '0';
						state <= next_command;
			END CASE;
		  END IF;
		END IF;
	END PROCESS;
END rtl;
