library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 
entity proc is
port (ip: inout std_logic_vector(7 downto 0);
cmd: inout std_logic_vector(15 downto 0); 
clk,res: in std_logic;
a: inout std_logic_vector(7 downto 0); 
b,r: inout std_logic_vector(7 downto 0));
end proc;
architecture a of proc is 
signal stage: std_logic; 
begin
process(clk) 
begin
if (res = '1') then
a <="00000000";
b <="00000000";
ip <="00000000";
elsif clk'event and clk='1' then case stage is
when '0'=> stage<='1'; 
when others=> stage<='0'; 
case conv_integer(cmd) is when 0=> ip <= ip+1;
when 256 to 511 =>ip<=cmd(7 downto 0);
when 512 to 767 =>if conv_integer(a)=0
then ip<=cmd(7 downto 0);
else ip<=ip+1;
end if; 
when 768 to 1023 =>r<=ip; 
ip<=cmd(7 downto 0);
when 1024 to 1279 => a<=cmd(7 downto 0); 
ip<=ip+1;
when 1280 to 1535 => b<=cmd(7 downto 0); 
ip<=ip+1;
when 1536 =>ip<=r+1;
when 1537=>a<=b; 
ip<=ip+1;
when 1538=>b<=a; 
ip<=ip+1; 
when 1539=>a<=b;
b<=a; 
ip<=ip+1; 
when 1540=>a<=a+b; 
ip<=ip+1; 
when 1541=>a<=a-b; 
ip<=ip+1; 
when 1542=>a<=a and b; 
ip<=ip+1; 
when 1543=>a<=a or b; 
ip<=ip+1; 
when 1544=>a<=a xor b; 
ip<=ip+1; 
when 1545=>a<=a-1; 
ip<=ip+1; 
when others=>ip<=ip+1;
end case; 
end case; 
end if;
end process; 
end a;
