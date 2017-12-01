----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:03:13 11/15/2017 
-- Design Name: 
-- Module Name:    pc - Behavioral 
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

entity pc is
    Port ( rst : in  STD_LOGIC; --复位信号
           clk : in  STD_LOGIC; --时钟信号
           pc_o : out  STD_LOGIC_VECTOR (15 downto 0); --要读取的指令地址
           ce_o : out  STD_LOGIC; --指令存储器使能
			  pc_plus_1: out STD_LOGIC_VECTOR(15 downto 0); --ID段使用的信号，性能加速
			  stall : in STD_LOGIC_VECTOR(5 downto 0); --暂停信号
			  branch_flag_i : in STD_LOGIC; --是否跳转信号
			  branch_target_address_i : in STD_LOGIC_VECTOR(15 downto 0)
		);
end pc;

 architecture Behavioral of pc is
signal ce : STD_LOGIC;
signal pc : STD_LOGIC_VECTOR (15 downto 0); --要读取的指令地址
begin
	ce_o <= ce;
	pc_o <= pc;
	pc_plus_1<=pc+1;
	
	CE_PROCESS : process(clk)
	begin
		if(clk'event and clk = Enable) then
			if(rst = Enable) then
				ce <= Disable;
			else
				ce <= Enable;
			end if;
		end if;
	end process;
	
	PC_PROCESS : process(clk)
	begin
		if(clk'event and clk = Enable) then
			if(ce = Disable) then
				pc <= ZeroWord;
			elsif(stall(0) = NoStop) then
				if(branch_flag_i = Enable) then
					pc <= branch_target_address_i;
				else
					pc <= pc + 1;
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;

