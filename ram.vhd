----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:11:02 11/17/2017 
-- Design Name: 
-- Module Name:    ram - Behavioral 
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

entity ram is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           re : in  STD_LOGIC;
           we : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
           wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           rdata : out  STD_LOGIC_VECTOR (15 downto 0));
end ram;

architecture Behavioral of ram is

type MemArray is array (63 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
signal rams: MemArray := (others => ZeroWord);
begin

	WriteOperator : process(clk)
	begin
		if(clk'event and clk = Enable) then
			if(rst = Disable) then
				if(we = Enable) then
					rams(conv_integer(addr)) <= wdata;
				end if;
			end if;
		end if;
	end process;

	READ : process(rst,re,addr,we,wdata,rams)
	begin
		if(rst = Enable) then
			rdata <= ZeroWord;
		elsif(re = Disable) then
			rdata <= ZeroWord;
		else
			rdata <= rams(conv_integer(addr));
		end if;
	end process;
	
end Behavioral;

