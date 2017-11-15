----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:58:20 11/15/2017 
-- Design Name: 
-- Module Name:    id - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use WORK.DEFINES.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity id is
    Port ( rst : in  STD_LOGIC;
           pc_i : in  STD_LOGIC_VECTOR (15 downto 0);
           inst_i : in  STD_LOGIC_VECTOR (15 downto 0);
           reg1_data_i : in  STD_LOGIC_VECTOR (15 downto 0);
           reg2_data_i : in  STD_LOGIC_VECTOR (15 downto 0);
           reg1_read_o : out  STD_LOGIC;
           reg2_read_o : out  STD_LOGIC;
           reg1_addr_o : out  STD_LOGIC_VECTOR (2 downto 0);
           reg2_addr_o : out  STD_LOGIC_VECTOR (2 downto 0);
           aluop_o : out  STD_LOGIC_VECTOR (7 downto 0);
           alusel_o : out  STD_LOGIC_VECTOR (2 downto 0);
           reg1_o : out  STD_LOGIC_VECTOR (15 downto 0);
           reg2_o : out  STD_LOGIC_VECTOR (15 downto 0);
           wd_o : out  STD_LOGIC_VECTOR (2 downto 0);
           wreg_o : out  STD_LOGIC);
end id;

architecture Behavioral of id is
signal imm:STD_LOGIC_VECTOR(15 downto 0);
signal instvalid:STD_LOGIC; --指令是否有效
--内部信号
signal reg1_read_e,reg2_read_e:STD_LOGIC;
begin
	reg1_read_o <= reg1_read_e;
	reg2_read_o <= reg2_read_e;
	
	--译码
	id_process : process(rst,pc_i,inst_i,reg1_data_i,reg2_data_i)
		variable op:STD_LOGIC_VECTOR(4 downto 0);
		variable rx,ry,rz:STD_LOGIC_VECTOR(2 downto 0);
		variable imm4:STD_LOGIC_VECTOR(3 downto 0);
		variable imm8:STD_LOGIC_VECTOR(7 downto 0);
	begin
		if(rst = Enable) then
			reg1_read_e <= Disable;
			reg2_read_e <= Disable;
			reg1_addr_o <= "000";
			reg2_addr_o <= "000";
			aluop_o <= EXE_NOP_OP;
			alusel_o <= EXE_RES_NOP;
			wd_o <= "000";
			wreg_o <= Disable;
			instvalid <= Disable;
		else
			op := inst_i(15 downto 11);
			rx := inst_i(10 downto 8);
			ry := inst_i(7 downto 5);
			rz := inst_i(4 downto 2);
			imm4 := inst_i(3 downto 0);
			imm8 := inst_i(7 downto 0);
			case op is
				when "01000" => --ADDIU3
					wreg_o <= Enable;
					aluop_o <= EXE_ADDIU3_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Enable;
					reg2_read_e <= Disable;
					wd_o <=ry;
					instvalid <= Enable;
					imm <= SXT(imm4,16);
				when others =>
					reg1_read_e <= Disable;
					reg2_read_e <= Disable;
					reg1_addr_o <= "000";
					reg2_addr_o <= "000";
					aluop_o <= EXE_NOP_OP;
					alusel_o <= EXE_RES_NOP;
					wd_o <= "000";
					wreg_o <= Disable;
					instvalid <= Disable;
			end case;
		end if;
	end process;

	--确定源操作数1
	reg1_process : process(rst,reg1_data_i,imm,reg1_read_e)
	begin
		if(rst = Enable) then
			reg1_o <= ZeroWord;
		elsif(reg1_read_e = Enable) then
			reg1_o <= reg1_data_i;
		elsif(reg1_read_e = Disable) then
			reg1_o<=imm;
		else
			reg1_o<=ZeroWord;
		end if;
	end process;

	--确定源操作数2
	reg2_process : process(rst,reg2_data_i,imm,reg2_read_e)
	begin
		if(rst = Enable) then
			reg2_o <= ZeroWord;
		elsif(reg2_read_e = Enable) then
			reg2_o <= reg2_data_i;
		elsif(reg2_read_e = Disable) then
			reg2_o<=imm;
		else
			reg2_o<=ZeroWord;
		end if;
	end process;

end Behavioral;

