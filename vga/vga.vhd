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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
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

		pos_in: out std_logic_vector(11 downto 0);
		data_in: in std_logic_vector(15 downto 0);
		--control:in std_logic;
		ram_data: in std_logic_vector(15 downto 0);
		ram_addr: out std_logic_vector(17 downto 0);
		HS, VS: out std_logic;
		R : out std_logic_vector (2 downto 0);
		G : out std_logic_vector (2 downto 0);
		B : out std_logic_vector (2 downto 0)
	);
end vga;

-- 640 * 480 @60MHz
-- divided into 80 * 30 blocks;
-- 56 * 21 blocks;

architecture Behavioral of vga is

constant start_addr: std_logic_vector(17 downto 0) := "001000000000000000";
constant img_size: integer := 128;

--block计数
signal H_count : integer := 0;
signal V_count : integer := 0;

--当前输出的块的x, y及颜色信息
signal block_x : integer := 0;
signal block_y : integer := 0;
signal R_block : integer := 0;
signal G_block : integer := 0;
signal B_block : integer := 0;
signal current_block : std_logic_vector(15 downto 0);

--当前像素相对于block的坐标
signal inblock_x : integer := 0;
signal inblock_y : integer := 0;

begin
	block_x <= H_count / 8;
	block_y <= V_count / 16;
	inblock_x <= H_count - 8 * block_x;
	inblock_y <= V_count - 16 * block_y;
		
	pos_in <= conv_std_logic_vector(block_x*80+block_y,12);
	
	current_block <= data_in;
	R_block <= conv_integer(current_block(15 downto 13));
	G_block <= conv_integer(current_block(12 downto 10));
	B_block <= conv_integer(current_block(9 downto 7));
	
--	screen(0, 0) <= "0000000000000000";
--	screen(10, 10) <= "1111111110000000";
--	screen(10, 11) <= "1111111110000001";
--	screen(10, 12) <= "1111111110000010";

	ram_addr <= start_addr + conv_integer(data_in(6 downto 0)) * img_size + inblock_x + inblock_y * 8;
	--ram_addr <= start_addr + (conv_integer(block_x) + conv_integer(block_y)) * img_size + inblock_x + inblock_y * 8;
	--ram_addr <= start_addr;
	display : process(H_count, V_count, ram_data)
		begin
			if(V_count >= 480 or H_count >= 640)then
				
				R <= "000";
				G <= "000";
				B <= "000";
			else
--				if(ram_data = "0000000000000000") then
				R <= ram_data(2 downto 0);
				G <= ram_data(5 downto 3);
				B <= ram_data(8 downto 6);
--				else
--					R <= "111";
--					G <= "000";
--					B <= "000";
--				end if;
--				if(H_count <= 160)then
--					R <= "111";
--					G <= "000";
--					B <= "000";
--				elsif(H_count <= 320)then
--					R <= "000";
--					G <= "000";
--					B <= "111";
--				elsif(H_count <= 480)then
--					R <= "000";
--					G <= "111";
--					B <= "000";
--				else
--					R <= "111";
--					G <= "111";
--					B <= "111";
--				end if;
			end if;
		end process;
		
	update : process(V_count, H_count)
		begin
			if(H_count >= 656 and H_count <= 751)then
				HS <= '0';
			else
				HS <= '1';
			end if;
			
			if(V_count >= 490 and V_count <= 491)then
				VS <= '0';
			else
				VS <= '1';
			end if;
		end process;
	
	h_update : process(clk)
		begin
			if(rising_edge(clk))then
				
				if(H_count < 799)then
					H_count <= H_count + 1;
				else
					H_count <= 0;
				end if;
			end if;
		end process;
		
	v_update : process(clk)
		begin
			if(rising_edge(clk))then
				if(H_count = 799)then
					if(V_count < 524)then
						V_count <= V_count + 1;
					else
						V_count <= 0;
					end if;
				end if;
			end if;			
		end process;

	

end Behavioral;




