library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CodeGame is
    Port ( clk : in STD_LOGIC;
           Number : in STD_LOGIC_Vector(3 downto 0);
           KeyPress : in STD_LOGIC;
           GT, EQ, LT : out STD_LOGIC_VECTOR (3 downto 0);
           Win, Lose : out STD_LOGIC);
end CodeGame;

architecture Behavioral of CodeGame is

-- component for two bit counter
component TwoBitCounter is
	Port(clk	:	in 	STD_LOGIC;
    	 enable	:	in 	STD_LOGIC;
         clear 	: 	in 	STD_LOGIC;
         TC		: 	out STD_LOGIC;
end component;

-- state signals
type state_type is (sInit, sEnterCode, sEnterGuess, sCheck, sWin, sLose);
signal cstate, nstate : state_type := sInit;

-- control signals
signal ResetSignal			: STD_LOGIC := '0';
signal EnteringCodeSignal 	: STD_LOGIC := '0';
signal EnteringGuessSignal 	: STD_LOGIC := '0';
signal CheckSignal    : STD_LOGIC := '0';
signal WinSignal 			: STD_LOGIC := '0';
signal GuessCountTC			: STD_LOGIC := '0';
signal NumberCountTC		: STD_LOGIC := '0';

-- component signals
signal NumberCountEnable : STD_LOGIC := '0';
signal GuessCountEnable : STD_LOGIC := '0';

-- registers
signal code1	:	STD_LOGIC_VECTOR(3 downto 0);
signal code2	:	STD_LOGIC_VECTOR(3 downto 0);
signal code3	:	STD_LOGIC_VECTOR(3 downto 0);
signal code4	:	STD_LOGIC_VECTOR(3 downto 0);

signal guess1	:	STD_LOGIC_VECTOR(3 downto 0);
signal guess2	:	STD_LOGIC_VECTOR(3 downto 0);
signal guess3	:	STD_LOGIC_VECTOR(3 downto 0);
signal guess4	:	STD_LOGIC_VECTOR(3 downto 0);


begin

-- wire in the two-bit counter for NumberCount

NumberCounter: TwoBitCounter PORT MAP(
  clk	=> clk,
  enable => NumberCountEnable,
  clear => ResetSignal,
  TC => NumberCountTC);

GuessCounter: TwoBitCounter PORT MAP(
  clk	=> clk,
  enable => GuessCountEnable,
  clear => ResetSignal,
  TC => GuessCountTC);

-- update the FSM state at clock rise
stateUpdate : process(clk)
begin
	if rising_edge(clk) then
    	cstate <= nstate;
    end if;
end process stateUpdate;

-- async select next state based on control signals and current state
nextStateLogic : process(cstate, NumberCountTC, GuessCountTC, winSignal)
begin
	-- defaults
    nstate <= cstate;
    case cstate is
    	when sInit => nstate <= sEnterCode;
        when sEnterCode =>
        	if NumberCountTC = '1' then
            	nstate <= sEnterGuess;
            end if;
        when sEnterGuess =>
        	if NumberCountTC = '1' then
            	nstate <= sCheck;
            end if;
        when sCheck =>
        	if WinSignal = '1' then
            	nstate <= sWin;
            elsif GuessCountTC = '1'
            	nstate <= sLose;
            else
            	nstate <= sEnterGuess;
            end if;
        when sWin => nstate <= sInit;
        when sLose => nstate <= sInit;
    end case;
end process nextStateLogic;

-- contains logic for control signal vals
controlSignalLogic : process(cstate)
begin
	-- defaults
    EnteringCodeSignal <= '0';
    EnteringGuessSignal <= '0';
    CheckSignal <= '0';
    WinSignal <= '0';
    ResetSignal <= '0';
    case cstate is
    	when sEnterCode => enteringCodeSignal <= '1';
        when sEnterGuess => enteringGuessSignal <= '1';
        when sCheck =>
          CheckSignal <= '1';
        	if (code1 & code2 & code3 & code4) = (guess1 & guess2 & guess3 & guess4)
            	winSignal <= '1';
            end if;
        when others =>
    end case;
    
end process controlSignalLogic;
    
-- contains logic for output vals
outputLogic	: process(cstate)
begin
	-- defaults
    Win <= '0';
    Lose <= '0';
    GT <= "0000";
    EQ <= "0000";
    LT <= "0000";
    case cstate is
    	when sCheck =>
        	-- GT
            GT(3) <= '1' when unsigned(code1) > unsigned(guess1) else '0';
            GT(2) <= '1' when unsigned(code2) > unsigned(guess2) else '0';
            GT(1) <= '1' when unsigned(code3) > unsigned(guess3) else '0';
            GT(0) <= '1' when unsigned(code4) > unsigned(guess4) else '0';
            -- EQ
            EQ(3) <= '1' when unsigned(code1) = unsigned(guess1) else '0';
            EQ(2) <= '1' when unsigned(code2) = unsigned(guess2) else '0';
            EQ(1) <= '1' when unsigned(code3) = unsigned(guess3) else '0';
            EQ(0) <= '1' when unsigned(code4) = unsigned(guess4) else '0';
            -- LT
            LT(3) <= '1' when unsigned(code1) < unsigned(guess1) else '0';
            LT(2) <= '1' when unsigned(code2) < unsigned(guess2) else '0';
            LT(1) <= '1' when unsigned(code3) < unsigned(guess3) else '0';
            LT(0) <= '1' when unsigned(code4) < unsigned(guess4) else '0';
        when sWin => Win <= '1';
        when sLose <= Lose <= '1';
        others =>
    end case;
end process outputLogic;

counterEnableLogic : process(KeyPress, NumberCountTC, EnteringGuessSignal)
begin
  NumberCountEnable <= '0';
  GuessCountEnable <= '0';

  -- logic for NumberCounter
  if KeyPress = '1' then
    NumberCountEnable <= '1';
  end if;

  -- logic for GuessCounter
  if EnteringGuessSignal = '1' and NumberCountTC = '1' then
    GuessCountEnable <= '1';
  end if;
end process counterEnableLogic;

codeRegisterLogic : process(clk, EnteringCodeSignal, Number, KeyPress, ResetSignal)
begin
  -- all logic is clocked
  if rising_edge(clk) then
    -- clear all registers if ResetSignal is high
    if ResetSignal = '1' then
      code1 <= "0000";
      code2 <= "0000";
      code3 <= "0000";
      code4 <= "0000";
    elsif EnteringCodeSignal = '1' and KeyPress = '1' then
      code4 <= Number;
      code3 <= code4;
      code2 <= code3;
      code1 <= code2;
    end if;
  end if;
end process codeRegisterLogic;

guessRegisterLogic : process(clk, EnteringGuessSignal, Number, KeyPress, ResetSignal)
begin
  -- all logic is clocked
  if rising_edge(clk) then
    -- clear all registers if ResetSignal is high
    if ResetSignal = '1' then
      guess1 <= "0000";
      guess2 <= "0000";
      guess3 <= "0000";
      guess4 <= "0000";
    elsif EnteringGuessSignal = '1' and KeyPress = '1' then
      guess4 <= Number;
      guess3 <= guess4;
      guess2 <= guess3;
      guess1 <= guess2;
    end if;
  end if;
end process guessRegisterLogic;

end Behavioral;
