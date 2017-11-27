--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:57:37 11/15/2017
-- Design Name:   
-- Module Name:   F:/Xilinx/Project/CPU/addiu3_test.vhd
-- Project Name:  CPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sopc
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY addiu3_test IS
END addiu3_test;
 
ARCHITECTURE behavior OF addiu3_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sopc
    Port ( rst_in : in  STD_LOGIC;
           clk_in : in  STD_LOGIC;
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
			  LED: out STD_LOGIC_VECTOR(15 downto 0));
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
	signal data_ready : std_logic := '0';
   signal tbre : std_logic := '0';
	signal tsre : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: sopc PORT MAP (
          rst_in => rst,
          clk_in => clk,
			 data_ready => data_ready,
			 tbre => tbre,
			 tsre => tsre
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		rst <= '1';
      -- hold reset state for 100 ns.
      wait for 20 ns;	
		rst <= '0';
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
