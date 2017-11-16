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
			sub_op := inst_i(4 downto 0);
			sub_op2 := inst_i(1 downto 0);
			rx := inst_i(10 downto 8);
			ry := inst_i(7 downto 5);
			rz := inst_i(4 downto 2);
			imm3 := inst_i(4 downto 2);
			imm4 := inst_i(3 downto 0);
			imm8 := inst_i(7 downto 0);
			case op is
				when "01000" => --ADDIU3
					wreg_o <= Enable;
					aluop_o <= EXE_ADDIU3_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Enable;
					reg2_read_e <= Disable;
					reg1_addr_o <= rx;
					wd_o <=ry;
					instvalid <= Enable;
					imm <= SXT(imm4,16);
				when "01001" => --ADDIU
					wreg_o <= Enable;
					aluop_o <= EXE_ADDIU_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Enable;
					reg2_read_e <= Disable;
					reg1_addr_o <= rx;
					wd_o <=rx;
					instvalid <= Enable;
					imm <= SXT(imm8,16);
				when "11100" => 
					case sub_op2 is
						when "01" => --ADDU
							wreg_o <= Enable;
							aluop_o <= EXE_ADDU_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							reg1_addr_o <= rx;
							reg2_addr_o <= ry;
							wd_o <=rz;
							instvalid <= Enable;
						when "11" => --SUBU
							wreg_o <= Enable;
							aluop_o <= EXE_SUBU_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							reg1_addr_o <= rx;
							reg2_addr_o <= ry;
							wd_o <=rz;
							instvalid <= Enable;
						when others =>
					end case;
				when "01101" => --LI
					wreg_o <= Enable;
					aluop_o <= EXE_LI_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Disable;
					reg2_read_e <= Disable;
					wd_o <=rx;
					instvalid <= Enable;
					imm <= EXT(imm8, 16);
				when "01111" => --MOVE
					wreg_o <= Enable;
					aluop_o <= EXE_MOVE_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Enable;
					reg2_read_e <= Disable;
					reg1_addr_o <= ry;
					imm <= ZeroWord;
					wd_o <=rx;
					instvalid <= Enable;
				when "11101" => 
					case sub_op is
						when "01100" => --AND
							wreg_o <= Enable;
							aluop_o <= EXE_AND_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							reg1_addr_o <= rx;
							reg2_addr_o <= ry;
							wd_o <=rx;
							instvalid <= Enable;
						when "01110" => --XOR
							wreg_o <= Enable;
							aluop_o <= EXE_XOR_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							reg1_addr_o <= rx;
							reg2_addr_o <= ry;
							wd_o <=rx;
							instvalid <= Enable;
						when "01011" => --NEG
							wreg_o <= Enable;
							aluop_o <= EXE_NEG_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Disable;
							reg1_addr_o <= rx;
							wd_o <=rx;
							instvalid <= Enable;
							imm <= ZeroWord;
						when "01111" => --NOT
							wreg_o <= Enable;
							aluop_o <= EXE_NOT_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Disable;
							wd_o <=rx;
							reg1_addr_o <= rx;
							imm <= ZeroWord;
							instvalid <= Enable;
						when "01101" => --OR
							wreg_o <= Enable;
							aluop_o <= EXE_OR_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							wd_o <=rx;
							reg1_addr_o <= rx;
							reg2_addr_o <= ry;
							instvalid <= Enable;
						case sub_op2 is 
						when "00100" => --SLLV
							wreg_o <= Enable;
							aluop_o <= EXE_SLLV_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							wd_o <=ry;
							reg1_addr_o <= ry;
							reg2_addr_o <= rx;
							instvalid <= Enable; 						
						when "00111" => --SRAV
							wreg_o <= Enable;
							aluop_o <= EXE_SRAV_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							wd_o <=ry;
							reg1_addr_o <= ry;
							reg2_addr_o <= rx;
							instvalid <= Enable;
						when "00110" => --SRLV
							wreg_o <= Enable;
							aluop_o <= EXE_SRLV_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							wd_o <=ry;
							reg1_addr_o <= ry;
							reg2_addr_o <= rx;
							instvalid <= Enable;
						when others =>
					end case;
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
				when "00110" => 
					case sub_op2 is
						when "00" => --SLL
							wreg_o <= Enable;
							aluop_o <= EXE_SLL_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Disable;
							wd_o <=rx;
							reg1_addr_o <= ry;
							if(imm3 = "000") then
								imm <= EXT("1000", 16);
							else
								imm <= EXT(imm3, 16);
							end if;
							instvalid <= Enable;
						when "11" => --SRA
							wreg_o <= Enable;
							aluop_o <= EXE_SRA_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Disable;
							wd_o <=rx;
							reg1_addr_o <= ry;
							if(imm3 = "000") then
								imm <= EXT("1000", 16);
							else
								imm <= EXT(imm3, 16);
							end if;
							instvalid <= Enable;
						when "10" => --SRL
							wreg_o <= Enable;
							aluop_o <= EXE_SRL_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Disable;
							wd_o <=rx;
							reg1_addr_o <= ry;
							if(imm3 = "000") then
								imm <= EXT("1000", 16);
							else
								imm <= EXT(imm3, 16);
							end if;
							instvalid <= Enable;
						when others =>
					end case;
					
				when "11101" =>
					
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

