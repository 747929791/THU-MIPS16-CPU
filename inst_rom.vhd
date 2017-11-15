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
	type InstArray is array (InstNum downto 0) of STD_LOGIC_VECTOR(15 downto 0);
	signal insts: InstArray := (
	  --01000xxxyyy0iiii
		"0100000000100101",
		"0100000001001111",
		"0100000001100001",
		"0100000010001101",
		others => ZeroWord);
begin
	process(ce,addr)
		variable id : integer;
	begin
		if(ce = Enable) then
			id:=conv_integer(addr)/2;
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

