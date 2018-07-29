
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity basecomputer is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           outr : out  STD_LOGIC_vector(7 downto 0);
           inpr : in  STD_LOGIC_vector(7 downto 0));
end basecomputer;

architecture Behavioral of basecomputer is

type memory is array(0 to 1023) of std_logic_vector(15 downto 0);
signal mem : memory;
signal mbr : std_logic_vector(15 downto 0);
signal mar :std_logic_vector(9 downto 0);
signal pc : std_logic_vector(9 downto 0);
signal ar : std_logic_vector(9 downto 0);
signal ac : std_logic_vector(8 downto 0);
signal cr : std_logic_vector(7 downto 0);
signal opr : std_logic_vector(3 downto 0);
signal zf : std_logic;
signal cf : std_logic;
signal fgi : std_logic;
signal fgo : std_logic;
signal inf : std_logic;

signal state : std_logic_vector(5 downto 0);

begin

	process(clk,reset)
		
		variable ad : integer;
	begin
	
		if(reset = '1') then
			
			pc <= "0000000000";
			zf <= '0';
			cf <= '0';
			fgi <= '0';
			fgo <= '0';
			inf <= '0';
			ac <= "000000000";
			state <= "000000";
		
		--  setting to memory word like examples :
		
		
		--	mem(0) <= "1011110000010000";
		--	mem(1) <= "0011110000000100";
		
			
			
		else if(clk'event and clk = '1') then
		
			case state is
				when "000000" =>
					mar <= pc;
					state <= "000001";
				
				when "000001" => --fetch
					ad := to_integer(unsigned(mar));
					mbr <= mem(ad);
					pc <= pc + 1;
					state <= "000010";
				
				when "000010"=> --decode
					opr <= mbr(13 downto 10);
					ar <= mbr(9 downto 0);
					state <= "000011";	
				
				when "000011"=>
					if (mbr(14)='0') then
						state <= "000100"; --execution cycle
					else 
						if (mbr(15)='0') then
							state <= "000111"; --direct
						else 
							state <= "001010"; --indirect
						end if;
					end if;
				
				when "000100"=> --execution cycle
					if (mbr(13 downto 10)="1111") then
						if (mbr(15)='0') then
							state <="001101"; -- register
						else
							state <="001110"; --I/O
						end if;

					else
						state <= "001001"; --immediate addressing (mem ref ins)
					end if;
				
				when "000111"=> --direct
					mar <= ar;
					state <= "001000";
					
				when "001000"=>
					ad := to_integer(unsigned(mar));
					mbr <= mem(ad);
					state <= "001001";
					
				when "001001"=> --mem ref
				
					case opr is
						when "0000"=> --NOP
							state<="001111";
						when "0001"=> --ADD
							ac <= ac + mbr(7 downto 0);
							state<="001111";
						when "0010"=> --SUB
							ac <= ac + not mbr(7 downto 0)+1;
							state<="001111";
						when "0011"=> --AND
							ac <= ac and mbr(7 downto 0);
							state<="001111";
						when "0100"=> --OR
							ac <= ac or mbr(7 downto 0);
							state<="001111";
						when "0101"=> --XOR
							ac <= ac xor mbr(7 downto 0);
							state<="001111";
						when "0110"=> --LDA
							ac(7 downto 0) <= mbr(7 downto 0);
							state<="001111";
						when "0111"=> --STA
							mar <= ar;
							mbr(7 downto 0)<= ac(7 downto 0);
							state <= "010011";
						when "1000"=> --BUN
							pc <= ar;
							state<="001111";
						when "1001"=> --BSA
							mbr(9 downto 0) <= pc;
							mar <= ar;
							state <= "010011";
						when "1010"=> --DSZ
							mbr(7 downto 0)<= mbr(7 downto 0) - 1;
							state <= "010110";
						when "1011"=> --LDC
							cr <= mbr(7 downto 0);
							state<="001111";
						when "1100"=> --BZ
							if (zf='0') then
								pc<=pc+1;
								state<="001111";
							else
								pc<=mbr(9 downto 0);
								state<="001111";
							end if;
						when "1101"=> --BC		
							if (zf='0') then
								pc<=pc+1;
								state<="001111";
							else
								pc<=mbr(9 downto 0);
								state<="001111";
							end if;
						when others =>
							state<="001111";
					end case;
				
				when "001010"=> --indirect
					mar <= ar;
					state <="001011";
					
				when "001011"=> 
					ad := to_integer(unsigned(mar));
					mbr <= mem(ad);
					state <= "001100";
					
				when "001100"=> 
					ar <= mbr(9 downto 0);
					state <= "000111";
					
				when "001101"=> --reg ref ins
					
					case mbr is
					
						when "0011110000000001"=> --CLA
							ac(7 downto 0)  <= "00000000";
							state<="001111";
						when "0011110000000010"=> --CLS
							zf<='0';
							cf<='0';
							state<="001111";
						when "0011110000000100"=> --CMA
							ac <= not ac;
							state<="001111";
						when "0011110000001000"=> --SRA
							ac(6 downto 0) <= ac(7 downto 1);
							ac(7)<= '0';
							state<="001111";
						when "0011110000010000"=> --SLA
							ac(7 downto 1) <= ac(6 downto 0);
							ac(0)<= '0';
							state<="001111";
						when "0011110000100000"=> --INC
							ac <= ac + 1;
							state<="001111";
						when "0011110001000000"=> --HALT
						
						when others =>
							state<="001111";
					end case;
					
				when "001110"=> --I/O ref ins	
					
					case mbr is
					
						when "1011110000000001"=> --INP
							ac(7 downto 0) <= inpr;
							fgi <= '0';
							state<="001111";
						when "1011110000000010"=> --OUT
							outr <= ac(7 downto 0);
							fgo <= '0';
							state<="001111";
						when "1011110000000100"=> --SKI
							if (fgi = '1') then
								pc <= pc + 1;
								state<="001111";
							end if;	
						when "1011110000001000"=> --SKO
							if (fgo = '1') then
								pc <= pc + 1;
								state<="001111";
							end if;	
						when "1011110000010000"=> --ION
							inf <= '1';
							state<="001111";
						when "1011110000100000"=> --IOF
							inf <= '0';
							state<="001111";
						when "1011110001000000"=> --SFI
							fgi <= '1';
							state<="001111";
						when "1011110010000000"=> --SFO
							fgo <= '1';
							state<="001111";
							when others =>
							state<="001111";
					end case;
					
					
				when "001111"=>
					if (inf='0') then
						state <= "000000"; --fetch
					else
						state <= "010000"; --interrupt cycle
					end if;
					
				when "010000"=> --interrupt cycle
					mbr(7 downto 0) <= pc(7 downto 0);
					inf <='0';
					state <= "010001";
					
				when "010001"=>
					pc<="0000000000";
					mar<="0000000000";
					state<="010010";
					
				when "010010"=>
					ad := to_integer(unsigned(mar));
					mem(ad)<=mbr(7 downto 0);
					pc<=pc+1;
					
				when "010011"=> 	--second clk STA
					ad := to_integer(unsigned(mar));
					mem(ad)<= mbr(7 downto 0);
					state<="001111";
					
				when "010100"=> 	--second clk BSA
					ad := to_integer(unsigned(mar));
					mem(ad)<= mbr(9 downto 0);
					ar <= ar + 1;
					state <= "010101";
					
				when "010101"=> 	--third clk BSA
					pc <= ar;
					state<="001111";
					
				when "010110"=> 	--second clk DSZ
					ad := to_integer(unsigned(mar));
					mem(ad) <= mbr(7 downto 0);
					ac(7 downto 0) <= mbr(7 downto 0);
					state <= "010111";
					
				when "010111"=> --third clk DSZ
					if (ac="000000000") then
						pc<= pc+1;
						state<="001111";
					else
						state<="001111";
					end if;	

				when others =>
					state <= "000000";
				
			end case;
		
		end if;
end if;
	
end process;

end Behavioral;