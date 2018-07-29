
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY testbench IS
END testbench;
 ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT baseComputer
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
			inpr : IN  std_logic_vector(7 downto 0);
         outr : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '1';
	signal inpr : std_logic_vector(7 downto 0) := "11110000";
 	--Outputs
   signal outr : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: baseComputer PORT MAP (
			clk => clk,
			reset => reset,
			inpr => inpr,
			outr => outr
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   stim_proc: process
   begin		
     
		reset <= '1';
		wait for 10 ns;
		reset <= '0';

      wait;
   end process;

END;
