----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:06:40 11/15/2017 
-- Design Name: 
-- Module Name:    regfile - Behavioral 
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

entity regfile is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           waddr : in  STD_LOGIC_VECTOR (2 downto 0);
           wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           we : in  STD_LOGIC;
           raddr1 : in  STD_LOGIC_VECTOR (2 downto 0);
           re1 : in  STD_LOGIC;
           rdata1 : out  STD_LOGIC_VECTOR (15 downto 0);
           raddr2 : in  STD_LOGIC;
           re2 : in  STD_LOGIC;
           rdata2 : out  STD_LOGIC_VECTOR (15 downto 0));
end regfile;

architecture Behavioral of regfile is
type RegArray is array (7 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
signal regs: RegArray := (ZeroWord);
begin

	WriteOperator : process(clk)
	begin
		if(clk'event and clk = Enable) then
			if(rst = Disable) then
				if(we = Enable) then
					regs(warrd) <= wdata;
				end if;
			end if;
		end if;
	end process;

	READ1 : process(rst,re1,raddr1,waddr,we)
	begin
		if(rst = Enable) then
			rdata1 <= ZeroWord;
		elsif(re1 = Disable) then
			rdata1 <= ZeroWord;
		elsif((raddr1 = waddr) and (we = Enable)) then
			rdata1 <= wdata;
		else
			rdata1 <= regs(raddr1);
		end if;
	end process;

	READ2 : process(rst,re2,raddr2,waddr,we)
	begin
		if(rst = Enable) then
			rdata2 <= ZeroWord;
		elsif(re2 = Disable) then
			rdata2 <= ZeroWord;
		elsif((raddr2 = waddr) and (we = Enable)) then
			rdata2 <= wdata;
		else
			rdata2 <= regs(raddr2);
		end if;
	end process;
end Behavioral;

