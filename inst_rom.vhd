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
           inst : out  STD_LOGIC_VECTOR (15 downto 0);
			  ready : out STD_LOGIC);

end inst_rom;
architecture Behavioral of inst_rom is
	constant InstNum : integer := 100;
	type InstArray is array (0 to InstNum) of STD_LOGIC_VECTOR(15 downto 0);
	signal insts: InstArray := (
		--LW_SW_MT_MF_TEST
		"0110100000000101", --LI R[0], 5
		"0110100100000100", --LI R[1], 4
		"0110101000000011", --LI R[2], 3
		"1101100000100001", --SW R[0], R[1], 1
		"1001100001100001", --LW R[0], R[3], 1
		"0110010001000001", --MTSP R[2]
		"1111000000000001", --MTIH R[0]
		"0110001100000010", --ADDSP 2
		"1101000000000101", --SW_SP R[0], 5
		"1001001100000101", --LW_SP R[3], 5
		"1111010000000000", --MFIH R[4]
		"1110110101000000", --MFPC R[5]
		others => NopInst);
begin
	process(ce,addr)
		variable id : integer;
	begin
		ready <= '1';
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

