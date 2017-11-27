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
           wd_i : in  STD_LOGIC_VECTOR (3 downto 0);
           wreg_i : in  STD_LOGIC;
           wdata_i : in  STD_LOGIC_VECTOR (15 downto 0);
           wd_o : out  STD_LOGIC_VECTOR (3 downto 0);
           wreg_o : out  STD_LOGIC;
           wdata_o : out  STD_LOGIC_VECTOR (15 downto 0);
			  --访存信号
			  mem_read_i : in STD_LOGIC;
			  mem_write_i : in STD_LOGIC;
			  mem_addr_i : in STD_LOGIC_VECTOR(15 downto 0);
			  mem_wdata_i : in STD_LOGIC_VECTOR(15 downto 0);
			  --存储器信号
			  mem_rdata_i : in STD_LOGIC_VECTOR(15 downto 0);
			  mem_read_o : out STD_LOGIC;
			  mem_write_o : out STD_LOGIC;
			  mem_addr_o : out STD_LOGIC_VECTOR(15 downto 0);
			  mem_wdata_o : out STD_LOGIC_VECTOR(15 downto 0);
			  mem_ce_o : out STD_LOGIC);
end mem;

architecture Behavioral of mem is
	signal ce : STD_LOGIC;
begin
	mem_ce_o <= ce;
	process(rst,wd_i,wreg_i,wdata_i,mem_read_i,mem_write_i,mem_addr_i,mem_wdata_i,mem_rdata_i)
	begin
		if(rst = Enable) then
			wd_o <= RegAddrZero;
			wreg_o <= Disable;
			wdata_o <= ZeroWord;
			mem_read_o <= Disable;
			mem_write_o <= Disable;
			mem_addr_o <= ZeroWord;
			mem_wdata_o <= ZeroWord;
			ce<=Disable;
		else
			--默认值
			wd_o <= RegAddrZero;
			wreg_o <= Disable;
			wdata_o <= ZeroWord;
			mem_read_o <= mem_read_i;
			mem_write_o <= mem_write_i;
			if(mem_read_i = Enable) then --Load指令
				wd_o <= wd_i;
				wreg_o <= wreg_i;
				wdata_o <= mem_rdata_i;
				mem_addr_o <= mem_addr_i;
				ce<=Enable;
			elsif(mem_write_i = Enable)then --Save指令
				mem_addr_o <= mem_addr_i;
				mem_wdata_o <= mem_wdata_i;
				ce<=Enable;
			else --非Load_Save指令
				wd_o <= wd_i;
				wreg_o <= wreg_i;
				wdata_o <= wdata_i;
				ce<=Disable;
			end if;
		end if;
	end process;

end Behavioral;

