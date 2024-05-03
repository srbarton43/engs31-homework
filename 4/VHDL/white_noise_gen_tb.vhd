library IEEE;
use IEEE.std_logic_1164.all;

entity WhiteNoiseGenerator_tb  is
end WhiteNoiseGenerator_tb;

architecture testbench of WhiteNoiseGenerator_tb is

component PWM_Controller IS
PORT ( 	clk		:	in	STD_LOGIC; --1 MHz clock
		    Reset		: 	in 	STD_LOGIC;
		    Seed	: 	in 	STD_LOGIC_VECTOR(15 downto 0);
        Random_Number	:	out	STD_LOGIC_VECTOR(15 downto 0);		
        Number_Ready  :	out	STD_LOGIC);
end component;

signal clk		:	in	STD_LOGIC := '0'; --1 MHz clock
signal Reset		: 	in 	STD_LOGIC := '0';
signal Seed	: 	in 	STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal Random_Number_sig	:	STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal Number_Ready_sig  :	STD_LOGIC) := '0';

constant sys_clk_period : time := 1000ns;

begin

uut : PWM_Controller PORT MAP(
		clk  => clk,
		Reset => Reset,
        Seed => Seed,
        Random_Number 	=> Random_Number_sig,
		Number_Ready => Number_Ready_sig);
    
    
clk_proc : process
begin
  clk <= '0';
  wait for sys_clk_period/2;   

  clk <= '1';
  wait for sys_clk_period/2;
end process clk_proc;

stim_proc : process
begin
  Reset <= '0';
  wait for 3*sys_clk_period; -- stay zero

  Reset <= '1';
  Seed <= "1100110011001100";

  wait for 3*sys_clk_period; -- stay at seed for 3 clock cycles

  Reset <= '0';

  wait for 100*sys_clk_period;

  Reset <= '1';
  Seed <= "111111111111111";

  wait for 3*sys_clk_period;

  Reset <= '0';

  wait;
  
end process stim_proc;

end testbench;
