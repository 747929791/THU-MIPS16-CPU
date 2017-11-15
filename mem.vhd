----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:04:53 11/15/2017 
-- Design Name: 
-- Module Name:    mem - Behavioral 
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

entity mem is
    Port ( rst : in  STD_LOGIC;
           wd_i : in  STD_LOGIC_VECTOR (2 downto 0);
           wreg_i : in  STD_LOGIC;
           wdata_i : in  STD_LOGIC_VECTOR (15 downto 0);
           wd_o : out  STD_LOGIC_VECTOR (2 downto 0);
           wreg_o : out  STD_LOGIC;
           wdata_o : out  STD_LOGIC_VECTOR (15 downto 0));
end mem;

architecture Behavioral of mem is

begin

	process(rst,wd_i,wreg_i,wdata_i)
	begin
		if(rst = Enable) then
			wd_o <= "000";
			wreg_o <= Disable;
			wdata_o <= ZeroWord;
		else
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
		end if;
	end process;

end Behavioral;

