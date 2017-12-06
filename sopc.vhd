----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:40:22 11/15/2017 
-- Design Name: 
-- Module Name:    sopc - Behavioral 
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

entity sopc is
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
			  
			  FlashByte: out STD_LOGIC;
			  FlashVpen: out STD_LOGIC;
			  FlashCE: out STD_LOGIC;
			  FlashOE: out STD_LOGIC;
			  FlashWE: out STD_LOGIC;
			  FlashRP: out STD_LOGIC;
			  FlashAddr: out STD_LOGIC_VECTOR(22 downto 1);
			  FlashData: inout STD_LOGIC_VECTOR(15 downto 0);
			  
			  LED: out STD_LOGIC_VECTOR(15 downto 0);

			  HS, VS: out std_logic;
			  R : out std_logic_vector (2 downto 0);
			  G : out std_logic_vector (2 downto 0);
		     B : out std_logic_vector (2 downto 0);
			  PS2_CLK : in std_logic;
			  PS2_DATA : in std_logic
			  );
end sopc;

architecture Behavioral of sopc is

signal clk, rst : STD_LOGIC;
signal rom_data : STD_LOGIC_VECTOR(15 downto 0);
signal rom_addr : STD_LOGIC_VECTOR(15 downto 0);
signal rom_ce : STD_LOGIC;
signal ram_rdata : STD_LOGIC_VECTOR(15 downto 0);
signal ram_read : STD_LOGIC;
signal ram_write : STD_LOGIC;
signal ram_addr : STD_LOGIC_VECTOR(15 downto 0);
signal ram_wdata : STD_LOGIC_VECTOR(15 downto 0);
signal ram_ce : STD_LOGIC;
signal rst_reversed : STD_LOGIC;
signal rst_cpu : STD_LOGIC;
signal inst_ready : STD_LOGIC;
signal rom_ready : STD_LOGIC;
signal ram_ready : STD_LOGIC;
signal zero : STD_LOGIC;
signal zeros : std_logic_vector(15 downto 0);

signal vga_addr : std_logic_vector(17 downto 0);
signal vga_data : std_logic_vector(15 downto 0);
signal vga_pos_in, vga_pos_out :std_logic_vector(11 downto 0);
signal vga_data_in, vga_data_out :std_logic_vector(15 downto 0);
signal vga_mem_we: std_logic_vector(0 downto 0);

signal PS2Code: std_logic_vector(7 downto 0);
signal PS2OE: std_logic;
signal kbdASCII: std_logic_vector(15 downto 0);
signal kbdOE: std_logic;

component vga is
	port(
		clk: in std_logic;
		--data_in: in std_logic_vector(18 downto 0);
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
end component; 

component cpu
	    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;

			  LED : out STD_LOGIC_VECTOR(15 downto 0);
			  rom_ready_i : in STD_LOGIC; --取指是否成功
           rom_data_i : in STD_LOGIC_VECTOR(15 downto 0); --取得的指令
           rom_addr_o : out STD_LOGIC_VECTOR(15 downto 0); --指令寄存器地址
           rom_ce_o : out STD_LOGIC; --指令存储器使能
			  ram_ready_i : in STD_LOGIC; --访存是否成功
           ram_rdata_i : in STD_LOGIC_VECTOR(15 downto 0);
           ram_read_o : out STD_LOGIC;
           ram_write_o : out STD_LOGIC;
           ram_addr_o : out STD_LOGIC_VECTOR(15 downto 0);
           ram_wdata_o : out STD_LOGIC_VECTOR(15 downto 0);
           ram_ce_o : out STD_LOGIC; --数据存储器使能
			  interrupt_in : in STD_LOGIC
			  );
end component;

component inst_rom
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
			  FlashData: inout STD_LOGIC_VECTOR(15 downto 0);
			  
			  --vga
			  VGAAddr: in STD_LOGIC_VECTOR(17 downto 0);
			  VGAData: out STD_LOGIC_VECTOR(15 downto 0);
			  VGAPos: out std_logic_vector(11 downto 0);
			  VGAData1: out std_logic_vector(15 downto 0);
			  VGAMEMWE: out STD_LOGIC;
			  
			  --PS2
			  LED: out STD_LOGIC_VECTOR(15 downto 0);
			  keyboardASCII: in STD_LOGIC_VECTOR(15 downto 0);
			  keyboardOE : in STD_LOGIC);
end component;


component my_dcm is
   port ( CLKIN_IN        : in    std_logic; 
          RST_IN          : in    std_logic; 
          CLKDV_OUT       : out   std_logic; 
          CLKFX_OUT       : out   std_logic; 
          CLKIN_IBUFG_OUT : out   std_logic; 
          CLK0_OUT        : out   std_logic; 
          CLK2X_OUT       : out   std_logic; 
          LOCKED_OUT      : out   std_logic);
end component;

COMPONENT screen_mem is
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

component PS2 is
port (
	CLK_MAIN, RST: in std_logic;
	PS2_DATA, PS2_CLK: in std_logic; -- PS2 clk and data
	SCANCODE: out std_logic_vector(7 downto 0); -- scan code signal output
	OE: out std_logic
	) ;
end component ;

component keyboard is
port (
	CLK_MAIN, RST: in std_logic;
	PS2_CODE: in std_logic_vector(7 downto 0);
	PS2_OE: in std_logic;
	ASCII: out STD_LOGIC_VECTOR(15 downto 0);
	KeyboardOE: out STD_LOGIC
	) ;
end component ;

begin
	rst<=rst_in;
	zero <= '0';
	zeros <= "0000000000000000";
	--clk <= clk_in;
	rst_reversed <= not(rst);
	rst_cpu <= rst_reversed or not(inst_ready);
	vga_component : vga port map(clk=>clk, pos_in=>vga_pos_in, data_in=>vga_data_in, 
											R=>R, G=>G, B=>B, HS=>HS, VS=>VS, 
											ram_addr => vga_addr, ram_data => vga_data);
											
	PS2_component : PS2 port map(CLK_MAIN=>clk, RST=>rst, PS2_DATA=>PS2_DATA, PS2_CLK=>PS2_CLK, SCANCODE=>PS2Code, OE=>PS2OE);
	
	Keyboard_component : keyboard port map(CLK_MAIN=>clk, RST=>rst, PS2_CODE=>PS2Code, PS2_OE=>PS2OE, ASCII=>kbdASCII, KeyboardOE=>kbdOE);
											
	dcm_component : my_dcm port map(CLKIN_IN=>clk_in, RST_IN=>zero, CLKFX_OUT=>clk);
										  

	cpu_component : cpu port map(rst=>rst_cpu,clk=>clk,rom_data_i=>rom_data, rom_addr_o=>rom_addr, rom_ce_o=>rom_ce,rom_ready_i=>rom_ready,LED=>LED,
										  ram_rdata_i=>ram_rdata,ram_read_o=>ram_read,ram_write_o=>ram_write,ram_addr_o=>ram_addr,
										  ram_wdata_o=>ram_wdata,ram_ce_o=>ram_ce,ram_ready_i=>ram_ready, interrupt_in => kbdOE);

	--cpu_component : cpu port map(rst=>rst_cpu,clk=>clk,rom_data_i=>rom_data, rom_addr_o=>rom_addr, rom_ce_o=>rom_ce,rom_ready_i=>rom_ready,
	--										--LED=>LED,
	--									  ram_rdata_i=>ram_rdata,ram_read_o=>ram_read,ram_write_o=>ram_write,ram_addr_o=>ram_addr,ram_wdata_o=>ram_wdata,ram_ce_o=>ram_ce,ram_ready_i=>ram_ready);

		
	inst_rom_component : inst_rom port map(rst=>rst_reversed, clk=>clk, 
		ce_id=>rom_ce, addr_id=>rom_addr, inst_id=>rom_data, inst_ready=>inst_ready, rom_ready_o=>rom_ready,
		re_mem=>ram_read, we_mem=>ram_write, addr_mem=>ram_addr,wdata_mem=>ram_wdata,rdata_mem=>ram_rdata, ram_ready_o=>ram_ready,
		data_ready=>data_ready, tbre=>tbre, tsre=>tsre, Ram1Addr=>Ram1Addr, Ram1Data=>Ram1Data,
		Ram1OE=>Ram1OE, Ram1WE=>Ram1WE, Ram1EN=>Ram1EN, rdn=>rdn, wrn=>wrn, 
		Ram2Addr=>Ram2Addr, Ram2Data=>Ram2Data, Ram2OE=>Ram2OE, Ram2WE=>Ram2WE, Ram2EN=>Ram2EN, 
		VGAAddr =>vga_addr, VGAData => vga_data, VGAMEMWE => vga_mem_we(0), VGAPos => vga_pos_out, VGAData1 => vga_data_out,
		keyboardASCII => kbdASCII, keyboardOE => kbdOE, --LED=>LED,
		FlashByte=>FlashByte, FlashVpen=>FlashVpen, FlashCE=>FlashCE, FlashOE=>FlashOE, FlashWE=>FlashWE, FlashRP=>FlashRP, FlashAddr=>FlashAddr, FlashData=>FlashData);
	
--	ram_component : ram port map(rst=>rst_reversed,clk=>clk,re=>ram_read,we=>ram_write,addr=>ram_addr,wdata=>ram_wdata,rdata=>ram_rdata,
--	Ram2Addr=>Ram2Addr, Ram2Data=>Ram2Data, Ram2OE=>Ram2OE, Ram2WE=>Ram2WE, Ram2EN=>Ram2EN);

	screen_mem_component : screen_mem port map(clka=>clk, clkb=>clk, addra=>vga_pos_out, dina=>vga_data_out, wea=>vga_mem_we, addrb=>vga_pos_in, doutb=>vga_data_in);


end Behavioral;

