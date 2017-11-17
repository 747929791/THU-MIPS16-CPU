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
           clk : in  STD_LOGIC);
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

component cpu
	    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
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
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
           inst : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component ram
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           re : in  STD_LOGIC;
           we : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
           wdata : in  STD_LOGIC_VECTOR (15 downto 0);
           rdata : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

begin

	cpu_component : cpu port map(rst=>rst,clk=>clk,rom_data_i=>rom_data, rom_addr_o=>rom_addr, rom_ce_o=>rom_ce,
										  ram_rdata_i=>ram_rdata,ram_read_o=>ram_read,ram_write_o=>ram_write,ram_addr_o=>ram_addr,ram_wdata_o=>ram_wdata,ram_ce_o=>ram_ce);
	inst_rom_component : inst_rom port map(inst=>rom_data, addr=>rom_addr, ce=>rom_ce);
	ram_component : ram port map(rst=>rst,clk=>clk,re=>ram_read,we=>ram_write,addr=>ram_addr,wdata=>ram_wdata,rdata=>ram_rdata);

end Behavioral;

