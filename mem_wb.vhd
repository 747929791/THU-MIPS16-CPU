----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:09:47 11/15/2017 
-- Design Name: 
-- Module Name:    mem_wb - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_wb is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           mem_wd : in  STD_LOGIC_VECTOR (2 downto 0);
           mem_wreg : in  STD_LOGIC;
           mem_wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           wb_wd : out  STD_LOGIC_VECTOR (2 downto 0);
           wb_wreg : out  STD_LOGIC;
           wb_wdata : out  STD_LOGIC_VECTOR (15 downto 0));
end mem_wb;

architecture Behavioral of mem_wb is

begin

	process(clk)
	begin
		if(clk'event and clk = Enable) then
			if(rst = Enable) then
				wb_wd <= "000";
				wb_wreg <= Disable;
				wb_wdata <= ZeroWord;
			else
				wb_wd <= mem_wd;
				wb_wreg <= mem_wreg;
				wb_wdata <= mem_wdata;
			end if;
		end if;
	end process;

end Behavioral;

