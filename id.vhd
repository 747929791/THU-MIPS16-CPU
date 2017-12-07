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

entity id is
    Port ( rst : in  STD_LOGIC;
           pc_i : in  STD_LOGIC_VECTOR (15 downto 0);
           inst_i : in  STD_LOGIC_VECTOR (15 downto 0);
			  previous_inst_i : in STD_LOGIC_VECTOR (15 downto 0);
           reg1_data_i : in  STD_LOGIC_VECTOR (15 downto 0);
           reg2_data_i : in  STD_LOGIC_VECTOR (15 downto 0);
           reg1_read_o : out  STD_LOGIC;
           reg2_read_o : out  STD_LOGIC;
           reg1_addr_o : out  STD_LOGIC_VECTOR (3 downto 0);
           reg2_addr_o : out  STD_LOGIC_VECTOR (3 downto 0);
           aluop_o : out  STD_LOGIC_VECTOR (7 downto 0);
           alusel_o : out  STD_LOGIC_VECTOR (2 downto 0);
           reg1_o : out  STD_LOGIC_VECTOR (15 downto 0);
           reg2_o : out  STD_LOGIC_VECTOR (15 downto 0);
           wd_o : out  STD_LOGIC_VECTOR (3 downto 0);
           wreg_o : out  STD_LOGIC;
			  --数据旁路技术需要的ex与mem阶段的信号
			  ex_wreg_i : in STD_LOGIC;
			  ex_wd_i : in STD_LOGIC_VECTOR(3 downto 0);
			  ex_wdata_i : in STD_LOGIC_VECTOR(15 downto 0);
			  mem_wreg_i : in STD_LOGIC;
			  mem_wd_i : in STD_LOGIC_VECTOR(3 downto 0);
			  mem_wdata_i : in STD_LOGIC_VECTOR(15 downto 0);
			  --暂停请求信号
			  stallreq : out STD_LOGIC;
			  --PC跳转信号
			  branch_flag_o : out STD_LOGIC;
			  branch_target_address_o : out STD_LOGIC_VECTOR(15 downto 0);
			  --供访存储的指令信号
			  inst_o : out STD_LOGIC_VECTOR(15 downto 0);
			  --ex阶段aluop信号检测Load相关
			  ex_aluop_i : in STD_LOGIC_VECTOR(7 downto 0);
			  
			  int_enable : out STD_LOGIC
			  );
end id;

architecture Behavioral of id is
signal imm:STD_LOGIC_VECTOR(15 downto 0);
signal instvalid:STD_LOGIC; --指令是否有效
signal int_enable_sig :std_logic := '1';
--内部信号
signal reg1_read_e,reg2_read_e:STD_LOGIC;
signal reg1_addr,reg2_addr:STD_LOGIC_VECTOR(3 downto 0);
signal reg1_data,reg2_data:STD_LOGIC_VECTOR(15 downto 0); --考虑旁路取得的正确reg_data
begin
	inst_o <= inst_i;
	int_enable <= int_enable_sig;
	reg1_read_o <= reg1_read_e;
	reg2_read_o <= reg2_read_e;
	reg1_addr_o <= reg1_addr;
	reg2_addr_o <= reg2_addr;
	--译码
	id_process : process(rst,pc_i,inst_i,reg1_data,imm)
		variable op : STD_LOGIC_VECTOR(4 downto 0);
		variable sub_op : STD_LOGIC_VECTOR(4 downto 0);
		variable sub_op2 : STD_LOGIC_VECTOR(1 downto 0);
		variable rx, ry, rz : STD_LOGIC_VECTOR(3 downto 0);
		variable imm3 : STD_LOGIC_VECTOR(2 downto 0);
		variable imm4 : STD_LOGIC_VECTOR(3 downto 0);
		variable imm5 : STD_LOGIC_VECTOR(4 downto 0);
		variable imm8 : STD_LOGIC_VECTOR(7 downto 0);
		variable imm11 : std_logic_vector(10 downto 0);
		variable pc_plus_1 : STD_LOGIC_VECTOR(15 downto 0);
	begin
		if(rst = Enable) then
			reg1_read_e <= Disable;
			reg2_read_e <= Disable;
			reg1_addr <= RegAddrZero;
			reg2_addr <= RegAddrZero;
			aluop_o <= EXE_NOP_OP;
			alusel_o <= EXE_RES_NOP;
			wd_o <= RegAddrZero;
			wreg_o <= Disable;
			instvalid <= Disable;
			int_enable_sig <= '1';
		else
			op := inst_i(15 downto 11);
			sub_op := inst_i(4 downto 0);
			sub_op2 := inst_i(1 downto 0);
			rx := "0"&inst_i(10 downto 8);
			ry := "0"&inst_i(7 downto 5);
			rz := "0"&inst_i(4 downto 2);
			imm3 := inst_i(4 downto 2);
			imm4 := inst_i(3 downto 0);
			imm5 := inst_i(4 downto 0);
			imm8 := inst_i(7 downto 0);
			imm11 := inst_i(10 downto 0);
			--默认参数
			reg1_read_e <= Disable;
			reg2_read_e <= Disable;
			--reg1_addr_o <= "000";
			--reg2_addr_o <= "000";
			aluop_o <= EXE_NOP_OP;
			alusel_o <= EXE_RES_NOP;
			wd_o <= RegAddrZero;
			wreg_o <= Disable;
			branch_flag_o <= Disable;
			branch_target_address_o <= ZeroWord;
			instvalid <= Disable;
			pc_plus_1 := pc_i + "0000000000000001";
			case op is
				when "01000" => --ADDIU3
					wreg_o <= Enable;
					aluop_o <= EXE_ADDIU3_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Enable;
					reg1_addr <= rx;
					reg2_read_e <= Disable;
					wd_o <=ry;
					instvalid <= Enable;
					imm <= SXT(imm4,16);
				when "01001" => --ADDIU
					wreg_o <= Enable;
					aluop_o <= EXE_ADDIU_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Enable;
					reg2_read_e <= Disable;
					reg1_addr <= rx;
					wd_o <=rx;
					instvalid <= Enable;
					imm <= SXT(imm8,16);
				when "00000" => --ADDSP3
					wreg_o <= Enable;
					aluop_o <= EXE_ADDSP3_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Enable;
					reg1_addr <= SP_REGISTER;
					reg2_read_e <= Disable;
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
							reg1_addr <= rx;
							reg2_addr <= ry;
							wd_o <=rz;
							instvalid <= Enable;
						when "11" => --SUBU
							wreg_o <= Enable;
							aluop_o <= EXE_SUBU_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							reg1_addr <= rx;
							reg2_addr <= ry;
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
					reg1_addr <= ry;
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
							reg1_addr <= rx;
							reg2_addr <= ry;
							wd_o <=rx;
							instvalid <= Enable;
						when "01110" => --XOR
							wreg_o <= Enable;
							aluop_o <= EXE_XOR_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							reg1_addr <= rx;
							reg2_addr <= ry;
							wd_o <=rx;
							instvalid <= Enable;
						when "01011" => --NEG
							wreg_o <= Enable;
							aluop_o <= EXE_NEG_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Disable;
							reg1_addr <= ry;
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
							reg1_addr <= ry;
							imm <= ZeroWord;
							instvalid <= Enable;
						when "01101" => --OR
							wreg_o <= Enable;
							aluop_o <= EXE_OR_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							wd_o <=rx;
							reg1_addr <= rx;
							reg2_addr <= ry;
							instvalid <= Enable;
						when "00100" => --SLLV
							wreg_o <= Enable;
							aluop_o <= EXE_SLLV_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							wd_o <=ry;
							reg1_addr <= ry;
							reg2_addr <= rx;
							instvalid <= Enable; 						
						when "00111" => --SRAV
							wreg_o <= Enable;
							aluop_o <= EXE_SRAV_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							wd_o <=ry;
							reg1_addr <= ry;
							reg2_addr <= rx;
							instvalid <= Enable;
						when "00110" => --SRLV
							wreg_o <= Enable;
							aluop_o <= EXE_SRLV_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							wd_o <=ry;
							reg1_addr <= ry;
							reg2_addr <= rx;
							instvalid <= Enable;
						when "01010" => --CMP
							wreg_o <= Enable;
							aluop_o <= EXE_CMP_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							wd_o <= T_REGISTER;
							reg1_addr <= rx;
							reg2_addr <= ry;
							instvalid <= Enable;
						when "00010" => --SLT
							wreg_o <= Enable;
							aluop_o <= EXE_SLT_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							reg1_addr <= rx;
							reg2_addr <= ry;
							wd_o <= T_REGISTER;
							instvalid <= Enable;
						when "00011" => --SLTU
							wreg_o <= Enable;
							aluop_o <= EXE_SLTU_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Enable;
							reg1_addr <= rx;
							reg2_addr <= ry;
							wd_o <= T_REGISTER;
							instvalid <= Enable;
						when "00000" => 
							case ry is
								when "0010" => --MFPC
									wreg_o <= Enable;
									aluop_o <= EXE_MFPC;
									alusel_o <= EXE_RES_LOGIC;
									reg1_read_e <= Disable;
									reg2_read_e <= Disable;
									wd_o <=rx;
									imm <= pc_plus_1;
									instvalid <= Enable;
								when "0110" => --JALR
									wreg_o <= Enable;
									aluop_o <= EXE_JALR_OP;
									reg1_read_e <= Enable;
									reg1_addr <= rx;
									imm <= pc_plus_1 + "0000000000000001";
									wd_o <= RA_REGISTER;
									branch_flag_o <= Enable;
									branch_target_address_o <= reg1_data;
								when "0000" => --JR
									reg1_read_e <= Enable;
									reg1_addr <= rx;
									branch_flag_o <= Enable;
									branch_target_address_o <= reg1_data;
								when "0001" => --JRRA
									reg1_read_e <= Enable;
									reg1_addr <= RA_REGISTER;
									branch_flag_o <= Enable;
									branch_target_address_o <= reg1_data;
								when others =>
							end case;
						when others =>
							reg1_read_e <= Disable;
							reg2_read_e <= Disable;
							reg1_addr <= RegAddrZero;
							reg2_addr <= RegAddrZero;
							aluop_o <= EXE_NOP_OP;
							alusel_o <= EXE_RES_NOP;
							wd_o <= RegAddrZero;
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
							reg1_addr <= ry;
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
							reg1_addr <= ry;
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
							reg1_addr <= ry;
							if(imm3 = "000") then
								imm <= EXT("1000", 16);
							else
								imm <= EXT(imm3, 16);
							end if;
							instvalid <= Enable;
						when others =>
					end case;
				when "00100" => --BEQZ
					reg1_read_e <= Enable;
					reg1_addr <= rx;
					imm <= SXT(imm8,16);
					if(reg1_data = ZeroWord) then
						branch_flag_o <= Enable;
						branch_target_address_o <= pc_plus_1 + imm ;
					end if;
				when "00101" => --BNEZ
					reg1_read_e <= Enable;
					reg1_addr <= rx;
					imm <= SXT(imm8,16);
					if(reg1_data /= ZeroWord) then
						branch_flag_o <= Enable;
						branch_target_address_o <= pc_plus_1 + imm ;
					end if;
				when "01100" => 
					case rx is
						when "0011" => --ADDSP
							wreg_o <= Enable;
							aluop_o <= EXE_ADDSP_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg1_addr <= SP_REGISTER;
							reg2_read_e <= Disable;
							wd_o <= SP_REGISTER;
							instvalid <= Enable;
							imm <= SXT(imm8,16);
					
						when "0000" => --BTEQZ	
							reg1_read_e <= Enable;
							reg1_addr <= T_REGISTER;
							imm <= SXT(imm8,16);
							if(reg1_data = ZeroWord) then
								branch_flag_o <= Enable;
								branch_target_address_o <= pc_plus_1 + imm ;
							end if;
						when "0001" => --BTNEZ
							reg1_read_e <= Enable;
							reg1_addr <= T_REGISTER;
							imm <= SXT(imm8,16);
							if(reg1_data /= ZeroWord) then
								branch_flag_o <= Enable;
								branch_target_address_o <= pc_plus_1 + imm ;
							end if;
						when "0100" => --MTSP
							wreg_o <= Enable;
							aluop_o <= EXE_MTSP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Disable;
							wd_o <= SP_REGISTER;
							reg1_addr <= ry;
							imm <= ZeroWord;
							instvalid <= Enable;
						when "0010" => --SW_RS
							wreg_o <= Disable;
							aluop_o <= EXE_SW_RS;
							alusel_o <= EXE_RES_LOAD_STORE;
							reg1_read_e <= Enable;
							reg1_addr <= SP_REGISTER;
							reg2_read_e <= Enable;
							reg2_addr <= RA_REGISTER;
							instvalid <= Enable;
						when others =>
					end case;
				when "00010" => --B
					imm <= SXT(imm11, 16);
					branch_flag_o <= Enable;
					branch_target_address_o <= pc_plus_1 + imm;
				when "01110" => --CMPI
					wreg_o <= Enable;
					aluop_o <= EXE_CMPI_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Enable;
					reg2_read_e <= Disable;
					wd_o <= T_REGISTER;
					reg1_addr <= rx;
					imm <= SXT(imm8, 16);
					instvalid <= Enable;
				when "10011" => --LW
					wreg_o <= Enable;
					aluop_o <= EXE_LW;
					alusel_o <= EXE_RES_LOAD_STORE;
					reg1_read_e <= Enable;
					reg1_addr <= rx;
					reg2_read_e <= Disable;
					wd_o <=ry;
					instvalid <= Enable;
					imm <= SXT(imm5,16);
				when "10010" => --LW_SP
					wreg_o <= Enable;
					aluop_o <= EXE_LW_SP;
					alusel_o <= EXE_RES_LOAD_STORE;
					reg1_read_e <= Enable;
					reg1_addr <= SP_REGISTER;
					reg2_read_e <= Disable;
					wd_o <=rx;
					instvalid <= Enable;
					imm <= SXT(imm8,16);
				when "01010" => --SLTI
					wreg_o <= Enable;
					aluop_o <= EXE_SLTI_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Enable;
					reg2_read_e <= Disable;
					reg1_addr <= rx;
					imm <= SXT(imm8, 16);
					wd_o <= T_REGISTER;
					instvalid <= Enable;
				when "01011" => --SLTUI
					wreg_o <= Enable;
					aluop_o <= EXE_SLTI_OP;
					alusel_o <= EXE_RES_LOGIC;
					reg1_read_e <= Enable;
					reg2_read_e <= Disable;
					reg1_addr <= rx;
					imm <= EXT(imm8, 16);
					wd_o <= T_REGISTER;
					instvalid <= Enable;
				when "11011" => --SW
					wreg_o <= Disable;
					aluop_o <= EXE_SW;
					alusel_o <= EXE_RES_LOAD_STORE;
					reg1_read_e <= Enable;
					reg1_addr <= rx;
					reg2_read_e <= Enable;
					reg2_addr <= ry;
					instvalid <= Enable;
				when "11010" => --SW_SP
					wreg_o <= Disable;
					aluop_o <= EXE_SW_SP;
					alusel_o <= EXE_RES_LOAD_STORE;
					reg1_read_e <= Enable;
					reg1_addr <= SP_REGISTER;
					reg2_read_e <= Enable;
					reg2_addr <= rx;
					instvalid <= Enable;
				when "11110" => 
					case sub_op is
						when "00000" => --MFIH
							wreg_o <= Enable;
							aluop_o <= EXE_MFIH;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Disable;
							wd_o <=rx;
							reg1_addr <= IH_REGISTER;
							imm <= ZeroWord;
							instvalid <= Enable;
						when "00001" => --MTIH
							wreg_o <= Enable;
							aluop_o <= EXE_MTIH;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Enable;
							reg2_read_e <= Disable;
							wd_o <= IH_REGISTER;
							reg1_addr <= rx;
							imm <= ZeroWord;
							instvalid <= Enable;
						when others =>
					end case;
				when "11111" =>
					case imm4 is
						when "1111" => --ERET
							--jump to reg INT
							int_enable_sig <= '1';
							wreg_o <= Disable;
							reg1_read_e <= Enable;
							reg1_addr <= INT_REGISTER;
							branch_flag_o <= Enable;
							branch_target_address_o <= reg1_data;
						when others => --INT
							--write the interrupted pc to INT_REG
							int_enable_sig <= '0';
							wreg_o <= Enable;
							aluop_o <= EXE_INT_OP;
							alusel_o <= EXE_RES_LOGIC;
							reg1_read_e <= Disable;
							wd_o <= INT_REGISTER;
							if(previous_inst_i(15 downto 11) = "00010" or --B
								previous_inst_i(15 downto 11) = "00100" or --BEQZ
								previous_inst_i(15 downto 11) = "00101" or --BNEZ
								previous_inst_i(15 downto 8) = "01100000" or --BTEQZ
								previous_inst_i(15 downto 8) = "01100001" or --BTNEZ
								(previous_inst_i(15 downto 11) = "11101"  and
								previous_inst_i(7 downto 0) = "11000000") or --JALR
								(previous_inst_i(15 downto 11) = "11101"  and
								previous_inst_i(7 downto 0) = "00000000") or --JR
								previous_inst_i = "1110100000100000")then --JRRA
								imm <= pc_i - 1;
							else
								imm <= pc_i;
							end if;
							instvalid <= Enable;
							--jump to reg IH
							reg2_read_e <= Enable;
							reg2_addr <= IH_REGISTER;
							branch_flag_o <= Enable;
							branch_target_address_o <= reg2_data;
					end case;
				when others =>
			end case;
		end if;
	end process;

	--确定源操作数1
	reg1_process : process(rst,imm,reg1_read_e,reg1_data)
	begin
		if(rst = Enable) then
			reg1_o <= ZeroWord;
		elsif(reg1_read_e = Enable) then
			reg1_o <= reg1_data;
		elsif(reg1_read_e = Disable) then
			reg1_o<=imm;
		else
			reg1_o<=ZeroWord;
		end if;
	end process;

	--确定源操作数2
	reg2_process : process(rst,imm,reg2_read_e,reg2_data)
	begin
		if(rst = Enable) then
			reg2_o <= ZeroWord;
		elsif(reg2_read_e = Enable) then
			reg2_o <= reg2_data;
		elsif(reg2_read_e = Disable) then
			reg2_o<=imm;
		else
			reg2_o<=ZeroWord;
		end if;
	end process;

	--确定寄存器1正确值(考虑旁路)
	reg1_data_process : process(rst,reg1_data_i,imm,reg1_read_e,ex_wreg_i,ex_wd_i,ex_wdata_i,mem_wreg_i,mem_wd_i,mem_wdata_i,reg1_addr)
	begin
		if(rst = Enable) then
			reg1_data <= ZeroWord;
		elsif(reg1_read_e = Enable and ex_wreg_i = Enable and ex_wd_i=reg1_addr) then
			reg1_data <= ex_wdata_i;
		elsif(reg1_read_e = Enable and mem_wreg_i = Enable and mem_wd_i=reg1_addr) then
			reg1_data <= mem_wdata_i;
		elsif(reg1_read_e = Enable) then
			reg1_data <= reg1_data_i;
		elsif(reg1_read_e = Disable) then
			reg1_data<=ZeroWord;
		else
			reg1_data<=ZeroWord;
		end if;
	end process;

	--确定寄存器2正确返回值(考虑旁路)
	reg2_data_process : process(rst,reg2_data_i,imm,reg2_read_e,ex_wreg_i,ex_wd_i,ex_wdata_i,mem_wreg_i,mem_wd_i,mem_wdata_i,reg2_addr)
	begin
		if(rst = Enable) then
			reg2_data <= ZeroWord;
		elsif(reg2_read_e = Enable and ex_wreg_i = Enable and ex_wd_i=reg2_addr) then
			reg2_data <= ex_wdata_i;
		elsif(reg2_read_e = Enable and mem_wreg_i = Enable and mem_wd_i=reg2_addr) then
			reg2_data <= mem_wdata_i;
		elsif(reg2_read_e = Enable) then
			reg2_data <= reg2_data_i;
		elsif(reg2_read_e = Disable) then
			reg2_data<=ZeroWord;
		else
			reg2_data<=ZeroWord;
		end if;
	end process;

	--Load相关流水线暂停
	LoadRelate: process(ex_aluop_i,ex_wd_i,reg1_addr,reg1_read_e,reg2_addr,reg2_read_e)
		variable pre_inst_is_load : STD_LOGIC;
	begin
		if(ex_aluop_i = EXE_LW or ex_aluop_i = EXE_LW_SP) then
			pre_inst_is_load := '1';
		else
			pre_inst_is_load := '0';
		end if;
		stallreq <= NoStop;
		if(pre_inst_is_load = '1' and ex_wd_i = reg1_addr and reg1_read_e = Enable) then
			stallreq<=Stop;
		end if;
		if(pre_inst_is_load = '1' and ex_wd_i = reg2_addr and reg2_read_e = Enable) then
			stallreq<=Stop;
		end if;
	end process;

end Behavioral;

