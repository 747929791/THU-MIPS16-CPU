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
    Port ( clk : in STD_LOGIC;
			  rst : in STD_LOGIC;
			  
			  --id段信号
			  ce_id : in  STD_LOGIC;
           addr_id : in  STD_LOGIC_VECTOR (15 downto 0);
			  inst_id : out  STD_LOGIC_VECTOR (15 downto 0);
			  inst_ready : out STD_LOGIC;
			  rom_ready_o : out STD_LOGIC;
			  
			  --mem段信号
			  re_mem : in  STD_LOGIC;
           we_mem : in  STD_LOGIC;
           addr_mem : in  STD_LOGIC_VECTOR (15 downto 0);
           wdata_mem : in  STD_LOGIC_VECTOR (15 downto 0);
			  rdata_mem : out  STD_LOGIC_VECTOR (15 downto 0);
			  ram_ready_o : out STD_LOGIC;
			  
			  --ram1相关接口
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
			  
			  --ram2相关接口
			  Ram2Addr: out STD_LOGIC_VECTOR(17 downto 0);
			  Ram2Data: inout STD_LOGIC_VECTOR(15 downto 0);
			  Ram2OE: out STD_LOGIC;
			  Ram2WE: out STD_LOGIC;
			  Ram2EN: out STD_LOGIC;
			  
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
	constant kernelInstNum : integer := 1000;
	type InstArray is array (0 to InstNum) of STD_LOGIC_VECTOR(15 downto 0);
	signal insts: InstArray := (
		others => NopInst);
	signal clk_2,clk_4,clk_8: STD_LOGIC;
	signal FlashRead, FlashReset: STD_LOGIC;
	signal FlashDataOut: STD_LOGIC_VECTOR(15 downto 0);
	signal FlashAddrIn : STD_LOGIC_VECTOR(22 downto 1);
	signal LoadComplete: STD_LOGIC;
	signal i: STD_LOGIC_VECTOR(15 downto 0);
	signal read_prep, write_prep: STD_LOGIC;
	signal Ram2OE_tmp: STD_LOGIC;
	signal rom_ready: STD_LOGIC;
	
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
	
	ram_ready_o <= '1';
	rom_ready_o <= rom_ready;

	Rom_ready_state: process(addr_mem,we_mem,re_mem)
	begin
		if ((addr_mem >= x"4000") and (addr_mem < x"8000") and (we_mem = Enable)) then
			rom_ready <= '0';
		else 
			rom_ready <= '1';
		end if;
	end process;
	
	Ram1WE_control: process(rst,clk,we_mem,re_mem,addr_mem)
	begin
		if ((rst = Enable) or (we_mem = Disable) or (re_mem = Enable) or (addr_mem = x"bf00") or (addr_mem = x"bf01")) then
			Ram1WE <= '1';
		else 
			Ram1WE <= clk;
		end if;
	end process;
	
	wrn_control: process(rst,clk,we_mem,write_prep,LoadComplete)
	begin
		if ((LoadComplete = '0') or (rst = Enable) or (we_mem = Disable)) then
			wrn <= '1';
		elsif (write_prep = Enable) then
			wrn <= clk;
		else 
			wrn <= '1';
		end if;
	end process;
			
	rdn_control: process(rst,clk,re_mem,read_prep,LoadComplete)
	begin
		if ((LoadComplete = '0') or (rst = Enable) or (re_mem = Disable)) then
			rdn <= '1';
		elsif (read_prep = Enable) then
			rdn <= clk;
		else 
			rdn <= '1';
		end if;
	end process;
	
	Ram1_control: process(clk, rst, addr_mem, we_mem, re_mem, wdata_mem, data_ready, tbre, tsre)
	begin
		if (rst = Enable) then
			Ram1EN <= '0';
			Ram1OE <= '1';
			Ram1Addr <= (others => '0');
			Ram1Data <= (others => 'Z');
			read_prep <= Disable;
			write_prep <= Disable;
		else
			if ((we_mem = Disable) and (re_mem = Disable)) then
				read_prep <= Disable;
				write_prep <= Disable;
				Ram1EN <= '0';
				Ram1OE <= '0';
				Ram1Addr <= "00" & addr_mem;
				Ram1Data <= (others => 'Z');
			elsif (we_mem = Enable) then
				if (addr_mem = x"bf00") then
					--写串口
					Ram1EN <= '1';
					Ram1OE <= '1';
					Ram1Addr <= "00" & x"bf00";
					Ram1Data <= wdata_mem;
					read_prep <= Disable;
					write_prep <= Enable;
				else
					--写数据
					Ram1EN <= '0';
					Ram1OE <= '1';
					Ram1Addr <= "00" & addr_mem;
					Ram1Data <= wdata_mem;
					read_prep <= Disable;
					write_prep <= Disable;
				end if;
			elsif (re_mem = Enable) then
				if (addr_mem = x"bf00") then
					--读串口
					Ram1EN <= '1';
					Ram1OE <= '1';
					Ram1Addr <= "00" & x"bf00";
					Ram1Data <= (others => 'Z');
					read_prep <= Enable;
					write_prep <= Disable;
				elsif (addr_mem = x"bf01") then	
					--准备读或写串口
					Ram1EN <= '0';
					Ram1OE <= '1';
					Ram1Addr <= "00" & addr_mem;
					read_prep <= Disable;
					write_prep <= Disable;
					
					if ((data_ready = '1') and (tbre = '1') and (tsre= '1')) then 
						--串口数据可读写
						Ram1Data <= x"0003";
					elsif ((tbre = '1') and (tsre= '1')) then  
						--串口数据只可写
						Ram1Data <= x"0001";
					elsif (data_ready = '1') then  
						--串口数据只可读
						Ram1Data <= x"0002";
					else 
						--串口数据不可读写
						Ram1Data <= (others => '0');
					end if;
				else 
					--读数据
					Ram1EN <= '0';
					Ram1OE <= '0';
					Ram1Addr <= "00" & addr_mem;
					Ram1Data <= (others => 'Z');
					read_prep <= Disable;
					write_prep <= Disable;
				end if;
			else 
				--不应到达这里
				Ram1EN <= '0';
				Ram1OE <= '0';
				Ram1Addr <= "00" & addr_mem;
				Ram1Data <= (others => 'Z');
				read_prep <= Disable;
				write_prep <= Disable;
			end if;
		end if;
	end process;

	Mem_read : process(rst,addr_id,addr_mem,re_mem,wdata_mem,Ram1Data)
	variable id : integer;
	begin
		if(rst = Enable) then
			rdata_mem <= ZeroWord;
		elsif(re_mem = Disable) then
			rdata_mem <= ZeroWord;
		else
			rdata_mem <= Ram1Data;
		end if;
	end process;

	Inst: process(rst,ce_id,rom_ready,Ram2Data,LoadComplete)
	begin
		if((ce_id = Enable) and (rst = Disable) and (LoadComplete = Enable) and (rom_ready = Enable)) then
			inst_id <= Ram2Data;
		else
			inst_id <= NopInst;
		end if;
	end process;
	
	Ram2OE <= Ram2OE_tmp;
	Ram2WE <= clk or rst or not(Ram2OE_tmp);
	Ram2EN <= '0';
	
	Rom: process(addr_id,clk_8,clk,FlashDataOut,rst,i,LoadComplete,we_mem,addr_mem,wdata_mem)
	begin
		if (rst = Enable) then
			Ram2Addr <= (others => '0');
			Ram2Data <= (others => '0');
			FlashAddrIn <= (others => '0');
			Ram2OE_tmp <= '1';
			LoadComplete <= '0';
			FlashReset <= '0';
			i <= (others => '0');			
		else
			if (LoadComplete = '1') then 
				if ((we_mem = Enable) and (addr_mem >= x"4000") and (addr_mem < x"8000")) then
					Ram2Addr <= "00" & addr_mem;
					Ram2Data <= wdata_mem;
					Ram2OE_tmp <= '1';
				else
					Ram2Addr <= "00" & addr_id;
					Ram2Data <= (others => 'Z');
					Ram2OE_tmp <= '0';
				end if;
				FlashReset <= '0';
			else
				if (i = kernelInstNum) then 
					Ram2Addr <= "00" & addr_id;
					Ram2OE_tmp <= '0';
					FlashReset <= '0';
					LoadComplete <= '1';
					Ram2Data <= (others => 'Z');
				else 
					Ram2OE_tmp <= '1';
					FlashReset <= '1';
					if (i>0) then
						Ram2Addr <= "00" & (i-1);
						FlashAddrIn <= "000000" & (i-1);	
						Ram2Data <= FlashDataOut;	
					end if;
					if (clk_8'event and (clk_8 = '1')) then 		
						FlashRead <= not(FlashRead);
						i <= i+1;
					end if;
				end if;
			end if;
			
		end if;
	end process;
	
end Behavioral;

