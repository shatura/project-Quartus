library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- For CONV_STD_LOGIC_VECTOR:
use ieee.std_logic_arith.all;

entity bin2bcd_5bit is
port( bin:in std_logic_vector(4 downto 0);
bcd1:out std_logic_vector(3 downto 0);
bcd10:out std_logic_vector(3 downto 0)
);

end bin2bcd_5bit;

architecture converter_behavior of bin2bcd_5bit is
begin
process(bin)
variable i : integer range 0 to 23;
variable i1 : integer range 0 to 9;
begin
i := conv_integer(bin);
i1 := i / 10;
bcd10 <= CONV_STD_LOGIC_VECTOR(i1, 4);
i1 := i rem 10;
bcd1 <= CONV_STD_LOGIC_VECTOR(i1, 4);
end process;
end converter_behavior;