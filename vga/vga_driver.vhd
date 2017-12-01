----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:09:48 11/30/2017 
-- Design Name: 
-- Module Name:    vga_driver - Behavioral 
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

entity vga_driver is
	port(
		clk: in std_logic;
		rst: in std_logic;
		char_in: in std_logic_vector(6 downto 0);
		color_in: in std_logic_vector(8 downto 0);
		control_in: in std_logic_vector
		ram_data : inout std_logic_vector(15 downto 0);
		ram_addr : out std_logic_vector(17 downto 0);
		EN, OE, WE : out std_logic;
		
		control_out: out std_logic;
		pixels_out: out std_logic_vector(15 downto 0)
		
	);
end vga_driver;

--640 * 480, 16 * 16, 40 * 30
architecture Behavioral of vga_driver is

	signal write_en : std_logic; 
	signal pos : integer :=0;
	signal pos_x : integer := 0;
	signal pos_y : integer := 0;
	signal addr : std_logic_vector(17 downto 0);
	
begin
	pixels_out <= ram_data;
	pos_x <= pos mod 800;
	pos_y <= pos / 800;
	control_out <= control_in;
	
	bhv: process(clk, rst)
	begin
		if(rst = '0')then
			pos <= 0;
			addr <= others => 0;
		elsif(rising_edge(clk))then
			if(control_in = '1')then -- write ram
				
			else -- read ram
				OE <= '0';
				pos <= pos + 1;
			end if;
		end if;
	end process;
	
end Behavioral;

