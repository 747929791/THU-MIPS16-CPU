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
		--data_in: in std_logic_vector(18 downto 0);
		pos_in: in std_logic_vector(15 downto 0);
		data_in: in std_logic_vector(15 downto 0);
		--pos, data使能
		WE_i_1, WE_i_2: in std_logic;
		--control:in std_logic;
		ram_data: in std_logic_vector(15 downto 0);
		ram_addr: out std_logic_vector(17 downto 0);
		HS, VS: out std_logic;
		WE_o_1, WE_o_2: out std_logic;
		R : out std_logic_vector (2 downto 0);
		G : out std_logic_vector (2 downto 0);
		B : out std_logic_vector (2 downto 0)
	);
end vga;

-- 640 * 480 @60MHz
-- divided into 80 * 30 blocks;
-- 56 * 21 blocks;

architecture Behavioral of vga is

--显存
type screen_info is array (79 downto 0, 29 downto 0) of std_logic_vector(15 downto 0);
signal screen : screen_info;


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

--输入x, y坐标
signal in_x : integer := 0;
signal in_y : integer := 0;
signal block_info : std_logic_vector(6 downto 0);

begin
	
	block_x <= H_count / 8;
	block_y <= V_count / 16;
	inblock_x <= H_count - 8 * block_x;
	inblock_y <= V_count - 16 * block_y;
	current_block <= screen(block_x, block_y);
	R_block <= conv_integer(current_block(15 downto 13));
	G_block <= conv_integer(current_block(12 downto 10));
	B_block <= conv_integer(current_block(9 downto 7));
	
	in_x <= conv_integer(pos_in(7 downto 0));
	in_y <= conv_integer(pos_in(15 downto 8));
	
--	screen(0, 0) <= "0000000000000000";
--	screen(10, 10) <= "1111111110000000";
--	screen(10, 11) <= "1111111110000001";
--	screen(10, 12) <= "1111111110000010";
	
	--ram_addr <= start_addr + conv_integer(screen(block_x, block_y)(6 downto 0)) * img_size + inblock_x + inblock_y * 8;
	ram_addr <= start_addr + (conv_integer(block_x) + conv_integer(block_y)) * img_size + inblock_x + inblock_y * 8;
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
				if(WE_i_1 = '1' and WE_i_2 = '1')then
					--screen(in_x, in_y) <= data_in;
					WE_o_1 <= '0';
					WE_o_2 <= '0';
				else
					WE_o_1 <= '1';
					WE_o_2 <= '1';
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




