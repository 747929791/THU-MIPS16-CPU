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

--À©Õ¹¼Ä´æÆ÷¶Ñ£¬0~7ÎªÍ¨ÓÃ¼Ä´æÆ÷£¬8~15Îª×¨ÓÃ¼Ä´æÆ÷
entity regfile is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
		   LED : out STD_LOGIC_VECTOR(15 downto 0);
           waddr : in  STD_LOGIC_VECTOR (3 downto 0);
           wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           we : in  STD_LOGIC;
           raddr1 : in  STD_LOGIC_VECTOR (3 downto 0);
           re1 : in  STD_LOGIC;
           rdata1 : out  STD_LOGIC_VECTOR (15 downto 0);
           raddr2 : in  STD_LOGIC_VECTOR (3 downto 0);
           re2 : in  STD_LOGIC;
           rdata2 : out  STD_LOGIC_VECTOR (15 downto 0));
end regfile;

architecture Behavioral of regfile is
type RegArray is array (0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
signal regs: RegArray := (others => ZeroWord);
begin

--	LED(15 downto 14) <= regs(7)(1 downto 0);
--	LED(13 downto 12) <= regs(6)(1 downto 0);
--	LED(11 downto 10) <= regs(5)(1 downto 0);
--	LED(9 downto 8) <= regs(4)(1 downto 0);
--	LED(7 downto 6) <= regs(3)(1 downto 0);
--	LED(5 downto 4) <= regs(2)(1 downto 0);
--	LED(3 downto 2) <= regs(1)(1 downto 0);
--	LED(1 downto 0) <= regs(0)(1 downto 0);

	LED(15 downto 8) <= regs(6)(7 downto 0);
	LED(7 downto 0) <= regs(0)(7 downto 0);

	WriteOperator : process(clk)
	begin
		if(clk'event and clk = Enable) then
			if(rst = Disable) then
				if(we = Enable) then
					regs(conv_integer(waddr)) <= wdata;
				end if;
			end if;
		end if;
	end process;

	READ1 : process(rst,re1,raddr1,waddr,we,wdata,regs)
	begin
		if(rst = Enable) then
			rdata1 <= ZeroWord;
		elsif(re1 = Disable) then
			rdata1 <= ZeroWord;
		elsif((raddr1 = waddr) and (we = Enable)) then
			rdata1 <= wdata;
		else
			rdata1 <= regs(conv_integer(raddr1));
		end if;
	end process;

	READ2 : process(rst,re2,raddr2,waddr,we,wdata,regs)
	begin
		if(rst = Enable) then
			rdata2 <= ZeroWord;
		elsif(re2 = Disable) then
			rdata2 <= ZeroWord;
		elsif((raddr2 = waddr) and (we = Enable)) then
			rdata2 <= wdata;
		else
			rdata2 <= regs(conv_integer(raddr2));
		end if;
	end process;
end Behavioral;

