----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:07:54 11/15/2017 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
	    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           rom_data_i : in STD_LOGIC_VECTOR(15 downto 0); --取得的指令
           rom_addr_o : out STD_LOGIC_VECTOR(15 downto 0); --指令寄存器地址
           rom_ce_o : out STD_LOGIC --指令寄存器使能
			  );
end cpu;

architecture Behavioral of cpu is
--连接IF/ID与译码模块ID的变量
signal pc_pc : STD_LOGIC_VECTOR(15 downto 0);
signal id_pc_i : STD_LOGIC_VECTOR(15 downto 0);
signal id_inst_i : STD_LOGIC_VECTOR(15 downto 0);
--ID到ID/EX的接口
signal id_aluop_o : STD_LOGIC_VECTOR(7 downto 0);
signal id_alusel_o : STD_LOGIC_VECTOR(2 downto 0);
signal id_reg1_o : STD_LOGIC_VECTOR(15 downto 0);
signal id_reg2_o : STD_LOGIC_VECTOR(15 downto 0);
signal id_wreg_o : STD_LOGIC;
signal id_wd_o : STD_LOGIC_VECTOR(2 downto 0);
--ID/EX到EX的输入变量
signal ex_aluop_i : STD_LOGIC_VECTOR(7 downto 0);
signal ex_alusel_i : STD_LOGIC_VECTOR(2 downto 0);
signal ex_reg1_i : STD_LOGIC_VECTOR(15 downto 0);
signal ex_reg2_i : STD_LOGIC_VECTOR(15 downto 0);
signal ex_wreg_i : STD_LOGIC;
signal ex_wd_i : STD_LOGIC_VECTOR(2 downto 0);
--EX到EX/MEM的变量
signal ex_wreg_o :STD_LOGIC;
signal ex_wd_o : STD_LOGIC_VECTOR(2 downto 0);
signal ex_wdata_o : STD_LOGIC_VECTOR(15 downto 0);
--EX/MEM到MEM的接口
signal mem_wreg_i :STD_LOGIC;
signal mem_wd_i : STD_LOGIC_VECTOR(2 downto 0);
signal mem_wdata_i : STD_LOGIC_VECTOR(15 downto 0);
--MEM到MEM/WB的变量
signal mem_wreg_o :STD_LOGIC;
signal mem_wd_o : STD_LOGIC_VECTOR(2 downto 0);
signal mem_wdata_o : STD_LOGIC_VECTOR(15 downto 0);
--MEM/WB到WB的变量
signal wb_wreg_i :STD_LOGIC;
signal wb_wd_i : STD_LOGIC_VECTOR(2 downto 0);
signal wb_wdata_i : STD_LOGIC_VECTOR(15 downto 0);
--ID与RegFile的变量
signal reg1_read : STD_LOGIC;
signal reg2_read : STD_LOGIC;
signal reg1_data : STD_LOGIC_VECTOR(15 downto 0);
signal reg2_data : STD_LOGIC_VECTOR(15 downto 0);
signal reg1_addr : STD_LOGIC_VECTOR(2 downto 0);
signal reg2_addr : STD_LOGIC_VECTOR(2 downto 0);

component pc
    Port ( rst : in  STD_LOGIC; --复位信号
           clk : in  STD_LOGIC; --时钟信号
           pc_o : out  STD_LOGIC_VECTOR (15 downto 0); --要读取的指令地址
           ce_o : out  STD_LOGIC); --指令存储器使能
end component;

component if_id
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           if_pc : in  STD_LOGIC_VECTOR (15 downto 0);
           if_inst : in  STD_LOGIC_VECTOR (15 downto 0);
           id_pc : out  STD_LOGIC_VECTOR (15 downto 0);
           id_inst : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component id
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
end component;

component regfile
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           waddr : in  STD_LOGIC_VECTOR (2 downto 0);
           wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           we : in  STD_LOGIC;
           raddr1 : in  STD_LOGIC_VECTOR (2 downto 0);
           re1 : in  STD_LOGIC;
           rdata1 : out  STD_LOGIC_VECTOR (15 downto 0);
           raddr2 : in  STD_LOGIC_VECTOR (2 downto 0);
           re2 : in  STD_LOGIC;
           rdata2 : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component id_ex
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           id_alusel : in  STD_LOGIC_VECTOR (2 downto 0);
           id_aluop : in  STD_LOGIC_VECTOR (7 downto 0);
           id_reg1 : in  STD_LOGIC_VECTOR (15 downto 0);
           id_reg2 : in  STD_LOGIC_VECTOR (15 downto 0);
           id_wd : in  STD_LOGIC_VECTOR (2 downto 0);
           id_wreg : in  STD_LOGIC;
           ex_alusel : out  STD_LOGIC_VECTOR (2 downto 0);
           ex_aluop : out  STD_LOGIC_VECTOR (7 downto 0);
           ex_reg1 : out  STD_LOGIC_VECTOR (15 downto 0);
           ex_reg2 : out  STD_LOGIC_VECTOR (15 downto 0);
           ex_wd : out  STD_LOGIC_VECTOR (2 downto 0);
           ex_wreg : out  STD_LOGIC);
end component;

component ex
    Port ( rst : in  STD_LOGIC;
           alusel_i : in  STD_LOGIC_VECTOR(2 downto 0);
           aluop_i : in  STD_LOGIC_VECTOR(7 downto 0);
           reg1_i : in  STD_LOGIC_VECTOR(15 downto 0);
           reg2_i : in  STD_LOGIC_VECTOR(15 downto 0);
           wd_i : in  STD_LOGIC_VECTOR (2 downto 0);
           wreg_i : in  STD_LOGIC;
           wd_o : out  STD_LOGIC_VECTOR (2 downto 0);
           wreg_o : out  STD_LOGIC;
           wdata_o : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component ex_mem
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           ex_wd : in  STD_LOGIC_VECTOR (2 downto 0);
           ex_wreg : in  STD_LOGIC;
           ex_wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           mem_wd : out  STD_LOGIC_VECTOR (2 downto 0);
           mem_wreg : out  STD_LOGIC;
           mem_wdata : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component mem
    Port ( rst : in  STD_LOGIC;
           wd_i : in  STD_LOGIC_VECTOR (2 downto 0);
           wreg_i : in  STD_LOGIC;
           wdata_i : in  STD_LOGIC_VECTOR (15 downto 0);
           wd_o : out  STD_LOGIC_VECTOR (2 downto 0);
           wreg_o : out  STD_LOGIC;
           wdata_o : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component mem_wb
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           mem_wd : in  STD_LOGIC_VECTOR (2 downto 0);
           mem_wreg : in  STD_LOGIC;
           mem_wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           wb_wd : out  STD_LOGIC_VECTOR (2 downto 0);
           wb_wreg : out  STD_LOGIC;
           wb_wdata : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

begin
	rom_addr_o <= pc_pc;
	pc_component : pc port map(rst=>rst,clk=>clk,pc_o=>pc_pc,ce_o=>rom_ce_o);
	if_id_component : if_id port map(rst=>rst,clk=>clk,if_pc=>pc_pc,if_inst=>rom_data_i,id_pc=>id_pc_i,id_inst=>id_inst_i);
	id_component : id port map(rst=>rst, pc_i=>id_pc_i, inst_i=>id_inst_i, reg1_data_i=>reg1_data, reg2_data_i=>reg2_data, 
										reg1_read_o=>reg1_read, reg2_read_o=>reg2_read, reg1_addr_o=>reg1_addr, reg2_addr_o=>reg2_addr, 
										aluop_o=>id_aluop_o, alusel_o=>id_alusel_o, reg1_o=>id_reg1_o, reg2_o=>id_reg2_o, wd_o=>id_wd_o, wreg_o=>id_wreg_o);
	regfile_component : regfile port map(rst=>rst, clk=>clk, waddr=>wb_wd_i, wdata=>wb_wdata_i, we=>wb_wreg_i, raddr1=>reg1_addr, re1=>reg1_read, 
													 rdata1=>reg1_data, raddr2=>reg2_addr, re2=>reg2_read, rdata2=>reg2_data);
	id_ex_component : id_ex port map(rst=>rst, clk=>clk, id_alusel=>id_alusel_o, id_aluop=>id_aluop_o, id_reg1=>id_reg1_o, id_reg2=>id_reg2_o, id_wd=>id_wd_o, id_wreg=>id_wreg_o,
												ex_alusel=>ex_alusel_i, ex_aluop=>ex_aluop_i, ex_reg1=>ex_reg1_i, ex_reg2=>ex_reg2_i, ex_wd=>ex_wd_i, ex_wreg=>ex_wreg_i);
	ex_component : ex port map(rst=>rst,alusel_i=>ex_alusel_i, aluop_i=>ex_aluop_i, reg1_i=>ex_reg1_i, reg2_i=>ex_reg2_i, wd_i=>ex_wd_i, wreg_i=>ex_wreg_i, wd_o=>ex_wd_o, wreg_o=>ex_wreg_o, wdata_o=>ex_wdata_o);
	ex_mem_component : ex_mem port map(rst=>rst, clk=>clk, ex_wd=>ex_wd_o, ex_wreg=>ex_wreg_o, ex_wdata=>ex_wdata_o, mem_wd=>mem_wd_i, mem_wreg=>mem_wreg_i, mem_wdata=>mem_wdata_i);
	mem_component : mem port map(rst=>rst, wd_i=>mem_wd_i, wreg_i=>mem_wreg_i, wdata_i=>mem_wdata_i, wd_o=>mem_wd_o, wreg_o=>mem_wreg_o, wdata_o=>mem_wdata_o);
	mem_wb_component : mem_wb port map(rst=>rst, clk=>clk, mem_wd=>mem_wd_o, mem_wreg=>mem_wreg_o, mem_wdata=>mem_wdata_o, wb_wd=>wb_wd_i, wb_wreg=>wb_wreg_i, wb_wdata=>wb_wdata_i);

end Behavioral;

