----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:44:23 11/15/2017 
-- Design Name: 
-- Module Name:    ex - Behavioral 
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

entity ex is
    Port ( rst : in  STD_LOGIC;
           alusel_i : in  STD_LOGIC_VECTOR(2 downto 0);
           aluop_i : in  STD_LOGIC_VECTOR(7 downto 0);
           reg1_i : in  STD_LOGIC_VECTOR(15 downto 0);
           reg2_i : in  STD_LOGIC_VECTOR(15 downto 0);
           wd_i : in  STD_LOGIC_VECTOR (2 downto 0);
           wreg_i : in  STD_LOGIC;
           wd_o : out  STD_LOGIC_VECTOR (2 downto 0);
           wreg_o : out  STD_LOGIC;
           wdata_o : out  STD_LOGIC_VECTOR (15 downto 0);
			  --暂停请求信号
			  stallreq : out STD_LOGIC;
			  --访存信号
			  mem_read_o : out STD_LOGIC;
			  mem_write_o : out STD_LOGIC;
			  mem_addr_o : out STD_LOGIC_VECTOR(15 downto 0);
			  mem_wdata_o : out STD_LOGIC_VECTOR(15 downto 0);
			  --指令(用于获取访存立即数)
			  inst_i : in STD_LOGIC_VECTOR(15 downto 0)
			  );
end ex;

architecture Behavioral of ex is
	signal logicout : std_logic_vector(15 downto 0);
begin
	stallreq <= NoStop; --暂时不暂停
	calc: process(rst,aluop_i,reg1_i,reg2_i,inst_i)
	begin
		if(rst = Enable) then
			logicout <= ZeroWord;
		else
			--默认值
			mem_read_o <= Disable;
			mem_write_o <= Disable;
			mem_addr_o <= ZeroWord;
			mem_wdata_o <= ZeroWord;
			case aluop_i is
				when EXE_ADDIU3_OP =>
					logicout <= reg1_i + reg2_i;
				when EXE_ADDIU_OP =>
					logicout <= reg1_i + reg2_i;
				when EXE_ADDU_OP =>
					logicout <= reg1_i + reg2_i;
				when EXE_SUBU_OP =>
					logicout <= reg1_i - reg2_i;
				when EXE_AND_OP =>
					logicout <= reg1_i and reg2_i;
				when EXE_XOR_OP =>
					logicout <= reg1_i xor reg2_i;
				when EXE_LI_OP =>
					logicout <= reg1_i;
				when EXE_MOVE_OP =>
					logicout <= reg1_i;
				when EXE_NEG_OP =>
					logicout <= reg2_i - reg1_i;
				when EXE_NOT_OP =>
					logicout <= not reg1_i;
				when EXE_OR_OP =>
					logicout <= reg1_i or reg2_i;
				when EXE_SLL_OP =>
					logicout <= to_stdlogicvector(to_bitvector(reg1_i) sll conv_integer(reg2_i));
				when EXE_SLLV_OP =>
					logicout <= to_stdlogicvector(to_bitvector(reg1_i) sll conv_integer(reg2_i));
				when EXE_SRA_OP =>
					logicout <= to_stdlogicvector(to_bitvector(reg1_i) sra conv_integer(reg2_i));
				when EXE_SRAV_OP =>
					logicout <= to_stdlogicvector(to_bitvector(reg1_i) sra conv_integer(reg2_i));
				when EXE_SRL_OP =>
					logicout <= to_stdlogicvector(to_bitvector(reg1_i) srl conv_integer(reg2_i));
				when EXE_SRLV_OP =>
					logicout <= to_stdlogicvector(to_bitvector(reg1_i) srl conv_integer(reg2_i));
				when EXE_LW =>
					mem_read_o <= Enable;
					mem_addr_o <= reg1_i + reg2_i;
				when EXE_SW =>
					mem_write_o <= Enable;
					mem_addr_o <= reg1_i + SXT(inst_i(4 downto 0),16);
					mem_wdata_o <= reg2_i;
				when others =>
					logicout <= ZeroWord;
			end case;
		end if;
	end process;
	
	sel: process(aluop_i,alusel_i,logicout,wd_i,wreg_i)
	begin
		wd_o <= wd_i;
		wreg_o <= wreg_i;
		case alusel_i is
			when EXE_RES_LOGIC =>
				wdata_o <= logicout;
			when others =>
				wdata_o <= ZeroWord;
		end case;
	end process;
end Behavioral;

