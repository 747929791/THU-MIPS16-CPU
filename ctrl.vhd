----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:29:11 11/16/2017 
-- Design Name: 
-- Module Name:    ctrl - Behavioral 
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

entity ctrl is
    Port ( rst : in  STD_LOGIC;
           stallreq_from_if : in  STD_LOGIC;
           stallreq_from_id : in  STD_LOGIC;
           stallreq_from_ex : in  STD_LOGIC;
           stallreq_from_mem : in  STD_LOGIC;
           stall : out  STD_LOGIC_VECTOR (5 downto 0));
end ctrl;

architecture Behavioral of ctrl is

begin

	process(rst,stallreq_from_if,stallreq_from_id,stallreq_from_ex, stallreq_from_mem)
	begin
		if(rst = Enable) then
			stall <= "000000";
		elsif(stallreq_from_mem = Stop) then
			stall <= "011111";
		elsif(stallreq_from_ex = Stop) then
			stall <= "001111";
		elsif(stallreq_from_id = Stop) then
			stall <= "000111";
		elsif(stallreq_from_if = Stop) then
			stall <= "000011";
		else
			stall <= "000000";
		end if;
	end process;

end Behavioral;

