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
    Port ( rst : in  STD_LOGIC; --��λ�ź�
           clk : in  STD_LOGIC; --ʱ���ź�
           pc_o : out  STD_LOGIC_VECTOR (15 downto 0); --Ҫ��ȡ��ָ���ַ
           ce_o : out  STD_LOGIC; --ָ��洢��ʹ��
			  pc_plus_1: out STD_LOGIC_VECTOR(15 downto 0); --ID��ʹ�õ��źţ����ܼ���
			  stall : in STD_LOGIC_VECTOR(5 downto 0); --��ͣ�ź�
			  branch_flag_i : in STD_LOGIC; --�Ƿ���ת�ź�
			  branch_target_address_i : in STD_LOGIC_VECTOR(15 downto 0)
		);
end pc;

 architecture Behavioral of pc is
signal ce : STD_LOGIC;
signal pc : STD_LOGIC_VECTOR (15 downto 0); --Ҫ��ȡ��ָ���ַ
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

