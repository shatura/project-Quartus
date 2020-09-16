library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


--Описание интерфейса модуля:
entity check_module is	-- расчет контроля хэш-функции и проверка на совпадение
 
port (

		clk	: in std_logic;
		data_in	: in std_logic_vector(511 downto 0);		 --входные данные для расчета хэш- функции
		hash_check_in	: in std_logic_vector(511 downto 0); -- контрольное значение хэш-функции для сверки с полученным
		start	: in std_logic;								 -- сигнал запуска работы модуля
		check_over	: out std_logic := '0';					 --сигнал завершения обработки данных
		check_resume	: out std_logic := '0'  			 --признак вердикта о совпадении рассчитанного и контрольного значений хэш-функций (1 – совпадение, 0 – несовпадение).

);
end check_module;

architecture arch of check_module is 
component gh_fixed512_logic

port (
		clk	: in std_logic;
		clken	: in std_logic;
		data_in	: in std_logic_vector(511 downto 0);
		valid_out	: out std_logic := '0';
		hash_out	: out std_logic_vector(511 downto 0)
	);
	 end component gh_fixed512_logic;
		signal enable	: std_logic := '0';
		signal data_in_i	: std_logic_vector(511 downto 0); 
		signal valid_out_i		: std_logic := '0';
		signal hash_out_i	: std_logic_vector(511 downto 0) := (others => '0');
		signal hash_out_i_lock	: std_logic_vector(511 downto 0) := (others => '0');
		signal hash_check_in_i	: std_logic_vector(511 downto 0) := (others => '0');
		signal step	: integer range 0 to 7 := 0;

	begin
	
	--Процесс управления модулем расчета хэша:
	
		process(clk) 
		begin
			if( rising_edge(clk) ) then
				--Предустановка признака завершения обработки в 0:
				check_over	<= '0';
				--Автомат работы с данными:
				case(step) is
				--Состояние автомата "ожидание сигнала запучка работы":
				when 0 =>
				--Сброс признака совпадения хэшей:
				check_resume	<= '0';
			--усли подан сигнал начала работы, тогда дается разрешение на работу модулю расчета, 
			--подается входной вектор данных на модуль расчета, подается в буфер контрольное значение хэш-функции, 
			--осуществляется переход на следующее состояние автомата для последующего сравнения
			
			if( start = '1' ) then
				enable	<= '1';
				data_in_i	<= data_in; 
				hash_check_in_i <= hash_check_in; 
				step	<= 1;
			else
			--если нет сигнала запуска работы, тогда модуль расчета остановлен:
				enable	<= '0';
			end if;
			--Состояние автомата переходит в «ожидание завершения расчета значения хэш-функции»:
			when 1 =>
			--Если от модуля расчета пришел признак валидности выходных данных, тогда происходит остановка модуля расчета, 
			--рассчитанное значение хэш- функции подается в буфер для последующего сравнения. 
			--После следует переход на следующее состояние автомата
			if( valid_out_i = '1' ) then

				enable	<= '0';
				hash_out_i_lock <= hash_out_i; 
				step	<= 2;
				end if;
			--В состоянии автомата "сравнение значений хэш-функций" выдается 
			--признак завершения обработки данных, затем сравниваются 
			--рассчитанное значение хэш-функции и контрольное значение
				when 2 =>
						check_over	<= '1';
						if( hash_out_i_lock = hash_check_in_i ) then
							check_resume	<= '1';  --совпало
							else
							check_resume	<= '0';  --несовпало
							end if;
							step	<= 3;		 	 --переход
			--ожидание старта (это состояние необходимо для того, чтобы расчеты были однозначно стартованы, а не выполнялись бесконечно над одними и теми же данными)
			when 3 =>

								if( start = '0' ) then step	<= 0;
								end if;
								when others => null;
							end case;
						end if; 
					end process;
					
		gh_fixed512_logic_inst : gh_fixed512_logic 
		port map
		(
			clk	=> clk,
			clken	=> enable,
			data_in		=> data_in_i, 
			valid_out	=> valid_out_i,
			hash_out	=> hash_out_i
		);
	end arch;

