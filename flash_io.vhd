----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:19:42 11/20/2017 
-- Design Name: 
-- Module Name:    flash_byte - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use WORK.DEFINES.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity flash_io is
    Port ( addr : in  STD_LOGIC_VECTOR (22 downto 1);
           data_out : out  STD_LOGIC_VECTOR (15 downto 0);
			  clk : in std_logic;
			  reset : in std_logic;
			  
			  flash_byte : out std_logic;--BYTE#
			  flash_vpen : out std_logic;
			  flash_ce : out std_logic;
			  flash_oe : out std_logic;
			  flash_we : out std_logic;
			  flash_rp : out std_logic;
			  flash_addr : out std_logic_vector(22 downto 1);
			  flash_data : inout std_logic_vector(15 downto 0);
			  
           ctl_read : in  STD_LOGIC
	);
end flash_io;

architecture Behavioral of flash_io is
	type flash_state is (
		waiting,
		read1, read2, read3, read4,
		done
	);
	signal state : flash_state := waiting;
	signal next_state : flash_state := waiting;
	
	signal ctl_read_last : std_logic;
	
	constant InstNum : integer := 100;
	type InstArray is array (0 to InstNum) of STD_LOGIC_VECTOR(15 downto 0);
	signal insts: InstArray := (
	  --01000xxxyyy0iiii 访存LWSW测试
	  --11011xxxyyyiiiii SW (Rx+imm)<-Ry
	  --10011xxxyyyiiiii SW (Rx+imm)->Ry
--		"0100000000000001", --R[0]+=1
--		"1101100100000011", --SW(R[0])->RAM[R(1)+3]
--		"1001100000100010", --LW(RAM[R[0]+2])->R[1]
--		"0100000100100001", --R[1]++
--		"0100010010000001", --R[4]++ 现在R[0]=1,R[1]=1,R[4]=1,RAM[3]=1
--		"0100000000000001", --R[0]++
--		"1101100100000011", --SW(R[0])->RAM[R(1)+3] 现在R[0]=2,R[1]=2,R[4]=1,RAM[3]=1,RAM[4]=2
		"0000100000000000", --noP
		"0110111010111111", --LI R6 00BF
		"0011011011000000", --SLL R6 R6 0000
		"0100111000000001", --ADDIU R6 0001
		"1001111000000000", --LW R6 R0 0000
		"0110111000000001", --LI R6 0001
		"1110100011001100", --AND R0 R6
		"0010000011111000", --BEQZ R0 -0008
		"0000100000000000", --noP
		"0110111010111111", --LI R6 00BF
		"0011011011000000", --SLL R6 R6 0000
		"0110100001001111", --LI R0 004F
		"1101111000000000", --SW R6 R0 0000
		"0000100000000000", --noP
		"0000100000000000", --noP
		"0110111010111111", --LI R6 00BF
		"0011011011000000", --SLL R6 R6 0000
		"0100111000000001", --ADDIU R6 0001
		"1001111000000000", --LW R6 R0 0000
		"0110111000000001", --LI R6 0001
		"1110100011001100", --AND R0 R6
		"0010000011111000", --BEQZ R0 -0008
		"0000100000000000", --noP
		"0110111010111111", --LI R6 00BF
		"0011011011000000", --SLL R6 R6 0000
		"0110100001001011", --LI R0 004B
		"1101111000000000", --SW R6 R0 0000
		"0000100000000000", --noP
		others => "0000100000000000");
	
begin

--	process(addr)
--	variable id : integer;
--	begin
--		id := conv_integer(addr);
--		data_out <= insts(id);
--	end process;

	flash_byte <= '1';
	flash_vpen <= '1';
	flash_ce <= '0';
	flash_rp <= '1';
	
	process (clk, reset, ctl_read)
	begin
		if (reset = '0') then
			flash_oe <= '1';
			flash_we <= '1';
			state <= waiting;
			next_state <= waiting;
			ctl_read_last <= ctl_read;
			flash_data <= (others => 'Z');
		elsif (clk'event and clk = '1') then
			case state is
				when waiting =>
					if (ctl_read /= ctl_read_last) then
						flash_we <= '0';
						state <= read1;
						ctl_read_last <= ctl_read;
					end if;
				when read1 =>
					flash_data <= x"00FF";
					state <= read2;
				when read2 =>
					flash_we <= '1';
					state <= read3;
				when read3 =>
					flash_oe <= '0';
					flash_addr <= addr;
					flash_data <= (others => 'Z');
					state <= read4;
				when read4 =>
					data_out <= flash_data;
					state <= done;
					
				when others =>
					flash_oe <= '1';
					flash_we <= '1';
					flash_data <= (others => 'Z');
					state <= waiting;
			end case;
		end if;
	end process;
	


end Behavioral;

