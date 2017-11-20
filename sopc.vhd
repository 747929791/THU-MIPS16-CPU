----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:40:22 11/15/2017 
-- Design Name: 
-- Module Name:    sopc - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sopc is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  
			  data_ready: in STD_LOGIC;
			  tbre: in STD_LOGIC;
			  tsre: in STD_LOGIC;
			  Ram1Addr: out STD_LOGIC_VECTOR(17 downto 0);
			  Ram1Data: inout STD_LOGIC_VECTOR(15 downto 0);
			  Ram1OE: out STD_LOGIC;
			  Ram1WE: out STD_LOGIC;
			  Ram1EN: out STD_LOGIC;
			  rdn: out STD_LOGIC;
			  wrn: out STD_LOGIC;		
			  
			  Ram2Addr: out STD_LOGIC_VECTOR(17 downto 0);
			  Ram2Data: inout STD_LOGIC_VECTOR(15 downto 0);
			  Ram2OE: out STD_LOGIC;
			  Ram2WE: out STD_LOGIC;
			  Ram2EN: out STD_LOGIC;
			  
			  FlashByte: out STD_LOGIC;
			  FlashVpen: out STD_LOGIC;
			  FlashCE: out STD_LOGIC;
			  FlashOE: out STD_LOGIC;
			  FlashWE: out STD_LOGIC;
			  FlashRP: out STD_LOGIC;
			  FlashAddr: out STD_LOGIC_VECTOR(22 downto 1);
			  FlashData: inout STD_LOGIC_VECTOR(15 downto 0);
			  
			  LED: out STD_LOGIC_VECTOR(15 downto 0));
end sopc;

architecture Behavioral of sopc is

signal rom_data : STD_LOGIC_VECTOR(15 downto 0);
signal rom_addr : STD_LOGIC_VECTOR(15 downto 0);
signal rom_ce : STD_LOGIC;
signal ram_rdata : STD_LOGIC_VECTOR(15 downto 0);
signal ram_read : STD_LOGIC;
signal ram_write : STD_LOGIC;
signal ram_addr : STD_LOGIC_VECTOR(15 downto 0);
signal ram_wdata : STD_LOGIC_VECTOR(15 downto 0);
signal ram_ce : STD_LOGIC;
signal rst_reversed : STD_LOGIC;
signal rst_cpu : STD_LOGIC;
signal inst_ready : STD_LOGIC;

component cpu
	    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  LED : out STD_LOGIC_VECTOR(15 downto 0);
           rom_data_i : in STD_LOGIC_VECTOR(15 downto 0); --取得的指令
           rom_addr_o : out STD_LOGIC_VECTOR(15 downto 0); --指令寄存器地址
           rom_ce_o : out STD_LOGIC; --指令存储器使能
           ram_rdata_i : in STD_LOGIC_VECTOR(15 downto 0);
           ram_read_o : out STD_LOGIC;
           ram_write_o : out STD_LOGIC;
           ram_addr_o : out STD_LOGIC_VECTOR(15 downto 0);
           ram_wdata_o : out STD_LOGIC_VECTOR(15 downto 0);
           ram_ce_o : out STD_LOGIC --数据存储器使能
			  );
end component;

component inst_rom
    Port ( ce : in  STD_LOGIC;
			  clk : in STD_LOGIC;
			  rst : in STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
			  inst : out  STD_LOGIC_VECTOR (15 downto 0);
			  
			  data_ready: in STD_LOGIC;
			  tbre: in STD_LOGIC;
			  tsre: in STD_LOGIC;
			  Ram1Addr: out STD_LOGIC_VECTOR(17 downto 0);
			  Ram1Data: inout STD_LOGIC_VECTOR(15 downto 0);
			  Ram1OE: out STD_LOGIC;
			  Ram1WE: out STD_LOGIC;
			  Ram1EN: out STD_LOGIC;
			  rdn: out STD_LOGIC;
			  wrn: out STD_LOGIC;
			  
			  FlashByte: out STD_LOGIC;
			  FlashVpen: out STD_LOGIC;
			  FlashCE: out STD_LOGIC;
			  FlashOE: out STD_LOGIC;
			  FlashWE: out STD_LOGIC;
			  FlashRP: out STD_LOGIC;
			  FlashAddr: out STD_LOGIC_VECTOR(22 downto 1);
			  FlashData: inout STD_LOGIC_VECTOR(15 downto 0));
end component;

component ram
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           re : in  STD_LOGIC;
           we : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
           wdata : in  STD_LOGIC_VECTOR (15 downto 0);
			  Ram2Addr: out STD_LOGIC_VECTOR(17 downto 0);
			  Ram2Data: inout STD_LOGIC_VECTOR(15 downto 0);
			  Ram2OE: out STD_LOGIC;
			  Ram2WE: out STD_LOGIC;
			  Ram2EN: out STD_LOGIC;
           rdata : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

begin
	rst_reversed <= not(rst);
	rst_cpu <= rst_reversed or not(inst_ready);
	cpu_component : cpu port map(rst=>rst_cpu,clk=>clk,rom_data_i=>rom_data, rom_addr_o=>rom_addr, rom_ce_o=>rom_ce,LED=>LED,
										  ram_rdata_i=>ram_rdata,ram_read_o=>ram_read,ram_write_o=>ram_write,ram_addr_o=>ram_addr,ram_wdata_o=>ram_wdata,ram_ce_o=>ram_ce);
	inst_rom_component : inst_rom port map(rst=>rst_reversed, clk=>clk, data_ready=>data_ready, tbre=>tbre, tsre=>tsre, Ram1Addr=>Ram1Addr, Ram1Data=>Ram1Data,
	Ram1OE=>Ram1OE, Ram1WE=>Ram1WE, Ram1EN=>Ram1EN, rdn=>rdn, wrn=>wrn, inst=>rom_data, addr=>rom_addr, ce=>rom_ce,
	FlashByte=>FlashByte, FlashVpen=>FlashVpen, FlashCE=>FlashCE, FlashOE=>FlashOE, FlashWE=>FlashWE, FlashRP=>FlashRP, FlashAddr=>FlashAddr, FlashData=>FlashData);
	ram_component : ram port map(rst=>rst_reversed,clk=>clk,re=>ram_read,we=>ram_write,addr=>ram_addr,wdata=>ram_wdata,rdata=>ram_rdata,
	Ram2Addr=>Ram2Addr, Ram2Data=>Ram2Data, Ram2OE=>Ram2OE, Ram2WE=>Ram2WE, Ram2EN=>Ram2EN);

end Behavioral;

