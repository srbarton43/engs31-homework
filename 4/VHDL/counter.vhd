library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TwoBitCounter is
	Port(clk	:	in 	STD_LOGIC;
    	 enable	:	in 	STD_LOGIC;
         clear 	: 	in 	STD_LOGIC;
         TC		: 	out STD_LOGIC;
end TwoBitCounter;

architecture Behavioral of TwoBitCounter is

signal count : UNSIGNED(1 downto 0) := "00";
signal TC_signal : STD_LOGIC := '0';

begin

clocked : process(clk, enable, clear)
begin
  if rising_edge(clk) then
    if clear = '1' then
      count <= "00";
    elsif enable = '1' then
      count <= count + 1;
    end if;
  end if;
end process;

TC_logic : process(count)
  TC_signal <= '0';
  if count = 3 then
    TC_signal <= '1';
  end if;
end process;

TC <= TC_signal;
  
end Behavioral;
