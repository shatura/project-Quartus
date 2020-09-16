library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity gh_round_subs_logic is --предназначен	для	расчета	S	– преобразования (преобразование подстановки)

port (
		clk	: in std_logic;
		clken	: in std_logic;
		lps_arg		: in std_logic_vector(511 downto 0); 
		valid_out	: out std_logic := '0';
		after_s	: out std_logic_vector(511 downto 0)
		);
	end gh_round_subs_logic;
	
	--Создание типа данных типа матрицы 256х8:
	architecture arch of gh_round_subs_logic is
	type sbox_table_type is array (0 to 255) of std_logic_vector(7 downto 0);
	--Ввод значений подстановки:
	
	constant sbox_table	: sbox_table_type := (
x"FC", x"EE", x"DD", x"11", x"CF", x"6E", x"31", x"16", x"FB",
x"C4", x"FA", x"DA", x"23", x"C5", x"04", x"4D",
x"E9", x"77", x"F0", x"DB", x"93", x"2E", x"99", x"BA", x"17",
x"36", x"F1", x"BB", x"14", x"CD", x"5F", x"C1",
x"F9", x"18", x"65", x"5A", x"E2", x"5C", x"EF", x"21", x"81",
x"1C", x"3C", x"42", x"8B", x"01", x"8E", x"4F",
x"05", x"84", x"02", x"AE", x"E3", x"6A", x"8F", x"A0", x"06",
x"0B", x"ED", x"98", x"7F", x"D4", x"D3", x"1F",
x"EB", x"34", x"2C", x"51", x"EA", x"C8", x"48", x"AB", x"F2",
x"2A", x"68", x"A2", x"FD", x"3A", x"CE", x"CC",
x"B5", x"70", x"0E", x"56", x"08", x"0C", x"76", x"12", x"BF",
x"72", x"13", x"47", x"9C", x"B7", x"5D", x"87",
x"15", x"A1", x"96", x"29", x"10", x"7B", x"9A", x"C7", x"F3",
x"91", x"78", x"6F", x"9D", x"9E", x"B2", x"B1",
x"32", x"75", x"19", x"3D", x"FF", x"35", x"8A", x"7E", x"6D",
x"54", x"C6", x"80", x"C3", x"BD", x"0D", x"57",
x"DF", x"F5", x"24", x"A9", x"3E", x"A8", x"43", x"C9", x"D7",
x"79", x"D6", x"F6", x"7C", x"22", x"B9", x"03",
x"E0", x"0F", x"EC", x"DE", x"7A", x"94", x"B0", x"BC", x"DC",
x"E8", x"28", x"50", x"4E", x"33", x"0A", x"4A",
x"A7", x"97", x"60", x"73", x"1E", x"00", x"62", x"44", x"1A",
x"B8", x"38", x"82", x"64", x"9F", x"26", x"41",
x"AD", x"45", x"46", x"92", x"27", x"5E", x"55", x"2F", x"8C",
x"A3", x"A5", x"7D", x"69", x"D5", x"95", x"3B",
x"07", x"58", x"B3", x"40", x"86", x"AC", x"1D", x"F7", x"30",
x"37", x"6B", x"E4", x"88", x"D9", x"E7", x"89",
x"E1", x"1B", x"83", x"49", x"4C", x"3F", x"F8", x"FE", x"8D",
x"53", x"AA", x"90", x"CA", x"D8", x"85", x"61",
x"20", x"71", x"67", x"A4", x"2D", x"2B", x"09", x"5B", x"CB",
x"9B", x"25", x"D0", x"BE", x"E5", x"6C", x"52",
x"59", x"A6", x"74", x"D2", x"E6", x"F4", x"B4", x"C0", x"D1",
x"66", x"AF", x"C2", x"39", x"4B", x"63", x"B6"
);

--Создание типа данных типа матрицы 64х8, 64х1:

type mass_64x7_type is array (0 to 63) of std_logic_vector(7 downto 0);
signal data_in_int : mass_64x7_type; signal data_out_ff : mass_64x7_type;
type mass_64x1_type is array (0 to 63) of std_logic; 
signal valid_i : mass_64x1_type := (others => '0');

--Осуществляется переписывание байтов из входного массива в байты
--двумерной	матрицы	для	того,	чтобы	входной	массив	512	разрядов обрабатывать побайтово:
begin
fill_inputs_cycle_j: for in_j in 0 to 63 generate data_in_int(in_j)	<= lps_arg((7+in_j*8) downto in_j*8);
end generate fill_inputs_cycle_j;
--Осуществляется переписывание данных побайтово из матрицы в выходной массив для того, 
--чтобы сформировать из двумерной матрицы данных входной 512-разрядный массив

fill_outputs_cycle_j: for in_j in 0 to 63 generate after_s((7+in_j*8) downto in_j*8) <= data_out_ff(in_j);
end generate fill_outputs_cycle_j;
--Заданный выходной признак валидности равен 1 при условии, что все промежуточные признаки валидности равны 1
valid_out <= '1' when valid_i(0 to 63) = x"FFFFFFFFFFFFFFFF";
--Осуществляется побайтовая обработка данных:
g_cycle: for g1 in 0 to 63 generate 
	process( clk )
		begin
			if( rising_edge(clk) ) then

--Проверка сигнала clken (разрешения обработки данных):
				if( clken = '1' ) then
--Проверка байт данных на то, чтобы они были информативными и не были равны нулю или неопределенными
if( data_in_int(g1) /= "UUUUUUUU" and data_in_int(g1) /= "ZZZZZZZZ" and data_in_int(g1) /= "XXXXXXXX" ) then
data_out_ff(g1) <= sbox_table(conv_integer(data_in_int(g1)));
--Установка признака валидности выходных данных:
		valid_i(g1) <= '1';
	end if;
else
--Сброс признака валидности выходных данных:
valid_i(g1) <= '0'; 	
end if;
end if; 
end process; end generate;

end arch;
