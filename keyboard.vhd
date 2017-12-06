library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity keyboard is
port (
	CLK_MAIN, RST: in std_logic;
	PS2_CODE: in std_logic_vector(7 downto 0);
	PS2_OE: in std_logic;
	ASCII: out STD_LOGIC_VECTOR(15 downto 0);
	KeyboardOE: out STD_LOGIC
	) ;
end keyboard ;

architecture kbd of keyboard is
type state_type is (delay,arrow,breakCheck,done);
signal state:state_type;
signal CodeBuffer, prevCode: STD_LOGIC_VECTOR(7 downto 0);
signal ASCIIBuffer: STD_LOGIC_VECTOR(15 downto 0);
signal shiftModifier,LshiftModifier,RshiftModifier,capsModifier,upperModifier: STD_LOGIC;

-- ALT:000f,  ESC:001b,  TAB:0009

begin
	ASCII <= ASCIIBuffer;
	shiftModifier <= LshiftModifier or RshiftModifier;
	upperModifier <= shiftModifier xor capsModifier;

	ASCII_translate: process(RST,PS2_OE,CLK_MAIN,PS2_CODE, shiftModifier, prevCode, CodeBuffer)
	begin
		if (RST = '0') then
			prevCode <= x"00";
			CodeBuffer <= x"00";
			LshiftModifier <= '0';
			RshiftModifier <= '0';
			capsModifier <= '0';
			ASCIIBuffer <= x"0000";
			state <= delay;
		elsif rising_edge(CLK_MAIN) then
			case state is 
				when delay =>
					KeyboardOE <= '0';
					if PS2_OE = '1' then
						case PS2_CODE is
								
							--arrows
							when x"e0" => 
								state <= arrow;										--arrows
								
							--break code
							when x"f0" => 
								state <= breakCheck;								--break code
								
							when others => 
								CodeBuffer <= PS2_CODE; 
								state <= done;
							
						end case;
					end if;
				when arrow =>
					KeyboardOE <= '0';
					if PS2_OE = '1' then
						case PS2_CODE is
							--U arrow
							when x"75" => 
								CodeBuffer <= PS2_CODE; 
								state <= done;
							--L arrow
							when x"6b" => 
								CodeBuffer <= PS2_CODE; 
								state <= done;
							--D arrow
							when x"72" => 
								CodeBuffer <= PS2_CODE; 
								state <= done;
							--R arrow
							when x"74" => 
								CodeBuffer <= PS2_CODE; 
								state <= done;
							--break code
							when x"f0" => 
								state <= breakCheck;								--break code
							when others => state <= delay;
						end case;
					end if;
				when done =>
					if (CodeBuffer /= prevCode) then
						prevCode <= CodeBuffer;
						case CodeBuffer is
							--a-z
							when x"1c" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0041";
								else
									ASCIIBuffer <= x"0061";
								end if;
								state <= delay;										--a
							when x"32" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0042";
								else
									ASCIIBuffer <= x"0062";
								end if;
								state <= delay;										--b
							when x"21" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0043";
								else
									ASCIIBuffer <= x"0063";
								end if;
								state <= delay;										--c
							when x"23" => 								
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0044";
								else
									ASCIIBuffer <= x"0064";
								end if;
								state <= delay;										--d
							when x"24" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0045";
								else
									ASCIIBuffer <= x"0065";
								end if;
								state <= delay;										--e
							when x"2b" => 								
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0046";
								else
									ASCIIBuffer <= x"0066";
								end if;
								state <= delay;										--f
							when x"34" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0047";
								else
									ASCIIBuffer <= x"0067";
								end if;
								state <= delay;										--g
							when x"33" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0048";
								else
									ASCIIBuffer <= x"0068";
								end if;
								state <= delay;										--h
							when x"43" =>
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0049";
								else
									ASCIIBuffer <= x"0069";
								end if;
								state <= delay;										--i
							when x"3b" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"004a";
								else
									ASCIIBuffer <= x"006a";
								end if;
								state <= delay;										--j
							when x"42" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"004b";
								else
									ASCIIBuffer <= x"006b";
								end if;
								state <= delay;										--k
							when x"4b" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"004c";
								else
									ASCIIBuffer <= x"006c";
								end if;
								state <= delay;										--l
							when x"3a" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"004d";
								else
									ASCIIBuffer <= x"006d";
								end if;
								state <= delay;										--m
							when x"31" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"004e";
								else
									ASCIIBuffer <= x"006e";
								end if;
								state <= delay;										--n
							when x"44" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"004f";
								else
									ASCIIBuffer <= x"006f";
								end if;
								state <= delay;										--o
							when x"4d" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0050";
								else
									ASCIIBuffer <= x"0070";
								end if;
								state <= delay;										--p
							when x"15" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0051";
								else
									ASCIIBuffer <= x"0071";
								end if;
								state <= delay;										--q
							when x"2d" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0052";
								else
									ASCIIBuffer <= x"0072";
								end if;
								state <= delay;										--r
							when x"1b" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0053";
								else
									ASCIIBuffer <= x"0073";
								end if;
								state <= delay;										--s
							when x"2c" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0054";
								else
									ASCIIBuffer <= x"0074";
								end if;
								state <= delay;										--t
							when x"3c" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0055";
								else
									ASCIIBuffer <= x"0075";
								end if;
								state <= delay;										--u
							when x"2a" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0056";
								else
									ASCIIBuffer <= x"0076";
								end if;
								state <= delay;										--v
							when x"1d" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0057";
								else
									ASCIIBuffer <= x"0077";
								end if;
								state <= delay;										--w
							when x"22" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0058";
								else
									ASCIIBuffer <= x"0078";
								end if;
								state <= delay;										--x
							when x"35" => 
								if (upperModifier = '1') then
									ASCIIBuffer <= x"0059";
								else
									ASCIIBuffer <= x"0079";
								end if;
								state <= delay;										--y
							when x"1a" => 								
								if (upperModifier = '1') then
									ASCIIBuffer <= x"005a";
								else
									ASCIIBuffer <= x"007a";
								end if;
								state <= delay;										--z
								
							--0-9	
							when x"45" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"0029";
								else
									ASCIIBuffer <= x"0030";
								end if;
								state <= delay;										--0
							when x"16" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"0021";
								else
									ASCIIBuffer <= x"0031";
								end if;
								state <= delay;										--1
							when x"1e" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"0040";
								else
									ASCIIBuffer <= x"0032";
								end if;
								state <= delay;										--2
							when x"26" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"0023";
								else
									ASCIIBuffer <= x"0033";
								end if;
								state <= delay;										--3
							when x"25" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"0024";
								else
									ASCIIBuffer <= x"0034";
								end if;
								state <= delay;										--4
							when x"2e" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"0025";
								else
									ASCIIBuffer <= x"0035";
								end if;
								state <= delay;										--5
							when x"36" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"005e";
								else
									ASCIIBuffer <= x"0036";
								end if;
								state <= delay;										--6
							when x"3d" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"0026";
								else
									ASCIIBuffer <= x"0037";
								end if;
								state <= delay;										--7
							when x"3e" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"002a";
								else
									ASCIIBuffer <= x"0038";
								end if;
								state <= delay;										--8
							when x"46" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"0028";
								else
									ASCIIBuffer <= x"0039";
								end if;
								state <= delay;										--9
								
							--special marks
							when x"0e" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"007e";
								else
									ASCIIBuffer <= x"0060";
								end if;
								state <= delay;										--`
							when x"4e" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"005f";
								else
									ASCIIBuffer <= x"002d";
								end if;
								state <= delay;										---
							when x"55" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"002b";
								else
									ASCIIBuffer <= x"003d";
								end if;
								state <= delay;										--=
							when x"54" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"007b";
								else
									ASCIIBuffer <= x"005b";
								end if;
								state <= delay;										--[
							when x"5b" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"007d";
								else
									ASCIIBuffer <= x"005d";
								end if;
								state <= delay;										--]
							when x"5d" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"007c";
								else
									ASCIIBuffer <= x"005c";
								end if;
								state <= delay;										--\
							when x"4c" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"003a";
								else
									ASCIIBuffer <= x"003b";
								end if;
								state <= delay;										--;
							when x"52" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"0022";
								else
									ASCIIBuffer <= x"0027";
								end if;
								state <= delay;										--'
							when x"41" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"003c";
								else
									ASCIIBuffer <= x"002c";
								end if;
								state <= delay;										--,
							when x"49" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"003e";
								else
									ASCIIBuffer <= x"002e";
								end if;
								state <= delay;										--.
							when x"4a" => 
								if (shiftModifier = '1') then
									ASCIIBuffer <= x"003f";
								else
									ASCIIBuffer <= x"002f";
								end if;
								state <= delay;										--/
							
							when x"29" => 
								ASCIIBuffer <= x"0020";
								state <= delay;										--space
								
							when x"66" => 
								ASCIIBuffer <= x"007f";
								state <= delay;										--backspace
								
							when x"5a" => 
								ASCIIBuffer <= x"000a";
								state <= delay;										--enter
								
							--shift
							when x"12" => 
								LshiftModifier <= '1';
								state <= delay;										--L shift
								
							when x"59" => 
								RshiftModifier <= '1';
								state <= delay;										--R shift
								
							--control keys
							when x"58" => 
								capsModifier <= not(capsModifier);
								state <= delay;										--caps lock
								
							when x"11" => 
								ASCIIBuffer <= x"000f";
								state <= delay;										--L ALT		
								
							when x"76" => 
								ASCIIBuffer <= x"001b";
								state <= delay;										--ESC		

							when x"0d" => 
								ASCIIBuffer <= x"0009";
								state <= delay;										--TAB								
								
							--U arrow
							when x"75" => 
								ASCIIBuffer <= x"0011";
								state <= delay;
							--L arrow
							when x"6b" => 
								ASCIIBuffer <= x"0012";
								state <= delay;
							--D arrow
							when x"72" => 
								ASCIIBuffer <= x"0013";
								state <= delay;
							--R arrow
							when x"74" => 
								ASCIIBuffer <= x"0014";
								state <= delay;
								
							when others => 
								ASCIIBuffer <= x"0000";
								state <= delay;
						end case;
						KeyboardOE <= '1';
					else
						ASCIIBuffer <= x"0000";
						KeyboardOE <= '0';
						state <= delay;
					end if;
				when breakCheck =>
					if PS2_OE = '1' then
						if (PS2_CODE = x"12") then
							LshiftModifier <= '0';
						elsif (PS2_CODE = x"59") then
							RshiftModifier <= '0';
						end if;
						if (PS2_CODE = prevCode) then
							prevCode <= (others => '0');
						end if;
						ASCIIBuffer <= x"0000";
						KeyboardOE <= '1';
						state <= delay;
					end if;
				when others =>
					state <= delay;
			end case;
		end if;
	end process;
					
end kbd;
						