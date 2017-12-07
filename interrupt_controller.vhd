----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:01:08 12/05/2017 
-- Design Name: 
-- Module Name:    interrupt_controller - Behavioral 
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

entity interrupt_controller is
port(
	clk,rst : in std_logic;
	interrupt : in std_logic;
	enable : in std_logic;
	int_code_in: in std_logic_vector(3 downto 0);
	inst_in : in std_logic_vector(15 downto 0);
	inst_out : out std_logic_vector(15 downto 0)
);
end interrupt_controller;

architecture Behavioral of interrupt_controller is

type state is (state0, state1, state2);
signal current_state : state := state0;
signal int_signal : std_logic := '0';
signal int_code : std_logic_vector(3 downto 0) := "0000";
begin

	int_code <= int_code_in;
	
	INT_STATE : process(clk, interrupt)
	begin
		if(enable = '1')then
			if(interrupt = '1')then
				int_signal <= '1';
				if(current_state = state0)then
					current_state <= state1;
				end if;
			elsif(rising_edge(clk))then
				case current_state is
					when state1 =>
						current_state <= state2;
					when others =>
						current_state <= state0;
				end case;
			end if;
		end if;
	end process;
	
	OUTPUT : process(clk, current_state)
	begin
		if(enable = '1')then
			case current_state is
				when state0 =>
					inst_out <= inst_in;
				when state1 =>
					inst_out <= "111110000000" & int_code;
				when state2 =>
					inst_out <= "0000100000000000";
				when others =>
					inst_out <= inst_in;
			end case;
		else
			inst_out <= inst_in;
		end if;
	end process;

end Behavioral;
