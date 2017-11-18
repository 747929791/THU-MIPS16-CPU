----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:31:04 11/15/2017 
-- Design Name: 
-- Module Name:    inst_rom - Behavioral 
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
use WORK.DEFINES.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--指令存储器ROM模拟模块
entity inst_rom is
    Port ( ce : in  STD_LOGIC;
			  clk : in STD_LOGIC;
			  rst : in STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
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
           inst : out  STD_LOGIC_VECTOR (15 downto 0));
end inst_rom;
architecture Behavioral of inst_rom is
	constant InstNum : integer := 100;
	type InstArray is array (0 to InstNum) of STD_LOGIC_VECTOR(15 downto 0);
	signal insts: InstArray := (
	  --01000xxxyyy0iiii 访存LWSW测试
	  --11011xxxyyyiiiii SW (Rx+imm)<-Ry
	  --10011xxxyyyiiiii SW (Rx+imm)->Ry
		"0100000000000001", --R[0]+=1
		"1101100100000011", --SW(R[0])->RAM[R(1)+3]
		"1001100000100010", --LW(RAM[R[0]+2])->R[1]
		"0100000100100001", --R[1]++
		"0100010010000001", --R[4]++ 现在R[0]=1,R[1]=1,R[4]=1,RAM[3]=1
		"0100000000000001", --R[0]++
		"1101100100000011", --SW(R[0])->RAM[R(1)+3] 现在R[0]=2,R[1]=2,R[4]=1,RAM[3]=1,RAM[4]=2
		others => ZeroWord);
begin
	process(ce,addr)
		variable id : integer;
	begin
		if(ce = Enable) then
			id:=conv_integer(addr);
			if(id>InstNum) then
				inst <= ZeroWord;
			else
				inst <= Ram1Data;
			end if;
		else
			inst <= ZeroWord;
		end if;
	end process;
	
	process(addr,rst)
	begin
		if (rst = Enable) then
			Ram1Addr <= (others => '0');
			Ram1Data <= (others => 'Z');
			Ram1OE <= '1';
			Ram1WE <= '1';
			Ram1EN <= '0';
			rdn <= '1';
			wrn <= '1';
		else
			Ram1Addr <= "00" & addr;
			Ram1OE <= '0';
			Ram1WE <= '1';
			Ram1EN <= '0';
			rdn <= '1';
			wrn <= '1';
		end if;
	end process;
end Behavioral;

