library ieee;
use ieee.std_logic_1164.all; 
use  ieee.numeric_std.all; 
use ieee.std_logic_arith.all;

entity gh_fixed512_logic is --������������ ��� ������� ���-�������

port (
	clk	: in std_logic;
	clken	: in std_logic;
	data_in		: in std_logic_vector(511 downto 0); 
	valid_out	: out std_logic := '0'; --������� ���������� �������� ������
	hash_out	: out std_logic_vector(511 downto 0)
	);
	
end gh_fixed512_logic;

architecture arch of gh_fixed512_logic is 
component gh_round_logic is

port (
	clk	: in std_logic;
	clken	: in std_logic;
	hash_in		: in std_logic_vector(511 downto 0); 
	numbits_in	: in std_logic_vector(511 downto 0); 
	data_in		: in std_logic_vector(511 downto 0); 
	valid_out	: out std_logic := '0';
	hash_out	: out std_logic_vector(511 downto 0)
	);
	
end component gh_round_logic;
--���������� �������� �������� ���� std_logic_vector:
signal after_data : std_logic_vector(511 downto 0); 
signal after_numbits : std_logic_vector(511 downto 0); 
signal vector_512 : std_logic_vector(511 downto 0);
--�������� ���� ������ ���� ������� 80�512:
type data_delay_type is array (0 to 79) of std_logic_vector(511 downto 0);
signal data_delay : data_delay_type; 
signal valid_out_1 : std_logic := '0';
signal valid_out_2 : std_logic := '0';

--�������������� ����� 512 � ������ 512-���������:
begin
 vector_512	<= conv_std_logic_vector(512, 512);
 
 --����������� ��������� ������� � ����������� ������ ����� ����:
 
 stage_1_data : gh_round_logic 
 
 port map
 (
		clk	=> clk,
		clken	=> clken,
		hash_in	=> (others => '0'), 
		numbits_in=> (others => '0'), 
		data_in	=> data_in,
		valid_out	=> valid_out_1,
		hash_out	=> after_data);
	
	
stage_2_numbits : gh_round_logic

port map (

		clk	=> clk,
		clken		=> valid_out_1, --clken, 
		hash_in	=> after_data,
		numbits_in=> (others => '0'), data_in	=> vector_512,
		valid_out	=> valid_out_2,
		hash_out	=> after_numbits
		);
		
--������� �������������� ������������ ������ ��� ������������� ������
stage_3_sumbits 
	process(clk)
		begin
		if( rising_edge(clk)) then
--�������� ������� clken (���������� ��������� ������):
			if( clken = '1' ) then
--����������� ���������� ��������:
				data_delay(1 to 79) <= data_delay(0 to 78); 
				data_delay(0)	<= data_in;
			end if; 
		end if;
	end process;


stage_3_sumbits : gh_round_logic
port map (
clk	=> clk,
clken		=> valid_out_2, --clken, 
hash_in	=> after_numbits, 
numbits_in=> (others => '0'),
data_in	=> data_delay(79),
valid_out	=> valid_out,
hash_out	=> hash_out);
end arch;

