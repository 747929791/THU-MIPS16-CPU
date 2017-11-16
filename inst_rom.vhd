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

--指令存储器ROM模拟模块
entity inst_rom is
    Port ( ce : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
           inst : out  STD_LOGIC_VECTOR (15 downto 0));
end inst_rom;
architecture Behavioral of inst_rom is
	constant InstNum : integer := 100;
	type InstArray is array (0 to InstNum) of STD_LOGIC_VECTOR(15 downto 0);
	signal insts: InstArray := (
	  --01000xxxyyy0iiii 转移BEQZ测试
		"0100000101000000", --R[2]=R[1]
		"0100000000100000", --R[1]=R[0]
		"0100000000000001", --R[0]++
		"0010001011111100", --BEQZ(R[2])  PC<-PC-4
		"0100000000000001", --R[0]++
		"0100000010000001", --R[4]++ 现在R[0]=6,R[1]=4,R[2]=2,R[4]=7
		others => ZeroWord);
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

