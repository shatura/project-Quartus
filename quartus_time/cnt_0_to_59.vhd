library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- For CONV_STD_LOGIC_VECTOR:
use ieee.std_logic_arith.all;

entity cnt_0_to_59 is
port( clk:in std_logic; c59:out std_logic; vector:out std_logic_vector(5 downto 0));
end cnt_0_to_59;

architecture cnt_behavior of cnt_0_to_59 is
begin
process(clk)
variable cnt : integer range 0 to 59;
begin
if(clk'event and clk = '1')
then
if(cnt = 59)
then
cnt := 0;
c59 <= '1';
vector <= CONV_STD_LOGIC_VECTOR(cnt, 6);
else
cnt := cnt + 1;
c59 <= '0';
vector <= CONV_STD_LOGIC_VECTOR(cnt, 6);
end if;
end if;
end process;
end cnt_behavior;