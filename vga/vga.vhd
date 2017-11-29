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
		data_in: in std_logic_vector(15 downto 0);
		HS, VS: out std_logic;
		R : out std_logic_vector (2 downto 0);
		G : out std_logic_vector (2 downto 0);
		B : out std_logic_vector (2 downto 0)
	);
end vga;

-- 640 * 480 @60MHz

architecture Behavioral of vga is
signal H_count : integer := 0;
signal V_count : integer := 0;
begin
	R <= data_in(2 downto 0);
	G <= data_in(5 downto 3);
	B <= data_in(8 downto 6);
	
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




