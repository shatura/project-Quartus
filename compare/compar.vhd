library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity compar is
generic( N:integer:=4);
Port ( A,B : in STD_LOGIC_VECTOR (N-1 downto 0);
Sum : out STD_LOGIC_VECTOR (N-1 downto 0);
c2 : out STD_LOGIC;
c1 : in STD_LOGIC);
end compar;
architecture Behavioral of compar is
COMPONENT comp
PORT( c1,a,b : IN std_logic;
c2,s2 : OUT std_logic);
END COMPONENT;
signal s:STD_LOGIC_VECTOR(N-2 downto 0);
begin
g0:for i in N-1 downto 0 generate
g1:if(i=N-1) generate
bitN:comp port map (c1 =>s(N-2),a =>A(N-1),b =>B(N-1),c2 =>c2,s2 =>Sum(N-1));
end generate g1;
g2:if(i>0 and i<N-1) generate
biti:comp port map (c1 =>s(i-1),a =>A(i),b =>B(i),c2 =>S(i),s2 =>Sum(i));
end generate g2;
g3:if(i=0) generate
bit0:comp port map (c1 =>c1,a =>A(0),b =>B(0),c2 =>S(0),s2 =>Sum(0));
end generate g3;
end generate g0;
end Behavioral;
