library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity PS2 is
port (
	CLK_MAIN, CLK_11, CLK_25, CLK_100, RST: in std_logic;
	PS2_DATA, PS2_CLK: in std_logic; -- PS2 clk and data
	SCANCODE: out std_logic_vector(7 downto 0); -- scan code signal output, 每接收到一组数据即输出
	OE: out std_logic -- 输出使能，每次输出的时候置1，无输出时置0
	) ;
end PS2 ;

architecture rtl of PS2 is
type state_type is (delay, start, d0, d1, d2, d3, d4, d5, d6, d7, parity, stop, finish) ;
signal data, clk, clk1, clk2, odd, fok : std_logic ; 
signal code : std_logic_vector(7 downto 0) ; 
signal state : state_type ;
begin
	clk1 <= PS2_CLK when rising_edge(CLK_MAIN) ;
	clk2 <= clk1 when rising_edge(CLK_MAIN) ;
	clk <= (not clk1) and clk2 ;
	
	data <= PS2_DATA when rising_edge(CLK_MAIN) ;
	
	odd <= code(0) xor code(1) xor code(2) xor code(3) 
		xor code(4) xor code(5) xor code(6) xor code(7) ;
	
	SCANCODE <= code when fok = '1' ;
	
	process(RST, CLK_MAIN)
	begin
		if rising_edge(CLK_MAIN) then
			fok <= '0';
			OE <= '0' ;
			case state is 
				when delay =>
					state <= start ;
				when start =>
					if clk = '1' then
						if data = '0' then
							state <= d0 ;
						else
							state <= delay ;
						end if ;
					end if ;
				when d0 =>
					if clk = '1' then
						code(0) <= data ;
						state <= d1 ;
					end if ;
				when d1 =>
					if clk = '1' then
						code(1) <= data ;
						state <= d2 ;
					end if ;
				when d2 =>
					if clk = '1' then
						code(2) <= data ;
						state <= d3 ;
					end if ;
				when d3 =>
					if clk = '1' then
						code(3) <= data ;
						state <= d4 ;
					end if ;
				when d4 =>
					if clk = '1' then
						code(4) <= data ;
						state <= d5 ;
					end if ;
				when d5 =>
					if clk = '1' then
						code(5) <= data ;
						state <= d6 ;
					end if ;
				when d6 =>
					if clk = '1' then
						code(6) <= data ;
						state <= d7 ;
					end if ;
				when d7 =>
					if clk = '1' then
						code(7) <= data ;
						state <= parity ;
					end if ;
				WHEN parity =>
					IF clk = '1' then
						if (data xor odd) = '1' then
							state <= stop ;
						else
							state <= delay ;
						end if;
					END IF;

				WHEN stop =>
					IF clk = '1' then
						if data = '1' then
							state <= finish;
						else
							state <= delay;
						end if;
					END IF;

				WHEN finish =>
					state <= delay ;
					fok <= '1' ;
					OE <= '1';
				when others =>
					state <= delay ;
			end case ; 
		end if ;
	end process ;
end rtl ;
			
						
