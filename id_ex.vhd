----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:32:35 11/15/2017 
-- Design Name: 
-- Module Name:    id_ex - Behavioral 
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
use WORK.DEFINES.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity id_ex is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           id_alusel : in  STD_LOGIC_VECTOR (2 downto 0);
           id_aluop : in  STD_LOGIC_VECTOR (7 downto 0);
           id_reg1 : in  STD_LOGIC_VECTOR (15 downto 0);
           id_reg2 : in  STD_LOGIC_VECTOR (15 downto 0);
           id_wd : in  STD_LOGIC_VECTOR (2 downto 0);
           id_wreg : in  STD_LOGIC;
           ex_alusel : out  STD_LOGIC_VECTOR (2 downto 0);
           ex_aluop : out  STD_LOGIC_VECTOR (7 downto 0);
           ex_reg1 : out  STD_LOGIC_VECTOR (15 downto 0);
           ex_reg2 : out  STD_LOGIC_VECTOR (15 downto 0);
           ex_wd : out  STD_LOGIC_VECTOR (2 downto 0);
           ex_wreg : out  STD_LOGIC;
			  stall : in STD_LOGIC_VECTOR(5 downto 0)); --ÔÝÍ£ÐÅºÅ
end id_ex;

architecture Behavioral of id_ex is

begin
	
	process(clk)
	begin
		if(clk'event and clk = Enable) then
			if(rst = Enable) then
				ex_alusel <= EXE_RES_NOP;
				ex_aluop <= EXE_NOP_OP;
				ex_reg1 <= ZeroWord;
				ex_reg2 <= ZeroWord;
				ex_wd <= "000";
				ex_wreg <= Disable;
			elsif(stall(2)=Stop and stall(3)=NoStop) then
				ex_aluop <= EXE_NOP_OP;
				ex_alusel <= EXE_RES_NOP;
				ex_reg1 <= ZeroWord;
				ex_reg2 <= ZeroWord;
				ex_wd <= "000";
				ex_wreg <= Disable;
			elsif(stall(2)=NoStop) then
				ex_alusel <= id_alusel;
				ex_aluop <= id_aluop;
				ex_reg1 <= id_reg1;
				ex_reg2 <= id_reg2;
				ex_wd <= id_wd;
				ex_wreg <= id_wreg;
			end if;
		end if;
	end process;

end Behavioral;

