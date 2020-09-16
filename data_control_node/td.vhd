library ieee;
use ieee.std_logic_1164.all; use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity tb is --предназначен для ввода входных данных и моделирования тактовой частоты

port 
(
	check_over	: out std_logic := '0';
	check_resume	: out std_logic := '0'
);

end tb;

architecture arch of tb is
component check_module is

 
	port (
		clk	: in std_logic;
		data_in	: in std_logic_vector(511 downto 0);
		hash_check_in	: in std_logic_vector(511 downto 0); 
		start	: in std_logic;
		check_over	: out std_logic := '0';
		check_resume	: out std_logic := '0'
		);

	end component check_module;

	--Ввод входных данных:
	signal data_in	: std_logic_vector(511 downto 0) := (others => '0');
	signal hash_check_in : std_logic_vector(511 downto 0) := x"D32FA1AA3DF25B8853FE3E059D25C0E17238D3027EB271557949F248267FB89C4700CFEC58DB03CB92F69C6D9B2CE7F008BD0C6D5306C859417463B2ECED692C";
	signal start	: std_logic := '0';
	signal clk	: std_logic := '0';
		begin
	 
	data_in(15 downto 0) <= x"0000", x"1234" after 10 us;
	start	<= '0', '1' after 12 us, '0' after 20 us;
	
	--Процесс моделирования тактовой частоты (периодом 2 мксек):
	process
	begin
		wait for 1 us; clk <= not clk;
	end process;
	check_module_inst : check_module 
		port map
	(
			clk	=> clk,
			data_in	=> data_in,
			hash_check_in	=> hash_check_in,
			start	=> start,
			check_over	=> check_over,
			check_resume	=> check_resume
		);
	end arch;
