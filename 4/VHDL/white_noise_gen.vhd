library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity WhiteNoiseGenerator is
port (  clk     :   in  STD_LOGIC;
        Reset   :   in  STD_LOGIC;
        Seed    :   in  STD_LOGIC_VECTOR(15 downto 0);
        Random_Number   :   out STD_LOGIC_VECTOR(15 downto 0);
        Number_Ready    :   out STD_LOGIC);
end WhiteNoiseGenerator;

architecture behavior of WhiteNoiseGenerator is

signal ShiftReg :   STD_LOGIC_VECTOR(15 downto 0);

signal nextBit  : STD_LOGIC := '0';

constant CLOCK_DIVIDER_TC   : integer := 12;

signal clk_cycle_counter    : unsigned(3 downto 0) := (others => '0');
signal slow_clk_port        : STD_LOGIC := '0';

begin

cycle_counter: process(clk)
begin
  if rising_edge(clk) then
    if clk_cycle_counter = CLOCK_DIVIDER_TC-1 then
      clk_cycle_counter <= (others => '0'); -- reset the counter
    else
      clk_cycle_counter <= clk_cycle_counter + 1; -- else increment counter
    end if;
  end if;
end process cycle_counter;

toggle_clock: process(clk)
begin
  if rising_edge(clk) then
    if clk_cycle_counter = CLOCK_DIVIDER_TC-1 then
      slow_clk_port <= NOT(slow_clk_port);
    end if;
  end if;
end process toggle_clock;

updateReg : process(slow_clk_port, Reset, nextBit, Seed)
begin
  if rising_edge(slow_clk_port) then
    if Reset = '1' then
      ShiftReg <= Seed;
    else
      ShiftReg <= nextBit & ShiftReg(15 downto 1);
    end if;
  end if;
end process updateReg;

getNextBit : process(ShiftReg)
begin
  nextBit <= ((ShiftReg(0) xor ShiftReg(2)) xor ShiftReg(3)) xor ShiftReg(5);
end process getNextBit;

setNumberReady : process(slow_clk_port)
begin
  Number_Ready <= '0';
  if rising_edge(slow_clk_port) then
    Number_Ready <= '1';
  end if;
end process setNumberReady;

Random_Number <= ShiftReg;

end behavior;

