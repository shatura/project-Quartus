library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity cnt_dc is port
(
clk: in std_logic;
reset: in std_logic;
click: in std_logic;
led: out std_logic_vector(7 downto 0)
);
end cnt_dc;

architecture led_arch of cnt_dc is
signal cnt: integer range 0 to 8 :=0;
signal temp: integer range 0 to 8 :=0;
signal res: integer;
begin

process (clk)
begin
if rising_edge(click) then
temp<=cnt;
res<=1;
end if;
if rising_edge(clk) then
if cnt=8 or res=1 then
cnt<=0;
else
cnt<=cnt+1;
end if;
end if;
if reset = '1' then
res<=0;
temp<=0;
cnt<=0;
end if;
end process;

led(0)<= '1' when cnt=1 or temp=1 else '0';
led(1)<= '1' when cnt=2 or temp=2 else '0';
led(2)<= '1' when cnt=3 or temp=3 else '0';
led(3)<= '1' when cnt=4 or temp=4 else '0';
led(4)<= '1' when cnt=5 or temp=5 else '0';
led(5)<= '1' when cnt=6 or temp=6 else '0';
led(6)<= '1' when cnt=7 or temp=7 else '0';
led(7)<= '1' when cnt=8 or temp=8 else '0';
end led_arch;