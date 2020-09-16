library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity gh_round_ltran_logic is -- предназначен	для	расчета	Lпреобразования (линейное преобразование)


port (
 	clk	: in std_logic;
	clken	: in std_logic;
	after_p		: in std_logic_vector(511 downto 0);
	valid_out	: out std_logic := '0';
	lps_func	: out std_logic_vector(511 downto 0)
);
end gh_round_ltran_logic;

	architecture arch of gh_round_ltran_logic is
	--Создание типа данных типа матрицы 64х64:
	type table_a_type is array (0 to 63) of std_logic_vector(63 downto 0);
	--Значения таблицы коэффициентов:
	constant table_a: table_a_type := (
	x"8e20faa72ba0b470", x"47107ddd9b505a38", x"ad08b0e0c3282d1c", x"d8045870ef14980e",
	x"6c022c38f90a4c07", x"3601161cf205268d", x"1b8e0b0e798c13c8", x"83478b07b2468764",
	x"a011d380818e8f40", x"5086e740ce47c920", x"2843fd2067adea10",x"14aff010bdd87508",
	x"0ad97808d06cb404", x"05e23c0468365a02", x"8c711e02341b2d01", x"46b60f011a83988e",
	x"90dab52a387ae76f", x"486dd4151c3dfdb9", x"24b86a840e90f0d2", x"125c354207487869",
	x"092e94218d243cba", x"8a174a9ec8121e5d", x"4585254f64090fa0",x"accc9ca9328a8950",
	x"9d4df05d5f661451", x"c0a878a0a1330aa6", x"60543c50de970553",x"302a1e286fc58ca7",
	x"18150f14b9ec46dd", x"0c84890ad27623e0", x"0642ca05693b9f70", x"0321658cba93c138",
	x"86275df09ce8aaa8", x"439da0784e745554", x"afc0503c273aa42a", x"d960281e9d1d5215",
	x"e230140fc0802984", x"71180a8960409a42", x"b60c05ca30204d21", x"5b068c651810a89e",
	x"456c34887a3805b9", x"ac361a443d1c8cd2", x"561b0d22900e4669", x"2b838811480723ba",
	x"9bcf4486248d9f5d", x"c3e9224312c8c1a0", x"effa11af0964ee50", x"f97d86d98a327728",
	x"e4fa2054a80b329c", x"727d102a548b194e", x"39b008152acb8227", x"9258048415eb419d",
	x"492c024284fbaec0", x"aa16012142f35760", x"550b8e9e21f7a530",x"a48b474f9ef5dc18",
	x"70a6a56e2440598e", x"3853dc371220a247", x"1ca76e95091051ad",x"0edd37c48a08a6d8",
	x"07e095624504536c", x"8d70c431ac02a736", x"c83862965601dd1b",x"641c314b2b8ee083"
	);
	
--Создание типа данных типа матрицы 64х8:

	type mass_64x7_type is array (0 to 63) of std_logic_vector(7 downto 0);
	signal state_in : mass_64x7_type; 
	signal state_out : mass_64x7_type; 
	signal state_ff : mass_64x7_type;

--Создание функции для обработки данных:

	function func_many_cycles(state_in: mass_64x7_type) return
	mass_64x7_type is
	
		variable v : std_logic_vector(63 downto 0); 
		variable temp1 : std_logic_vector(7 downto 0); 
		variable temp2 : std_logic_vector(7 downto 0); 
		variable temp3 : std_logic_vector(7 downto 0); 
		variable temp11 : integer range 0 to 63; 
		variable temp12 : integer range 0 to 63;
		variable state_out_v : mass_64x7_type;
		
	--Циклы обработки данных:
	begin
		for i in 0 to 7 loop
		v := (others => '0'); 
			for k in 0 to 7 loop
				for j in 0 to 7 loop
	--Проверка байт данных на то, чтобы они были информативными и не были равны 0 или неопределенными
	
	if (state_in(63-(i*8+k))(7-j) /= '0' and state_in(63- (i*8+k))(7-j) /= 'U' and state_in(63-(i*8+k))(7-j) /= 'Z' and state_in(63-(i*8+k))(7-j) /= 'X' ) then --по формуле с госта
		
		v := v xor table_a(k*8+j); 
		end if;
	end loop; 
end loop;
	--Осуществляется расчет линейного преобразования:
	
	for kk in 0 to 7 loop
		temp11 := (7-kk)*8;
		temp3 := v(temp11+7 downto temp11);
		state_out_v(63-(i*8+kk)) := temp3; 
	end loop;
	end loop;
	return state_out_v; 
	end func_many_cycles;
 
	begin
	--Осуществляется переписывание байтов из входного массива в байты  
	--двумерной	матрицы	для	того,	чтобы	входной	массив	512	разрядов обрабатывать побайтово
	fill_inputs_cycle_j: for in_j in 0 to 63 generate 
	state_in(in_j)	<= after_p((7+in_j*8) downto in_j*8);
	end generate fill_inputs_cycle_j;
	
	--Осуществляется переписывание данных побайтово из матрицы в выходной массив для того,
	-- чтобы сформировать из двумерной матрицы данных входной 512-разрядный массив
	
	fill_outputs_cycle_j: for in_j in 0 to 63 generate 
	lps_func((7+in_j*8) downto in_j*8) <= state_ff(in_j);
	end generate fill_outputs_cycle_j;
	
	--Процесс обработки данных:
	process(clk)
		begin
		if( rising_edge(clk) ) then
	--Проверка сигнала clken (разрешения обработки данных):
		if( clken = '1' ) then
	--Вызов функции func_many_cycles():
		state_ff <= func_many_cycles(state_in);
	--Установка признака валидности выходных данных:
		valid_out <= '1';
	   else
	--Сброс признака валидности выходных данных:
		valid_out <= '0'; 
		end if;
	end if; end process;
end arch;

	








	

