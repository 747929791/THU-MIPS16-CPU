----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:18:39 11/15/2017 
-- Design Name: 
-- Module Name:    if_id - Behavioral 
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

entity if_id is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           if_pc : in  STD_LOGIC_VECTOR (15 downto 0);
           if_inst : in  STD_LOGIC_VECTOR (15 downto 0);
           id_pc : out  STD_LOGIC_VECTOR (15 downto 0);
           id_inst : out  STD_LOGIC_VECTOR (15 downto 0);
			  stall : in STD_LOGIC_VECTOR(5 downto 0)); --ÔÝÍ£ÐÅºÅ
end if_id;

architecture Behavioral of if_id is

begin

	process(clk)
	begin
		if(clk'event and clk = Enable) then
			if(rst = Enable) then
				id_pc <= ZeroWord;
				id_inst <= ZeroWord;
			elsif(stall(1)=Stop and stall(2)=NoStop) then
				id_pc <= ZeroWord;
				id_inst <= NopInst;
			elsif(stall(1)=NoStop)then
				id_pc <= if_pc;
				id_inst <= if_inst;
			end if;
		end if;
	end process;
end Behavioral;

