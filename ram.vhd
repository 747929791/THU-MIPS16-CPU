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
			  Ram2Addr: out STD_LOGIC_VECTOR(17 downto 0);
			  Ram2Data: inout STD_LOGIC_VECTOR(15 downto 0);
			  Ram2OE: out STD_LOGIC;
			  Ram2WE: out STD_LOGIC;
			  Ram2EN: out STD_LOGIC;
           rdata : out  STD_LOGIC_VECTOR (15 downto 0));
end ram;

architecture Behavioral of ram is

type MemArray is array (0 to 63) of STD_LOGIC_VECTOR(15 downto 0);
signal rams: MemArray := (others => ZeroWord);
begin
	Ram2EN <= '0';
	Ram2OE <= we;
	Ram2WE <= clk or not(we);
	Ram2Addr <= "00" & addr;
	
	WriteOperator : process(clk,addr)
	begin
		if(clk'event and clk = Enable) then
			if(rst = Disable) then
				if(we = Enable) then
					Ram2Data <= wdata;
				end if;
			end if;
		end if;
	end process;

	READ : process(rst,re,addr,we,wdata,rams,Ram2Data)
	begin
		if(rst = Enable) then
			rdata <= ZeroWord;
		elsif(re = Disable) then
			rdata <= ZeroWord;
		else
			rdata <= Ram2Data;
		end if;
	end process;
	
end Behavioral;

