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
			  inst : out  STD_LOGIC_VECTOR (15 downto 0);
			  inst_ready : out STD_LOGIC;
			  
			  --ram相关接口
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
			  
			  --flash相关接口
			  FlashByte: out STD_LOGIC;
			  FlashVpen: out STD_LOGIC;
			  FlashCE: out STD_LOGIC;
			  FlashOE: out STD_LOGIC;
			  FlashWE: out STD_LOGIC;
			  FlashRP: out STD_LOGIC;
			  FlashAddr: out STD_LOGIC_VECTOR(22 downto 1);
			  FlashData: inout STD_LOGIC_VECTOR(15 downto 0));
end inst_rom;

architecture Behavioral of inst_rom is
	constant InstNum : integer := 100;
	constant kernelInstNum : integer := 10;
	type InstArray is array (0 to InstNum) of STD_LOGIC_VECTOR(15 downto 0);
	signal insts: InstArray := (
		--BNEQZ测试
		"0110101000000011", --LI R[2], 3
		"1110101001001011", --NEG R[2], R[2]
		"0110100000000100", --LI R[0], 4
		"1110100000001011", --NEG R[0], R[0]
		"0100000000000001", --R[0]++
		"1101100100000011", --SW(R[0])->RAM[R(1)+3] 现在R[0]=2,R[1]=2,R[4]=1,RAM[3]=1,RAM[4]=2
		others => NopInst);
	signal clk_2,clk_4,clk_8: STD_LOGIC;
	signal FlashRead, FlashReset: STD_LOGIC;
	signal FlashDataOut: STD_LOGIC_VECTOR(15 downto 0);
	signal FlashAddrIn : STD_LOGIC_VECTOR(22 downto 1);
	signal LoadComplete: STD_LOGIC;
	signal i: STD_LOGIC_VECTOR(15 downto 0);
	
	component flash_io
    Port ( addr : in  STD_LOGIC_VECTOR (22 downto 1);
           data_out : out  STD_LOGIC_VECTOR (15 downto 0);
			  clk : in std_logic;
			  reset : in std_logic;
			  
			  flash_byte : out std_logic;
			  flash_vpen : out std_logic;
			  flash_ce : out std_logic;
			  flash_oe : out std_logic;
			  flash_we : out std_logic;
			  flash_rp : out std_logic;
			  flash_addr : out std_logic_vector(22 downto 1);
			  flash_data : inout std_logic_vector(15 downto 0);
			  
           ctl_read : in  STD_LOGIC
	);
	end component;
	
begin
	process(clk)	--二分频
	begin
	if clk'event and clk='1' then
		clk_2 <= not clk_2;
	end if;
	end process;
	
	process(clk_2)	--四分频
	begin
	if clk_2'event and clk_2='1' then
		clk_4 <= not clk_4;
	end if;
	end process;
	
	process(clk_4)	--八分频
	begin
	if clk_4'event and clk_4='1' then
		clk_8 <= not clk_8;
	end if;
	end process;

	flash_io_component: flash_io port map(addr=>FlashAddrIn, data_out=>FlashDataOut, clk=>clk, reset=>FlashReset,
														flash_byte=>FlashByte, flash_vpen=>FlashVpen, flash_ce=>FlashCE, flash_oe=>FlashOE, flash_we=>FlashWE,
														flash_rp=>FlashRP, flash_addr=>FlashAddr, flash_data=>FlashData, ctl_read=>FlashRead);

	inst_ready <= LoadComplete;
	Ram1WE <= clk or rst or LoadComplete;

	process(rst,ce,addr,Ram1Data)
	variable id:integer;
	begin
		if((ce = Enable) and (rst = Disable) and (LoadComplete = Enable)) then
--			id:= conv_integer(addr);
--			if (id < InstNum) then
--				inst <= insts(id);
--			else
--				inst <= ZeroWord;
--			end if;
			inst <= Ram1Data;
		else
			inst <= ZeroWord;
		end if;
	end process;
	
	process(addr,clk_8,rst,i)
	begin
		if (rst = Enable) then
			Ram1Addr <= (others => '0');
			Ram1Data <= (others => 'Z');
			Ram1OE <= '1';
			Ram1EN <= '0';
			rdn <= '1';
			wrn <= '1';
			LoadComplete <= '0';
			FlashReset <= '0';
			i <= (others => '0');			
		else
			if (LoadComplete = '1') then 
				Ram1Addr <= "00" & addr;
				Ram1Data <= (others => 'Z');
				Ram1OE <= '0';
				Ram1EN <= '0';
				rdn <= '1';
				wrn <= '1';
				FlashReset <= '0';
			else
				if (i = kernelInstNum) then 
					Ram1Addr <= "00" & addr;
					Ram1OE <= '0';
					Ram1EN <= '0';
					rdn <= '1';
					wrn <= '1';
					FlashReset <= '0';
					LoadComplete <= '1';
					Ram1Data <= (others => 'Z');
				else 
					Ram1OE <= '1';
					Ram1EN <= '0';
					rdn <= '1';
					wrn <= '1';
					FlashReset <= '1';
					Ram1Addr <= "00" & i;
					FlashAddrIn <= "000000" & i;
					Ram1Data <= FlashDataOut;				
					if (clk_8'event and (clk_8 = '1')) then 
						FlashRead <= not(FlashRead);
						i <= i+1;
					end if;
				end if;
			end if;
			
		end if;
	end process;
end Behavioral;

