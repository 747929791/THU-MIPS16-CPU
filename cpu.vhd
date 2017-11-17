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
           rom_data_i : in STD_LOGIC_VECTOR(15 downto 0); --ȡ�õ�ָ��
           rom_addr_o : out STD_LOGIC_VECTOR(15 downto 0); --ָ��Ĵ�����ַ
           rom_ce_o : out STD_LOGIC; --ָ��洢��ʹ��
           ram_rdata_i : in STD_LOGIC_VECTOR(15 downto 0);
           ram_read_o : out STD_LOGIC;
           ram_write_o : out STD_LOGIC;
           ram_addr_o : out STD_LOGIC_VECTOR(15 downto 0);
           ram_wdata_o : out STD_LOGIC_VECTOR(15 downto 0);
           ram_ce_o : out STD_LOGIC --���ݴ洢��ʹ��
			  );
end cpu;

architecture Behavioral of cpu is
--����IF/ID������ģ��ID�ı���
signal pc_pc : STD_LOGIC_VECTOR(15 downto 0);
signal id_pc_i : STD_LOGIC_VECTOR(15 downto 0);
signal id_inst_i : STD_LOGIC_VECTOR(15 downto 0);
--ID��ID/EX�Ľӿ�
signal id_aluop_o : STD_LOGIC_VECTOR(7 downto 0);
signal id_alusel_o : STD_LOGIC_VECTOR(2 downto 0);
signal id_reg1_o : STD_LOGIC_VECTOR(15 downto 0);
signal id_reg2_o : STD_LOGIC_VECTOR(15 downto 0);
signal id_wreg_o : STD_LOGIC;
signal id_wd_o : STD_LOGIC_VECTOR(3 downto 0);
signal id_inst_o : STD_LOGIC_VECTOR(15 downto 0);
--ID/EX��EX���������
signal ex_aluop_i : STD_LOGIC_VECTOR(7 downto 0);
signal ex_alusel_i : STD_LOGIC_VECTOR(2 downto 0);
signal ex_reg1_i : STD_LOGIC_VECTOR(15 downto 0);
signal ex_reg2_i : STD_LOGIC_VECTOR(15 downto 0);
signal ex_wreg_i : STD_LOGIC;
signal ex_wd_i : STD_LOGIC_VECTOR(3 downto 0);
signal ex_inst_i : STD_LOGIC_VECTOR(15 downto 0);
--EX��EX/MEM�ı���
signal ex_wreg_o :STD_LOGIC;
signal ex_wd_o : STD_LOGIC_VECTOR(3 downto 0);
signal ex_wdata_o : STD_LOGIC_VECTOR(15 downto 0);
signal ex_mem_read_o : STD_LOGIC;
signal ex_mem_write_o : STD_LOGIC;
signal ex_mem_addr_o : STD_LOGIC_VECTOR(15 downto 0);
signal ex_mem_wdata_o : STD_LOGIC_VECTOR(15 downto 0);
--EX��ID�ķ����ź�
signal ex_aluop_o : STD_LOGIC_VECTOR(7 downto 0);
--EX/MEM��MEM�Ľӿ�
signal mem_wreg_i :STD_LOGIC;
signal mem_wd_i : STD_LOGIC_VECTOR(3 downto 0);
signal mem_wdata_i : STD_LOGIC_VECTOR(15 downto 0);
signal mem_mem_read_i : STD_LOGIC;
signal mem_mem_write_i : STD_LOGIC;
signal mem_mem_addr_i : STD_LOGIC_VECTOR(15 downto 0);
signal mem_mem_wdata_i : STD_LOGIC_VECTOR(15 downto 0);
--MEM��MEM/WB�ı���
signal mem_wreg_o :STD_LOGIC;
signal mem_wd_o : STD_LOGIC_VECTOR(3 downto 0);
signal mem_wdata_o : STD_LOGIC_VECTOR(15 downto 0);
--MEM/WB��WB�ı���
signal wb_wreg_i :STD_LOGIC;
signal wb_wd_i : STD_LOGIC_VECTOR(3 downto 0);
signal wb_wdata_i : STD_LOGIC_VECTOR(15 downto 0);
--ID��RegFile�ı���
signal reg1_read : STD_LOGIC;
signal reg2_read : STD_LOGIC;
signal reg1_data : STD_LOGIC_VECTOR(15 downto 0);
signal reg2_data : STD_LOGIC_VECTOR(15 downto 0);
signal reg1_addr : STD_LOGIC_VECTOR(3 downto 0);
signal reg2_addr : STD_LOGIC_VECTOR(3 downto 0);
--CTRL��ͣ�ź�
signal stallreq_id : STD_LOGIC;
signal stallreq_ex : STD_LOGIC;
signal stall : STD_LOGIC_VECTOR(5 downto 0);
--ID/PCת���ź�
signal branch_flag : STD_LOGIC;
signal branch_target_address : STD_LOGIC_VECTOR(15 downto 0);

component pc
    Port ( rst : in  STD_LOGIC; --��λ�ź�
           clk : in  STD_LOGIC; --ʱ���ź�
           pc_o : out  STD_LOGIC_VECTOR (15 downto 0); --Ҫ��ȡ��ָ���ַ
           ce_o : out  STD_LOGIC; --ָ��洢��ʹ��
			  stall : in STD_LOGIC_VECTOR(5 downto 0); --��ͣ�ź�
			  branch_flag_i : in STD_LOGIC; --�Ƿ���ת�ź�
			  branch_target_address_i : in STD_LOGIC_VECTOR(15 downto 0)
			  );
end component;

component if_id
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           if_pc : in  STD_LOGIC_VECTOR (15 downto 0);
           if_inst : in  STD_LOGIC_VECTOR (15 downto 0);
           id_pc : out  STD_LOGIC_VECTOR (15 downto 0);
           id_inst : out  STD_LOGIC_VECTOR (15 downto 0);
			  stall : in STD_LOGIC_VECTOR(5 downto 0)); --��ͣ�ź�
end component;

component id
    Port ( rst : in  STD_LOGIC;
           pc_i : in  STD_LOGIC_VECTOR (15 downto 0);
           inst_i : in  STD_LOGIC_VECTOR (15 downto 0);
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
			  --������·������Ҫ��ex��mem�׶ε��ź�
			  ex_wreg_i : in STD_LOGIC;
			  ex_wd_i : in STD_LOGIC_VECTOR(3 downto 0);
			  ex_wdata_i : in STD_LOGIC_VECTOR(15 downto 0);
			  mem_wreg_i : in STD_LOGIC;
			  mem_wd_i : in STD_LOGIC_VECTOR(3 downto 0);
			  mem_wdata_i : in STD_LOGIC_VECTOR(15 downto 0);
			  --��ͣ�����ź�
			  stallreq : out STD_LOGIC;
			  --PC��ת�ź�
			  --PC��ת�ź�
			  branch_flag_o : out STD_LOGIC;
			  branch_target_address_o : out STD_LOGIC_VECTOR(15 downto 0);
			  --���ô洢��ָ���ź�
			  inst_o : out STD_LOGIC_VECTOR(15 downto 0);
			  --ex�׶�aluop�źż��Load���
			  ex_aluop_i : in STD_LOGIC_VECTOR(7 downto 0)
			  );
end component;

component regfile
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           waddr : in  STD_LOGIC_VECTOR (3 downto 0);
           wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           we : in  STD_LOGIC;
           raddr1 : in  STD_LOGIC_VECTOR (3 downto 0);
           re1 : in  STD_LOGIC;
           rdata1 : out  STD_LOGIC_VECTOR (15 downto 0);
           raddr2 : in  STD_LOGIC_VECTOR (3 downto 0);
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
           id_wd : in  STD_LOGIC_VECTOR (3 downto 0);
           id_wreg : in  STD_LOGIC;
			  id_inst :  in STD_LOGIC_VECTOR (15 downto 0);
           ex_alusel : out  STD_LOGIC_VECTOR (2 downto 0);
           ex_aluop : out  STD_LOGIC_VECTOR (7 downto 0);
           ex_reg1 : out  STD_LOGIC_VECTOR (15 downto 0);
           ex_reg2 : out  STD_LOGIC_VECTOR (15 downto 0);
           ex_wd : out  STD_LOGIC_VECTOR (3 downto 0);
           ex_wreg : out  STD_LOGIC;
			  ex_inst :  out STD_LOGIC_VECTOR (15 downto 0);
			  stall : in STD_LOGIC_VECTOR(5 downto 0)); --��ͣ�ź�
end component;

component ex
    Port ( rst : in  STD_LOGIC;
           alusel_i : in  STD_LOGIC_VECTOR(2 downto 0);
           aluop_i : in  STD_LOGIC_VECTOR(7 downto 0);
           reg1_i : in  STD_LOGIC_VECTOR(15 downto 0);
           reg2_i : in  STD_LOGIC_VECTOR(15 downto 0);
           wd_i : in  STD_LOGIC_VECTOR (3 downto 0);
           wreg_i : in  STD_LOGIC;
           wd_o : out  STD_LOGIC_VECTOR (3 downto 0);
           wreg_o : out  STD_LOGIC;
           wdata_o : out  STD_LOGIC_VECTOR (15 downto 0);
			  --��ͣ�����ź�
			  stallreq : out STD_LOGIC;
			  --�ô��ź�
			  mem_read_o : out STD_LOGIC;
			  mem_write_o : out STD_LOGIC;
			  mem_addr_o : out STD_LOGIC_VECTOR(15 downto 0);
			  mem_wdata_o : out STD_LOGIC_VECTOR(15 downto 0);
			  --ָ��(���ڻ�ȡ�ô�������)
			  inst_i : in STD_LOGIC_VECTOR(15 downto 0);
			  --��id�׶μ��Load���
			  aluop_o : out STD_LOGIC_VECTOR(7 downto 0)
			  );
end component;

component ex_mem
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           ex_wd : in  STD_LOGIC_VECTOR (3 downto 0);
           ex_wreg : in  STD_LOGIC;
           ex_wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           mem_wd : out  STD_LOGIC_VECTOR (3 downto 0);
           mem_wreg : out  STD_LOGIC;
           mem_wdata : out  STD_LOGIC_VECTOR (15 downto 0);
			  stall : in STD_LOGIC_VECTOR(5 downto 0); --��ͣ�ź�
			  --�ô��ź�
			  ex_mem_read : in STD_LOGIC;
			  ex_mem_write : in STD_LOGIC;
			  ex_mem_addr : in STD_LOGIC_VECTOR(15 downto 0);
			  ex_mem_wdata : in STD_LOGIC_VECTOR(15 downto 0);
			  mem_mem_read : out STD_LOGIC;
			  mem_mem_write : out STD_LOGIC;
			  mem_mem_addr : out STD_LOGIC_VECTOR(15 downto 0);
			  mem_mem_wdata : out STD_LOGIC_VECTOR(15 downto 0));
end component;

component mem
    Port ( rst : in  STD_LOGIC;
           wd_i : in  STD_LOGIC_VECTOR (3 downto 0);
           wreg_i : in  STD_LOGIC;
           wdata_i : in  STD_LOGIC_VECTOR (15 downto 0);
           wd_o : out  STD_LOGIC_VECTOR (3 downto 0);
           wreg_o : out  STD_LOGIC;
           wdata_o : out  STD_LOGIC_VECTOR (15 downto 0);
			  --�ô��ź�
			  mem_read_i : in STD_LOGIC;
			  mem_write_i : in STD_LOGIC;
			  mem_addr_i : in STD_LOGIC_VECTOR(15 downto 0);
			  mem_wdata_i : in STD_LOGIC_VECTOR(15 downto 0);
			  --�洢���ź�
			  mem_rdata_i : in STD_LOGIC_VECTOR(15 downto 0);
			  mem_read_o : out STD_LOGIC;
			  mem_write_o : out STD_LOGIC;
			  mem_addr_o : out STD_LOGIC_VECTOR(15 downto 0);
			  mem_wdata_o : out STD_LOGIC_VECTOR(15 downto 0);
			  mem_ce_o : out STD_LOGIC);
end component;

component mem_wb
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           mem_wd : in  STD_LOGIC_VECTOR (3 downto 0);
           mem_wreg : in  STD_LOGIC;
           mem_wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           wb_wd : out  STD_LOGIC_VECTOR (3 downto 0);
           wb_wreg : out  STD_LOGIC;
           wb_wdata : out  STD_LOGIC_VECTOR (15 downto 0);
			  stall : in STD_LOGIC_VECTOR(5 downto 0)); --��ͣ�ź�
end component;

component ctrl
    Port ( rst : in  STD_LOGIC;
           stallreq_from_id : in  STD_LOGIC;
           stallreq_from_ex : in  STD_LOGIC;
           stall : out  STD_LOGIC_VECTOR (5 downto 0));
end component;

begin
	rom_addr_o <= pc_pc;
	pc_component : pc port map(rst=>rst,clk=>clk,pc_o=>pc_pc,ce_o=>rom_ce_o, stall=>stall, branch_flag_i=>branch_flag, branch_target_address_i=>branch_target_address);
	if_id_component : if_id port map(rst=>rst,clk=>clk,if_pc=>pc_pc,if_inst=>rom_data_i,id_pc=>id_pc_i,id_inst=>id_inst_i, stall=>stall);
	id_component : id port map(rst=>rst, pc_i=>id_pc_i, inst_i=>id_inst_i, reg1_data_i=>reg1_data, reg2_data_i=>reg2_data, 
										reg1_read_o=>reg1_read, reg2_read_o=>reg2_read, reg1_addr_o=>reg1_addr, reg2_addr_o=>reg2_addr, 
										aluop_o=>id_aluop_o, alusel_o=>id_alusel_o, reg1_o=>id_reg1_o, reg2_o=>id_reg2_o, wd_o=>id_wd_o, wreg_o=>id_wreg_o,
										ex_wreg_i=>ex_wreg_o, ex_wd_i=>ex_wd_o, ex_wdata_i=>ex_wdata_o, mem_wreg_i=>mem_wreg_o, mem_wd_i=>mem_wd_o, mem_wdata_i=>mem_wdata_o,
										stallreq=>stallreq_id, branch_flag_o=>branch_flag, branch_target_address_o=>branch_target_address, inst_o=>id_inst_o, ex_aluop_i=>ex_aluop_o);
	regfile_component : regfile port map(rst=>rst, clk=>clk, waddr=>wb_wd_i, wdata=>wb_wdata_i, we=>wb_wreg_i, raddr1=>reg1_addr, re1=>reg1_read, 
													 rdata1=>reg1_data, raddr2=>reg2_addr, re2=>reg2_read, rdata2=>reg2_data);
	id_ex_component : id_ex port map(rst=>rst, clk=>clk, id_alusel=>id_alusel_o, id_aluop=>id_aluop_o, id_reg1=>id_reg1_o, id_reg2=>id_reg2_o, id_wd=>id_wd_o, id_wreg=>id_wreg_o,
												ex_alusel=>ex_alusel_i, ex_aluop=>ex_aluop_i, ex_reg1=>ex_reg1_i, ex_reg2=>ex_reg2_i, ex_wd=>ex_wd_i, ex_wreg=>ex_wreg_i, stall=>stall,
												id_inst=>id_inst_o, ex_inst=>ex_inst_i);
	ex_component : ex port map(rst=>rst,alusel_i=>ex_alusel_i, aluop_i=>ex_aluop_i, reg1_i=>ex_reg1_i, reg2_i=>ex_reg2_i, wd_i=>ex_wd_i, wreg_i=>ex_wreg_i, 
										wd_o=>ex_wd_o, wreg_o=>ex_wreg_o, wdata_o=>ex_wdata_o, stallreq=>stallreq_ex, inst_i=>ex_inst_i,
										mem_read_o=>ex_mem_read_o, mem_write_o=>ex_mem_write_o, mem_addr_o=>ex_mem_addr_o, mem_wdata_o=>ex_mem_wdata_o, aluop_o=>ex_aluop_o);
	ex_mem_component : ex_mem port map(rst=>rst, clk=>clk, ex_wd=>ex_wd_o, ex_wreg=>ex_wreg_o, ex_wdata=>ex_wdata_o, mem_wd=>mem_wd_i, mem_wreg=>mem_wreg_i, mem_wdata=>mem_wdata_i, stall=>stall,
												  ex_mem_read=>ex_mem_read_o, ex_mem_write=>ex_mem_write_o, ex_mem_addr=>ex_mem_addr_o, ex_mem_wdata=>ex_mem_wdata_o,
												  mem_mem_read=>mem_mem_read_i, mem_mem_write=>mem_mem_write_i, mem_mem_addr=>mem_mem_addr_i, mem_mem_wdata=>mem_mem_wdata_i);
	mem_component : mem port map(rst=>rst, wd_i=>mem_wd_i, wreg_i=>mem_wreg_i, wdata_i=>mem_wdata_i, wd_o=>mem_wd_o, wreg_o=>mem_wreg_o, wdata_o=>mem_wdata_o,
										  mem_read_i=>mem_mem_read_i,mem_write_i=>mem_mem_write_i,mem_addr_i=>mem_mem_addr_i,mem_wdata_i=>mem_mem_wdata_i,
										  mem_read_o=>ram_read_o, mem_write_o=>ram_write_o, mem_addr_o=>ram_addr_o, mem_wdata_o=>ram_wdata_o, mem_rdata_i=>ram_rdata_i,mem_ce_o=>ram_ce_o);
	mem_wb_component : mem_wb port map(rst=>rst, clk=>clk, mem_wd=>mem_wd_o, mem_wreg=>mem_wreg_o, mem_wdata=>mem_wdata_o, wb_wd=>wb_wd_i, wb_wreg=>wb_wreg_i, wb_wdata=>wb_wdata_i, stall=>stall);
	ctrl_component : ctrl port map(rst=>rst, stallreq_from_id=>stallreq_id, stallreq_from_ex=>stallreq_ex, stall=>stall);
end Behavioral;

