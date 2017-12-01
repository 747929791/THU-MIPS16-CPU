----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:38:59 11/28/2017 
-- Design Name: 
-- Module Name:    vga - Behavioral 
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

entity vga is
	port(
		clk: in std_logic;
		rst: in std_logic; 
		data_in: in std_logic_vector(18 downto 0);
		control:in std_logic;
		ram_data: inout std_logic_vector(15 downto 0);
		ram_addr: out std_logic_vector(17 downto 0);
		EN, OE, WE: out std_logic;
		HS, VS: out std_logic;
		R : out std_logic_vector (2 downto 0);
		G : out std_logic_vector (2 downto 0);
		B : out std_logic_vector (2 downto 0)
	);
end vga;

-- 640 * 480 @60MHz
-- divided into 80 * 30 blocks;

architecture Behavioral of vga is

type screen_info is array (80 downto 0, 30 downto 0) of std_logic_vector(6 downto 0);
signal screen : screen_info;

constant start_addr: std_logic_vector(18 downto 0) := ???;
constant img_size: integer := 128;
signal H_count : integer := 0;
signal V_count : integer := 0;
signal block_x : integer := 0;
signal block_y : integer := 0;
signal inblock_x : integer := 0;
signal inblock_y : integer := 0;

signal in_x : integer := 0;
signal in_y : integer := 0;
signal block_info : std_logic_vector(6 downto 0);

begin
	R <= ram_data(2 downto 0);
	G <= ram_data(5 downto 3);
	B <= ram_data(8 downto 6);
	
	EN <= '1';
	WE <= '1';
	OE <= not(control);
	
	block_x <= V_count / 8;
	block_y <= H_count / 16;
	inblock_x <= V_count - 8 * block_x;
	inblock_y <= H_count - 16 * block_y;
	
	in_x <= conv_integer(data_in(18 downto 12));
	in_y <= conv_integer(data_in(11 downto 7));
	block_info <= data_in(6 downto 0);
	
	ram_addr <= start_addr + conv_integer(screen(block_x)(block_y)) * img_size + inblock_x + inblock_y * 8;
	
	update : process(H_count)
		begin
			if(H_count >= 490 and H_count >= 491)then
				HS <= '0';
			else
				HS <= '1';
			end if;
		end process;
	
	v_update : process(clk, rst)
		begin
			if(rst = '0') then
				V_count <= 0;
				
			elsif(rising_edge(clk))then
				V_count <= (V_count + 1) mod 800;
				if(control = 1)then
					screen(in_x)(in_y) <= block_info;
				end if;
			end if;
		end process;
		
	h_update : process(V_count, rst)
		begin
			if(rst = '0')then
				H_count <= 0;
			elsif(V_count = 0)then
				H_count <= (H_count + 1) mod 525;
			end if;
			
			if(V_count >= 656 and V_count <= 751)then
				VS <= '0';
			else
				VS <= '1';
			end if;
		end process;

	

end Behavioral;




