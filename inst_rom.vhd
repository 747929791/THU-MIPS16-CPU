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
		x"6800",    --LI R0 0000
		x"3000",    --SLL R0 R0 0000
		x"6905",    --LI R1 0005
		x"d820",    --SW R0 R1 0000
		x"6908",    --LI R1 0008
		x"d821",    --SW R0 R1 0001
		x"6904",    --LI R1 0004
		x"d822",    --SW R0 R1 0002
		x"6916",    --LI R1 0016
		x"d823",    --SW R0 R1 0003
		x"6902",    --LI R1 0002
		x"d824",    --SW R0 R1 0004
		x"6901",    --LI R1 0001
		x"d825",    --SW R0 R1 0005
		x"9820",    --LW R0 R1 0000
		x"4801",    --ADDIU R0 0001
		x"49ff",    --ADDIU R1 ffff
		x"7a00",    --MOVE R2 R0
		x"7b20",    --MOVE R3 R1
		x"9a80",    --LW R2 R4 0000
		x"9aa1",    --LW R2 R5 0001
		x"eca2",    --SLT R4 R5
		x"6103",    --BTNEZ 0003
		x"0800",    --NOP
		x"daa0",    --SW R2 R5 0000
		x"da81",    --SW R2 R4 0001
		x"4a01",    --ADDIU R2 0001
		x"4bff",    --ADDIU R3 ffff
		x"2bf6",    --BNEZ R3 fff6
		x"0800",    --NOP
		x"49ff",    --ADDIU R1 ffff
		x"29f1",    --BNEZ R1 fff1
		x"0800",    --NOP
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

