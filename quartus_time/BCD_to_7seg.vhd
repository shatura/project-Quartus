library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity BCD_to_7seg is
port(
BCD:in std_logic_vector(3 downto 0);
seg:out std_logic_vector(6 downto 0)
);

end BCD_to_7seg;

architecture conv_behavior of BCD_to_7seg is
begin
process(BCD)
begin
if BCD = "0000" then seg <= "0000001";--0
elsif BCD = "0001" then seg <= "1001111";--1
elsif BCD = "0010" then seg <= "0010010";--2
elsif BCD = "0011" then seg <= "0000110";--3
elsif BCD = "0100" then seg <= "1001100";--4
elsif BCD = "0101" then seg <= "0100100";--5
elsif BCD = "0110" then seg <= "0100000";--6
elsif BCD = "0111" then seg <= "0001111";--7
elsif BCD = "1000" then seg <= "0000000";--8
elsif BCD = "1001" then seg <= "0000100";--9
else seg <= "1001001";--err
end if;
end process;
end conv_behavior;