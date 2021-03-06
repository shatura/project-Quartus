library ieee;
use ieee.std_logic_1164.all; use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity gh_round_efunc_v2_logic is --������������ ��� ������� ������� �������� �����

port (

	clk	: in std_logic;
	clken	: in std_logic;
	hash_in	: in std_logic_vector(511 downto 0);
	data_in		: in std_logic_vector(511 downto 0); valid_out	: out std_logic := '0';
	hash_out	: out std_logic_vector(511 downto 0)
	);
	
	end gh_round_efunc_v2_logic;
	
	architecture arch of gh_round_efunc_v2_logic is
	
	 --�������� ���� ������ ���� ������� 12�512:
	 
	 type const_c_type is array (1 to 12) of std_logic_vector(511 downto 0);
	 
	 --���������� ��������� �, �������� ������� ����� �� ���� 34.11-2012:
	 
	 constant const_c : const_c_type := (
	x"b1085bda1ecadae9ebcb2f81c0657c1f2f6a76432e45d016714eb88d7585c4fc4b7ce09192676901a2422a08a460d31505767436cc744d23dd806559f2a64507",
	x"6fa3b58aa99d2f1a4fe39d460f70b5d7f3feea720a232b9861d55e0f16b501319ab5176b12d699585cb561c2db0aa7ca55dda21bd7cbcd56e679047021b19bb7",
	x"f574dcac2bce2fc70a39fc286a3d843506f15e5f529c1f8bf2ea7514b1297b7bd3e20fe490359eb1c1c93a376062db09c2b6f443867adb31991e96f50aba0ab2",
	x"ef1fdfb3e81566d2f948e1a05d71e4dd488e857e335c3c7d9d721cad685e353fa9d72c82ed03d675d8b71333935203be3453eaa193e837f1220cbebc84e3d12e",
	x"4bea6bacad4747999a3f410c6ca923637f151c1f1686104a359e35d7800fffbdbfcd1747253af5a3dfff00b723271a167a56a27ea9ea63f5601758fd7c6cfe57",
	x"ae4faeae1d3ad3d96fa4c33b7a3039c02d66c4f95142a46c187f9ab49af08ec6cffaa6b71c9ab7b40af21f66c2bec6b6bf71c57236904f35fa68407a46647d6e",
	x"f4c70e16eeaac5ec51ac86febf240954399ec6c7e6bf87c9d3473e33197a93c90992abc52d822c3706476983284a05043517454ca23c4af38886564d3a14d493",
	x"9b1f5b424d93c9a703e7aa020c6e41414eb7f8719c36de1e89b4443b4ddbc49af4892bcb929b069069d18d2bd1a5c42f36acc2355951a8d9a47f0dd4bf02e71e",
	x"378f5a541631229b944c9ad8ec165fde3a7d3a1b258942243cd955b7e00d0984800a440bdbb2ceb17b2b8a9aa6079c540e38dc92cb1f2a607261445183235adb",
	x"abbedea680056f52382ae548b2e4f3f38941e71cff8a78db1fffe18a1b3361039fe76702af69334b7a1e6c303b7652f43698fad1153bb6c374b4c7fb98459ced",
	x"7bcd9ed0efc889fb3002c6cd635afe94d8fa6bbbebab076120018021148466798a1d71efea48b9caefbacd1d7d476e98dea2594ac06fd85d6bcaa4cd81f32d1b",
	x"378ee767f11631bad21380b00449b17acda43c32bcdf1d77f82012d430219f9b5d80ef9d1891cc86e71da4aa88e12852faf417d5d9b21b9948bc924af11bd720"
	);
 
	--�������� ���� ������ ���� ������� 12�512, 13�512, 13�1:
	
	
		type m12_type is array (1 to 12) of std_logic_vector(511 downto 0);
		type m13_type is array (1 to 13) of std_logic_vector(511 downto 0);
		type b13_type is array (1 to 13) of std_logic;
		
		-- ���������� �������� ��������:
		
		signal val_x : m13_type; 
		signal val_kc : m12_type;
		signal val_k : m13_type; 
		signal val_lps : m13_type;
		signal clken_i : b13_type := (others => '0'); 
		signal valid_out_i : b13_type := (others => '0');
 
	component gh_round_lps_logic

	 
	port (
		clk	: in std_logic;
		clken	: in std_logic;
		lps_arg		: in std_logic_vector(511 downto 0); 
		valid_out	: out std_logic := '0';
		lps_func	: out std_logic_vector(511 downto 0)
		);

end component gh_round_lps_logic;


begin

--����� �������� ������ �� �����:
	hash_out <= val_x(13);
--��������������� ���������� ������������� ������:
	val_lps(1) <= data_in; 
	val_k(1) <= hash_in; 
	valid_out_i(1) <= clken; 
	clken_i(1) <= clken;
--��������� ������:
	generate_cycle_j: for g1 in 2 to 13 generate process(clk)
	begin
		if(rising_edge(clk)) then
--�������� ������� clken (���������� ��������� ������):
if( clken = '1' ) then
			val_x(g1-1) <= val_k(g1-1) xor val_lps(g1-1); 
			val_kc(g1-1) <= val_k(g1-1) xor const_c(g1-1); 
			clken_i(g1) <= valid_out_i(g1-1);
		end if;
	end if;
end process;

gh_round_lps_logic_main_inst : gh_round_lps_logic 
port map
	(
	clk	=> clk,
	clken	=> clken,
	--clken	=> clken_i(g1-1),
	lps_arg	=> val_x(g1-1),
	valid_out	=> valid_out_i(g1),
	lps_func	=> val_lps(g1)
);
gh_round_lps_logic_k_inst : gh_round_lps_logic

port map (
		clk	=> clk,
		clken	=> clken,
		--clken	=> clken_i(g1-1),
		lps_arg	=> val_kc(g1-1),
		 
		valid_out	=> open, --valid_out_i(g1),
		lps_func	=> val_k(g1)
);

end generate generate_cycle_j;
--������� ���������������� ������������ �������� ������ � ������� ���������� ���� �������� ������:
	process(clk)
	begin
		if(rising_edge(clk)) then
-- �������� ������� clken (���������� ��������� ������) 
			if( clken = '1' ) then
				val_x(13) <= val_k(13) xor val_lps(13); 
				valid_out <= valid_out_i(13);
			else
			valid_out <= '0';
end if; end if;
end process;

end arch;

