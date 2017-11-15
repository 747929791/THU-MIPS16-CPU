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

component cpu
	    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           rom_data_i : in STD_LOGIC_VECTOR(15 downto 0); --取得的指令
           rom_addr_o : out STD_LOGIC_VECTOR(15 downto 0); --指令寄存器地址
           rom_ce_o : out STD_LOGIC --指令寄存器使能
			  );
end component;

component inst_rom
    Port ( ce : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
           inst : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

begin

	cpu_component : cpu port map(rst=>rst,clk=>clk,rom_data_i=>rom_data, rom_addr_o=>rom_addr, rom_ce_o=>rom_ce);
	inst_rom_component : inst_rom port map(inst=>rom_data, addr=>rom_addr, ce=>rom_ce);

end Behavioral;

