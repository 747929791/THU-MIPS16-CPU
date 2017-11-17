----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:00:11 11/15/2017 
-- Design Name: 
-- Module Name:    ex_mem - Behavioral 
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

entity ex_mem is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           ex_wd : in  STD_LOGIC_VECTOR (2 downto 0);
           ex_wreg : in  STD_LOGIC;
           ex_wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           mem_wd : out  STD_LOGIC_VECTOR (2 downto 0);
           mem_wreg : out  STD_LOGIC;
           mem_wdata : out  STD_LOGIC_VECTOR (15 downto 0);
			  stall : in STD_LOGIC_VECTOR(5 downto 0); --‘›Õ£–≈∫≈
			  --∑√¥Ê–≈∫≈
			  ex_mem_read : in STD_LOGIC;
			  ex_mem_write : in STD_LOGIC;
			  ex_mem_addr : in STD_LOGIC_VECTOR(15 downto 0);
			  ex_mem_wdata : in STD_LOGIC_VECTOR(15 downto 0);
			  mem_mem_read : out STD_LOGIC;
			  mem_mem_write : out STD_LOGIC;
			  mem_mem_addr : out STD_LOGIC_VECTOR(15 downto 0);
			  mem_mem_wdata : out STD_LOGIC_VECTOR(15 downto 0));
end ex_mem;

architecture Behavioral of ex_mem is

begin

	process(clk)
	begin
		if(clk'event and clk = Enable) then
			if(rst = Enable) then
				mem_wd <= "000";
				mem_wreg <= Disable;
				mem_wdata <= ZeroWord;
			   mem_mem_read <= Disable;
			   mem_mem_write <= Disable;
			   mem_mem_addr <= ZeroWord;
			   mem_mem_wdata <= ZeroWord;
			elsif(stall(3)=Stop and stall(4)=NoStop) then
				mem_wd <= "000";
				mem_wreg <= Disable;
				mem_wdata <= ZeroWord;
			   mem_mem_read <= Disable;
			   mem_mem_write <= Disable;
			   mem_mem_addr <= ZeroWord;
			   mem_mem_wdata <= ZeroWord;
			elsif(stall(3)=NoStop) then
				mem_wd <= ex_wd;
				mem_wreg <= ex_wreg;
				mem_wdata <= ex_wdata;
			   mem_mem_read <= ex_mem_read;
			   mem_mem_write <= ex_mem_write;
			   mem_mem_addr <= ex_mem_addr;
			   mem_mem_wdata <= ex_mem_wdata;
			end if;
		end if;
	end process;

end Behavioral;

