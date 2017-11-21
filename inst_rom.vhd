----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:31:04 11/15/2017 
-- Design Name: 
-- Module Name:    inst_rom - Behavioral 
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

--Ö¸Áî´æ´¢Æ÷ROMÄ£ÄâÄ£¿é
entity inst_rom is
    Port ( ce : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
           inst : out  STD_LOGIC_VECTOR (15 downto 0));
end inst_rom;
architecture Behavioral of inst_rom is
	constant InstNum : integer := 100;
	type InstArray is array (0 to InstNum) of STD_LOGIC_VECTOR(15 downto 0);
	signal insts: InstArray := (
		--BNEQZ²âÊÔ
		"0110101000000011", --LI R[2], 3
		"1110101001001011", --NEG R[2], R[2]
		"0110100000000100", --LI R[0], 4
		"1110100000001011", --NEG R[0], R[0]
		"0100000000000001", --R[0]++
		"0010100011111110", --BNEQZ(R[0])  PC<-PC-3
		"0100000100100001", --R[1]++
		"0100001101100001", --R[3]++
		others => NopInst);
begin
	process(ce,addr)
		variable id : integer;
	begin
		if(ce = Enable) then
			id:=conv_integer(addr);
			if(id>InstNum) then
				inst <= ZeroWord;
			else
				inst <= insts(id);
			end if;
		else
			inst <= ZeroWord;
		end if;
	end process;
end Behavioral;

