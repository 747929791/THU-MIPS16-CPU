----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:13:48 11/21/2017 
-- Design Name: 
-- Module Name:    flash_sim - Behavioral 
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

entity flash_sim is
   Port ( flash_addr : in std_logic_vector(22 downto 1);
			 flash_data : out std_logic_vector(15 downto 0)
	);
end flash_sim;

architecture Behavioral of flash_sim is
	constant InstNum : integer := 100;
	type InstArray is array (0 to InstNum) of STD_LOGIC_VECTOR(15 downto 0);
	signal insts: InstArray := (
	  --01000xxxyyy0iiii 访存LWSW测试
	  --11011xxxyyyiiiii SW (Rx+imm)<-Ry
	  --10011xxxyyyiiiii SW (Rx+imm)->Ry
		"0100000000000001", --R[0]+=1
		"1101100100000011", --SW(R[0])->RAM[R(1)+3]
		"1001100000100010", --LW(RAM[R[0]+2])->R[1]
		"0100000100100001", --R[1]++
		"0100010010000001", --R[4]++ 现在R[0]=1,R[1]=1,R[4]=1,RAM[3]=1
		"0100000000000001", --R[0]++
		"1101100100000011", --SW(R[0])->RAM[R(1)+3] 现在R[0]=2,R[1]=2,R[4]=1,RAM[3]=1,RAM[4]=2
		others => ZeroWord);
begin
	process(flash_addr)
	variable id : integer;
	begin
		id := conv_integer(flash_addr);
		flash_data <= insts(id);
	end process;
end Behavioral;

